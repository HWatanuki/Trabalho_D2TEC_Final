// 1 -- Importacao dos arquivos blk.dat como blob's
// Declaracao do schema do blob
rawrec := RECORD
    DATA1 block; // cada byte do objeto binario bruto
END;

// Declaracao do blob 
rawds := DATASET('~ifsp::hmw::bitcoinraw',rawrec,FLAT);

// Visualizaçao do blob (HEX)
OUTPUT(rawds,NAMED('Hex_Data'));
COUNT(rawds);

// 2 -- Extracao dos dados primarios do blob e
// conversao em formato relacional

IMPORT Python3 AS Python;  
													 
// Declaracao do schema do dataset a ser obtido										
rec := RECORD
  STRING  tx_hash;   // hash da transacao
  INTEGER in_index;  // indice da transacao
  STRING  in_hash;   // hash do input da transcao
  INTEGER out_index; // indice do output da transacao
  STRING  out_addr;  // endereco do output da transacao
  INTEGER out_val;   // valor em bitcoin negociado
  STRING  timestamp; // data da transacao
END;

// Declaracao da funcao de conversao das informacoes binarias do blob em formato relacional
DATASET(rec) Parser(STRING filepath, STRING filepattern) := EMBED(Python: activity)
  import pandas as pd
  from HPCC_bitcoin_parser.blockchain import Blockchain
  from datetime import datetime
  rows=[]
  df=pd.DataFrame(columns=['tx_hash', 'in_index', 'in_hash', 'out_index', 'out_addr', 'out_val', 'timestamp'])
  counter = 0
  blockchain = Blockchain(filepath, filepattern)
  for i, block in enumerate(blockchain.get_unordered_blocks()):
      print(i)
      for tx in block.transactions:
          counter +=1
          if(counter == 10000):
              df = df.append(pd.DataFrame(rows, columns = df.columns))
              rows=[]
              counter=0
          # print("\nHash " + tx.hash)
          # print("-----------------------------------")
          # print("\nInputs")
          for no, input in enumerate(tx.inputs):
              #print("tx=%s outputno=%d type=%s value=%s" % (tx.hash, no, output.type, output.value))
              # print("Hash : " + str(input.transaction_hash) + "\nIndex : " +str(input.transaction_index))
              # print("\nOutput")
              for no_out, output in enumerate(tx.outputs):
                  #print("tx=%s outputno=%d type=%s value=%s" % (tx.hash, no, output.type, output.value))
                  # print("No : "+ str(no_out)+"\nAddy : " + str(output.addresses[0].address)+"\nValue : "+str(output.value))
                  if(len(output.addresses) == 1):
                      rows.append([tx.hash,input.transaction_index, input.transaction_hash, no_out, output.addresses[0].address, output.value, block.header.timestamp.strftime("%Y-%m-%d, %H:%M:%S")])
                  # print(rows)
  return list(df.itertuples(index=False))
ENDEMBED;

// Visualizacao dos dados primarios em formato relacional
myds := Parser('/var/lib/HPCCSystems/hpcc-data/ifsp/hmw/','bitcoinraw._1_of_[0-9]+'):PERSIST('temp');
OUTPUT(myds,,'~ifsp::hmw::bitcoin',NAMED('Relational_data'));
COUNT(Parser('/var/lib/HPCCSystems/hpcc-data/ifsp/hmw/','bitcoinraw._1_of_[0-9]+'));

// 3 -- Analise das 10 maiores transacoes de bitcoin
sortval := SORT(myds,-out_val);
top10val := CHOOSEN(sortval,10);
OUTPUT(top10val,NAMED('Top10_transactions'));

// 4 -- Analise dos 10 enderecos que mais receberam transacoes de bitcoin
mytbl := TABLE(myds,{out_addr; UNSIGNED cnt:=COUNT(GROUP); tot_val:=SUM(GROUP,out_val);},out_addr);
sortaddr := SORT(mytbl,-cnt,-tot_val);
top10cnt := CHOOSEN(sortaddr,10);
OUTPUT(top10cnt,NAMED('Top10_addresses'));