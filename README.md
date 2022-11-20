# Trabalho_D2TEC_Final
Trabalho final da disciplina D2TEC - Tecnologias de Big Data do curso de Especialização em Ciência de Dados do IFSP Campinas.

# Aluno: 
- Hugo Martinelli Watanuki

# ETL de dados blockchain usando infraestrutura Azure
O objetivo deste repositório é fornecer um conjunto de instruções e códigos para a criação de uma infraestutrura de processamento e análise de dados brutos de blockchain usando recursos de IaC (Infrasctruture as a Code) na Azure. 

A demonstração do passo a passo completo para a construção dessa infraestrutura está disponível aqui: https://youtu.be/vlRkAsbyuNI

# a) Introdução
O problema principal a ser endereçado por esse trabalho diz respeito à extração e estruturação de dados de transações de bitcoin a partir de arquivos binários de blockchain. 

O objetivo é extrair e estruturar as informações de transações de bitcoin a partir da blockchain para seu posterior uso em trabalho futuro,o qual envolverá a análise dos padrões temporais das transações por carteira de bitcoin com o intuito de identificação de fraudes. O foco nesse momento é estabelecer a infraestrutura capaz de fazer a extração e estruturação das informações de transações de bitcoin de maneira eficiente e automatizada.

Em virtude do volume e do formato dos dados brutos, optou-se por utilizar uma estratégia de ETL apoiada em processamento paralelo e distribuido por meio de um paradigma de microserviços em nuvem. A estratégia também focalizou a eficiência da implementação da infraestrutura por meio de conceitos de Infrastructure as a Code (IaC).

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

Para os tratamentos e análises apresentados a seguir foram selecionados 2 arquivos blk.dat apenas para efeito de ilustração, os quais contém pouco mais de 5 milhões de transações. Os arquivos blk.dat utilizados estão disponibilizados aqui: https://github.com/HWatanuki/Trabalho_D2TEC_Final/tree/main/Descricao_Dados

# c) Workflow
A solução criada para a extração e estruturação dos dados de blockchain utilizou os seguintes componentes principais:
- Azure Kubernetes Service (AKS): https://azure.microsoft.com/en-us/products/kubernetes-service/
- High Performance Computing Cluster (HPCC Systems): https://hpccsystems.com/

O diagrama de arquitetura é apresentado abaixo:

![image](https://user-images.githubusercontent.com/50485300/200107439-bf0d4e86-3b02-4c0d-ab3d-927c3134d172.png)


# d) Infraestrutura
A infrastrutura foi criada na região EastUS2 e envolveu os seguintes recursos:

- 1 Virtual Network (vnet) padrão da Azure com subnets pública e privada (https://azure.microsoft.com/en-us/products/virtual-network/):

![image](https://user-images.githubusercontent.com/50485300/202887061-5d422204-c18e-4a51-9e85-128acc07fa0b.png)

- 5 file shares com storage general-purpose V2 totalizando 180 GB para armazenamento de dados com redundância local (https://azure.microsoft.com/en-us/products/storage/files/#overview):

![image](https://user-images.githubusercontent.com/50485300/202886874-6e4a6598-1806-4059-87d3-880521da2648.png)

- 2 instâncias Standard_B2s com 2 vCPUs e 4 GiB de memória para processamento dos dados (https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable):

![image](https://user-images.githubusercontent.com/50485300/202887346-0372deda-f055-4020-a037-09f821767330.png)

- 1 instância Standard_D2_v4 com 2 vCPUs e 8 GiB de memória para gerenciamento do cluster (https://learn.microsoft.com/en-us/azure/virtual-machines/dv4-dsv4-series):
  
![image](https://user-images.githubusercontent.com/50485300/202887359-4d4e5ff9-948b-4f77-8040-c55981f8d481.png)

# e) Setup
Para a implementação da infraestrutura optou-se por utilizar um paradigma IaC por meio do Terraform (https://www.terraform.io/). Os códigos Terraform utilizados estão disponíveis em https://github.com/HWatanuki/Trabalho_D2TEC_Final/tree/main/Setup e foram divididos em dois módulos principais: 
 1) Módulo de implementação dos Azure File Shares: https://github.com/HWatanuki/Trabalho_D2TEC_Final/tree/main/Setup/storage
 2) Módulo de implementação do AKS/HPCC Systems: https://github.com/HWatanuki/Trabalho_D2TEC_Final/tree/main/Setup/aks

# f) Pipeline de dados
O tratamento dos dados objetivou extrair e estruturar os dados primários de transações bitcoin presentes nos blocos dos arquivos blk.dat.
Para isso, os arquivos blk.dat foram importados na plataforma HPCC Systems como Blob's (binary large object) e um código python foi utilizado como base para extrair e estruturar os dados primários contidos nos arquivos blk.dat.

Os códigos utilizados para tratamento dos dados estão disponíveis aqui: https://github.com/HWatanuki/Trabalho_D2TEC_Final/tree/main/Pipeline_Dados

1) Importação dos arquivos blk.dat como blob:

![image](https://user-images.githubusercontent.com/50485300/202888563-0815b437-b579-4e9f-b05a-dc8f021ee3a9.png)

Visualizacao do blob em formato hexadecimal:

![image](https://user-images.githubusercontent.com/50485300/202888276-0b39553c-e0c2-4867-89d2-5b8a5783a636.png)

2) Extração dos dados primários do blob e estruturação em formato relacional:

 O schema do dataset de transações de bitcoin a ser obtido do blob possui a seguinte estrutura:

    STRING  tx_hash;   // hash da transacao
    INTEGER in_index;  // indice da transacao
    STRING  in_hash;   // hash do input da transacao
    INTEGER out_index; // indice do output da transacao
    STRING  out_addr;  // endereco do output da transacao
    INTEGER out_val;   // valor em bitcoin negociado
    STRING  timestamp; // data da transacao

Visualização do dataset estruturado

![image](https://user-images.githubusercontent.com/50485300/202888627-7bc61878-72f9-48a6-b06b-b48adac9fa7d.png)

3) Visualização das 10 maiores transações de bitcoin contidas no dataset:

![image](https://user-images.githubusercontent.com/50485300/202889051-2d77eff2-0c8e-40ea-95d1-b205aa4fcf43.png)

4) Visualização dos 10 endereços que mais receberam transações de bitcoin

![image](https://user-images.githubusercontent.com/50485300/202889490-f1cfd324-badc-4edc-9e67-3168e36b5182.png)

5) Endpoint para consulta das transações dentro de valores min/max: http://20.7.99.254:8002/WsEcl/forms/ecl/query/hthor/search_transactions

![image](https://user-images.githubusercontent.com/50485300/202890999-799b578c-df9b-499d-b574-fd60b5368d53.png)

![image](https://user-images.githubusercontent.com/50485300/202890959-d9608090-3616-4dc8-8703-045645c7b2ce.png)

# g) Cleanup
Como a implementação da infraestrutura foi feita via Terraform, para a remoção dos recursos utilizados na Azure basta utilizar o comando "terraform destroy" a partir de cada subdiretório que contém os códigos para implementaçao do storage e do AKS.

# f) Referências

Walker, Greg. "How Does Bitcoin Work". Disponível em: https://learnmeabitcoin.com/
