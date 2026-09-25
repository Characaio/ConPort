
## 1. Visão geral
>	Toda a aplicação se baseia em 2 pilares principais, o **FrontEnd** e o **BackEnd**, ambos se comunicam via requisições HTTP pela API fornecida pelo BackEnd


# 2. Fluxo de Operações

## 2.1 Reports
Essa seção irá explicar o fluxo de operações dos reports
#### Consultar Report Resumido

Esta funcionalidade consulta as informações necessárias para apresentar um Report de forma resumida ao usuário.

```text
Usuário
  ↓
Usuario abre a tela de seus reports
  ↓
ReportService faz um pedido para a API pegar seus reports
  ↓
Backend recebe, trata, processa o pedido
  ↓
Backend Consulta o banco de dados
  ↓
PostgreSQL pega os dados
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna resposta ao FrontEnd
  ↓
ReportService recebe as informações e processa a informações 
  ↓
Tela de reports do usuário 
  ↓
Usuário visualiza as informações básicas de seu report
```
#### Pegar Report Expandido 

Esta funcionalidade consulta as informações necessárias para apresentar um Report de forma Expandida ao usuário em uma tela dedicada.

```text
Usuário
  ↓
Tela dos Reports do usuário 
  ↓
Usuário seleciona um Report
  ↓
ReportService solicita o report para a API
  ↓
API recebe a requisição 
  ↓
Backend trata, processa e prepara o pedido
  ↓
Backend consulta o banco de dados
  ↓
PostgreSQL pega os dados
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna resposta ao FrontEnd
  ↓
ReportService recebe e peocessa as informações 
  ↓
Tela dedicada do Report
  ↓
Usuário visualiza as informações completas do Report
```
#### Criar Report 

Esta seção descreve os principais fluxos de operação relacionados
a Reports, desde a interação do usuário com o FrontEnd até o
processamento e persistência dos dados no Backend.

```text
Usuário
  ↓
Tela de criação de report
  ↓
Usuário preenche um formulário com as informações necessárias 
  ↓
ReportService trata essas informações e faz um pedido para a API
  ↓
Backend trata o pedido
  ↓
Backend processa o pedido e faz o pedido
  ↓
PostgreSQL salva os dado
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna a resposta HTTP
  ↓
ReportService recebe a resposta
  ↓
Aviso simples ao usuário sobre como foi o resultado de seu report com base na resposta HTTP
  ↓
Usuario retorna a Tela principal 
```

## 2.2 Missoes

#### Consultar quantidade de missões ativas
Essa funcionalidade será realizada no momento que o usuario abrir o aplicativo e irá rodar no fundo do aplicativo, ela irá retornar a quantidade de missoes ativas no momento, caso seja 3 ou mais, nada acontece, mas caso seja 0, a funcionalidade de gerar missões será realizada

```text
Usuário
  ↓
Usuario Abre aplicaivo
  ↓
Missões service solicita a checagem
  ↓
Api recebe a requisição 
  ↓
Backend prepara o pedido de contagem
  ↓
PostgreSQL faz a consulta e retorna a contagem
  ↓
Backend prepara a resposta de API
  ↓
Missoes service recebe a quantidade e caso seja 0, Gera novas missões, caso não, nada acontece 
```
#### Gerar nova missões 
Essa funcionalidade apenas será realizada caso a contagem de missões ativas seja 0

```text
Usuário
  ↓
Funcionalidade de Contagem de missões  retorna True
  ↓
Missões service solicita a criação de novas missões
  ↓
Api recebe a requisição 
  ↓
Backend cria as missões semi aleatorizadas com base em um conjunto de dados pré definidos
  ↓
Backend prepara os dados gerados para serem salvos no banco
  ↓
PostgreSQL salva os dados
  ↓
Backend faz reposta da API
  ↓
API responde para o usuário que suas missões foram geradas
```
#### Consultar missões ativas
Essa funcionalidade irá acontecer quando a area de missão for carregada, ela irá pegar todas as informações sobre as missões ativas

```text
Usuário
  ↓
Area de Missão foi carregada
  ↓
ReportService solicita as missões ativas do usuario
  ↓
API recebe a requisição 
  ↓
Backend trata, processa e prepara o pedido
  ↓
Backend consulta o banco de dados
  ↓
PostgreSQL pega os dados da missão
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna as missões ao FrontEnd
  ↓
ReportService recebe e peocessa as informações 
  ↓
Area de missão fica com seus dados prontos para ser aberta
```

#### Progredir missão 
Essa funcionalidade representa qualquer progresso da missão para o cumprimento de sua meta

```text
Usuario
  ↓
Usuario acessa sua missão e faz um progresso
  ↓
Missao Service trata as informações passadas e decide quanto progresso foi feito e faz a requisição
  ↓
Backend recebe e trata a requisição
  ↓
Caso o progresso bata a meta, a missão vira concluida
  ↓
PostgreSQL os novos dados são salvos no banco
  ↓
Backend retorna uma resposta HTTP referente ao resultado desse processo
  ↓
Misssao service recebe essa resposta, e caso seja uma resposta 20X, a missão concluida é refrescada com suas novas informações
```


## 2.3 Unidades
Essa seção irá explicar todas operações de uma unidade de conservação

#### Consultar Status Principais
Esta funcionalidade serve para pegar os principais dados da unidade e mostra ao usuario

```text
Usuário
  ↓
Usuario abre a tela principal
  ↓
Unidade Service faz um pedido para a API pegar as informações da unidade
  ↓
Backend recebe, trata, processa o pedido
  ↓
Backend Consulta o banco de dados
  ↓
PostgreSQL pega os dados
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna resposta ao FrontEnd
  ↓
Unidade Service recebe as informações e processa a informações 
  ↓
Tela principal da unidade
  ↓
Usuário visualiza as informações Principais da unidade
```


#### Consultar Status gerais
Esta funcionalidade serve para pegar todos os dados da unidade e mostra ao usuario

```text
Usuário
  ↓
Usuario abre a tela de mais informações da unidade
  ↓
Unidade Service faz um pedido para a API pegar todas informações da unidade
  ↓
Backend recebe, trata, processa o pedido
  ↓
Backend Consulta o banco de dados
  ↓
PostgreSQL pega os dados
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna resposta ao FrontEnd
  ↓
Unidade Service recebe as informações e processa a informações 
  ↓
Tela de mais informações da unidade
  ↓
Usuário visualiza todas as informações da unidade
```


#### Pegar reports de uma unidade
Esta funcionalidade serve para pegar todos reports atrelados a unidade

```text
Usuário
  ↓
Usuario abre a tela principal
  ↓
Unidade Service faz um pedido para a API pegar as informações da unidade
  ↓
Backend recebe, trata, processa o pedido
  ↓
Backend Consulta o banco de dados
  ↓
PostgreSQL pega os dados
  ↓
Backend processa os dados e prepara a resposta 
  ↓
API retorna resposta ao FrontEnd
  ↓
Unidade Service recebe as informações e processa a informações 
  ↓
Tela principal da unidade
  ↓
Usuário visualiza as informações Principais da unidade
```


## 3. Responsabilidade de cada camada

FrontEnd -> Interface e interação do usuario
BackEnd -> Regras de negocio e API
Banco de dados -> Persistência dos dados
