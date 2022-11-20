// Declaracao do schema do objeto binario bruto
rawrec := RECORD
    DATA1 block;
END;

// Declaracao do objeto binario bruto 
rawds := DATASET('~ifsp::hmw::bitcoinraw',rawrec,FLAT);

// Visualizaçao do objeto binario bruto (HEX)
OUTPUT(rawds,NAMED('Hex_Data'));
COUNT(rawds);