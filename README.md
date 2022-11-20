# Trabalho_D2TEC_Final
Trabalho final da disciplina D2TEC - Tecnologias de Big Data do curso de Especialização em Ciência de Dados do IFSP Campinas.

# Aluno: 
- Hugo Martinelli Watanuki

# ETL de dados blockchain usando infraestrutura Azure
O objetivo deste repositório é fornecer um conjunto de instruções, arquivos de configuração e códigos para a criação de uma infraestutrura de processamento e análise de dados brutos de blockchain usando recursos da Azure. 

A demonstração do passo a passo completo para a construção dessa infraestrutura está disponível aqui: https://youtu.be/vlRkAsbyuNI

# a) Introdução
O problema principal a ser endereçado por esse trabalho diz respeito à extração e estruturação de dados de transações de bitcoin a partir de arquivos binários de blockchain. 

O objetivo é extrair e estruturar as informações de transações de bitcoin a partir da blockchain de maneira eficiente para posterior análise dos padrões temporais das transações por carteira de bitcoin com o intuito final de embasar decisões de identificação de fraudes. 

Em virtude do volume e do formato dos dados brutos, optou-se por utilizar uma estratégia de ETL apoiada em processamento paralelo e distribuido por meio de um paradigma de microserviços em nuvem.

# b) Descrição dos dados
A base de dados utilizada no trabalho corresponde ao blockchain de bitcoin (~7 GB). O blockchain, por sua vez, é armazenado em arquivos binários blk.dat localizados nos nós computacionais pertencentes à rede de bitcoin (https://bitcoin.org/en/download). Cada arquivo blk.dat (~128 MB) contém blocos de dados brutos que são recebidos pelo nó da rede de bitcoin e ficam armazenados no diretório ~/.bitcoin/blocks/:

![image](https://user-images.githubusercontent.com/50485300/202885667-15e9e589-e7bb-4cf2-802c-a0a7bf1f9a4c.png)

Os dados contidos nos arquivos blk.dat estão armazenados em formato binário, conforme ilustrado abaixo nos primeiros 293 bytes do arquivo blk0000.dat:

![image](https://user-images.githubusercontent.com/50485300/202885772-4c03915e-2fff-41ac-b1ee-e9849c952e6a.png)

E cada bloco constituinte do arquivo blk.dat possui uma estrutura binária que pode ser dividida em cinco partes principais:

![image](https://user-images.githubusercontent.com/50485300/202885824-5bf8dde3-285d-4fe3-853b-f5c93d1647a5.png)

- Magic byte: determina a posição inicial e final de cada bloco
- Size: tamanho do bloco
- Block header: contém metadados diversas, tais como versão do bloco (4 bytes), hash do bloco anterior (32 bytes), hash de todas as transações do bloco (32 bytes), hora em que o bloco foi minerado (4 bytes), o alvo da mineraçao (4 bytes) e o campo para mineração (4 bytes).
- Tx count: número de transações existentes no bloco
- Transaction data: hash das informações das transações

Para as análises apresentadas a seguir foram selecionados 3 arquivos blk.dat, os quais estão disponibilizados aqui:  https://github.com/HWatanuki/Trabalho_D2TEC/tree/main/Datasets

# c) Workflow
A solução criada para a extração e estruturação dos dados de blockchain utilizou os seguintes componentes principais:
- Azure File Shares: https://azure.microsoft.com/en-us/products/storage/files/#overview
- Azure Kubernetes Service (AKS): https://azure.microsoft.com/en-us/products/kubernetes-service/
- High Performance Computing Cluster (HPCC Systems): https://hpccsystems.com/

O diagrama de arquitetura Azure implementada é apresentado abaixo:

![image](https://user-images.githubusercontent.com/50485300/200107439-bf0d4e86-3b02-4c0d-ab3d-927c3134d172.png)


# d) Infraestrutura
A infrastrutura foi criada na região us-east-2 e envolveu os seguintes recursos:
- 1 usuário Identity and Access Management (IAM) com permissões para administrar clusters EKS (https://docs.aws.amazon.com/eks/latest/userguide/security-iam.html)
- 1 Virtual Private Cloud (VPC) padrão da AWS com subnets públicas em cada zona de disponibilidade (https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html)
- 4 nós t3.medium com 2 vCPUs e 4 GiB de memória (https://aws.amazon.com/ec2/instance-types/t3/)
- 5 volumes de 1 GB cada para armazenamento de dados no EFS

# d) Scripts de consulta dos dados

O tratamento e análise dos dados objetivou proporcionar a um motorista de taxi da cidade de NY insumos para uma estratégia de trabalho. 
Para isso, uma vez tratados os dados, os mesmos serviram para um entendimento sobre o padrao das viagens ao longo dos dias e horas do mes, bem como as regioes com as viagens e gorjetas mais elevadas. 
Por fim, uma funcao foi elaborada com base nos dados historicos medios para permitir ao motorista estimar o valor, duracao e distancia de uma viagem com base no local de embarque/desembarque, dia e hora de inicio da viagem. 

Os códigos utilizados para tratament e consultas dos dados estão disponíveis aqui: https://github.com/HWatanuki/Trabalho_D2TEC/tree/main/Codigos

A demonstração das analises está disponível aqui: https://youtu.be/Kx29WY3P9MY

1) Limpeza e padronização dos dados com o objetivo de tratar os campos de data e hora, bem como alterar os tipos dos campos da tabela:

 ![image](https://user-images.githubusercontent.com/50485300/200211343-a1dfb689-12ad-4c3a-9d1e-9f440507fc24.png)
 
 
 O schema do dataset de viagens possui a seguinte estrutura:

    STRING VendorID; // codigo indicando a companhia associada a viagem
    STRING tpep_pickup_datetime; // data e hora do embarque
    STRING tpep_dropoff_datetime; // data e hora do desembarque
    STRING passenger_count; // numero de passageiros
    STRING trip_distance; // distancia da viagem
    STRING RatecodeID; // codigo final de cobranca da viagem
    STRING store_and_fwd_flag; // codigo que indica se os dados da viagem foram gravados no veiculo por falta de conexao
    STRING PULocationID; // codigo do local de embarque
    STRING DOLocationID; // codigo do local de desembarque
    STRING payment_type; // tipo do pagamento (dinheiro,cartao,etc)
    STRING fare_amount; // valor da corrida no taximetro
    STRING extra;  // tarifas extras nos horarios de pico
    STRING mta_tax; // imposto extra em funcao da taxa do taximetro
    STRING tip_amount; // valor da gorjeta
    STRING tolls_amount; // valor dos pedagios
    STRING improvement_surcharge; // taxa compensatoria para viagens curtas
    STRING total_amount; // valor total recebido do passageiro

Visualizacao do dataset de viagens bruto

![image](https://user-images.githubusercontent.com/50485300/200210322-6899b9c8-8b80-4789-822e-d1e9237e0769.png)


2) JOIN com a tabela de bairros de NY com o intuito de substituir os codigos de embarque e desembarque pelos nomes das regioes:

![image](https://user-images.githubusercontent.com/50485300/200211447-d05563d9-a49d-4a4e-9d67-100539bac8ad.png)

3) Analise da porcentagem de viagens cobertas pelo dataset em relacao a todos os itinerarios possiveis na cidade de NY:

![image](https://user-images.githubusercontent.com/50485300/200214452-f2d089a3-0c69-48ec-bc86-160e8b6d5999.png) (menos de 0.01%)

4) Analise da concentracao de viagens por companhia com o intuito de orientar o motorista sobre eventual dominio de mercado:

![image](https://user-images.githubusercontent.com/50485300/200214529-03e22a21-0b17-4d23-a8c2-dc837ab26168.png)

5) Analise dos trajetos mais frequentes ao longo do mes como um indicativo de regiao com alta demanda de servico de taxi:

![image](https://user-images.githubusercontent.com/50485300/200214601-a6eb9212-5ec7-454b-b65c-97d4ecbd7d79.png)

6) Distribuicao das viagens ao longo dos dias do mes como um indicativo dos dias com maior demanda de servico de taxi:

![image](https://user-images.githubusercontent.com/50485300/200215596-ce12b6a9-03c6-4bd8-bd27-f4360a6d6b4d.png)

7) Distribuicao das viagens ao longo das horas do dia como um indicativo das horas com maior demanda de servico de taxi:

![image](https://user-images.githubusercontent.com/50485300/200215638-6180e890-52a7-4ace-afab-d9738bdcf56e.png)

8) Analise dos trajetos com viagens com valor medio mais elevado:

![image](https://user-images.githubusercontent.com/50485300/200214935-c1b69091-f313-43ce-8086-fc54b0c238e3.png)

9) Analise dos valores das gorjetas por regiao de embarque:

![image](https://user-images.githubusercontent.com/50485300/200215040-d82564eb-452a-411b-b78f-91e93794add2.png)

10) Analise da correlacao do valor da gorjeta com o valor da distancia e do custo da viagem

![image](https://user-images.githubusercontent.com/50485300/200215104-dbde65c0-b4d6-4f94-aa2c-d4da612962fc.png)

11) Funcao para estimativa dos valores medios de cada viagem com base nos locais de embarque/desembarque, dia da semana e hora do dia do embarque:

![image](https://user-images.githubusercontent.com/50485300/200215536-9a626b31-75f3-43ac-8dce-ea30bdff4573.png)


Resultado de simulacao de uma corrida entre dois aeroportos de NY num domingo às 5 am:

![image](https://user-images.githubusercontent.com/50485300/200215215-f888c0d5-c0af-4593-8ef2-4c052a240594.png)


# e) Visualizações

Os resultados das consultas cujas visualizaçoes parecem ser mais relevantes estão listadas abaixo:

-Distribuicao temporal das viagens ao longo dos dias do mes (picos no meio da semana e vales nos finais de semana e feriados):

![image](https://user-images.githubusercontent.com/50485300/200216026-73417789-515a-4c6c-9188-4e8abe364027.png)

- Distribuicao temporal das viagens ao longo das horas do dia (pico nos horarios ao final do dia e vale na madrugada):

![image](https://user-images.githubusercontent.com/50485300/200216212-72830814-85fb-49e4-98c0-12d61457207d.png)

- Concentracao dos locais de embarque com valor médio de gorjeta por viagem mais elevado (aeroportos de JFK e LaGuardia):

![image](https://user-images.githubusercontent.com/50485300/200216421-2d8fedd8-bd32-435e-b66d-900842431183.png)
