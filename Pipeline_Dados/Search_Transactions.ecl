// Funcao para retornar as transacoes dentro de um intervalo min/max
EXPORT Search_Transactions(INTEGER min_value, INTEGER max_value) := FUNCTION
  // Schema do dataset de transacoes de bitcoin  
	rec := RECORD
    STRING  tx_hash;   // hash da transacao
    INTEGER in_index;  // indice da transacao
    STRING  in_hash;   // hash do input da transcao
    INTEGER out_index; // indice do output da transacao
    STRING  out_addr;  // endereco do output da transacao
    INTEGER out_val;   // valor em bitcoin negociado
    STRING  timestamp; // data da transacao
  END;
  // Declaracao do dataset de transacoes de bitcoin
  myds:= DATASET('~ifsp::hmw::bitcoin',rec,FLAT);
  // Filtragem do dataset de transacoes de bitcoin por um intervalo min/max
	myfiltereds := myds(out_val BETWEEN min_value AND max_value);
  // Retorno de 100 registros
	RETURN CHOOSEN(myfiltereds,100);
END;