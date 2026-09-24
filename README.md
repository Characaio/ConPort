# ConPort

O **ConPort** é uma aplicação voltada ao monitoramento ambiental de Unidades de Conservação.

A plataforma reúne indicadores que representam o estado ambiental de uma unidade e permite que usuários registrem ocorrências ambientais observadas em seu entorno. Essas ocorrências são posteriormente analisadas por supervisores responsáveis pela unidade, criando um fluxo de participação da comunidade e acompanhamento da situação ambiental. Para incentivar o usuário a ser sustentável, a plataforma terá um sistema de missões e pequenas recompensas 

Projeto desenvolvido como protótipo acadêmico para demonstração de uma solução tecnológica aplicada ao monitoramento ambiental.

O projeto eventualmente será expandido para uma aplicação mais realista.

---

## Objetivo

O **ConPort** busca aproximar a população do monitoramento de áreas de preservação, permitindo que informações observadas no ambiente sejam registradas e encaminhadas para análise.

A aplicação foi pensada para representar um cenário próximo de uma utilização real, no qual:
- A Unidade de Conservação possui indicadores ambientais;
- Usuários podem registrar ocorrências observadas;
- As ocorrências passam por análise de supervisores;
- Os dados podem ser utilizados para acompanhar a situação da unidade;
- Informações ambientais podem ser apresentadas de forma simples e visual.

---

## Funcionalidades

#### Indicadores ambientais

A aplicação apresenta indicadores que representam diferentes aspectos da situação de uma Unidade de Conservação:
- Integridade Territorial
- Conectividade Ecológica
- Qualidade Ambiental
- Preservação Local
- Fiscalização
- Biodiversidade

Esses indicadores são baseados em informações cadastradas para cada unidade e fornecem uma visão geral de sua situação ambiental.

#### Registro de ocorrências

Usuários podem registrar situações atípicas observadas na unidade, incluindo:
- Queimadas
- Animais feridos
- Animais exóticos
- Poluição
- Desmatamento

Uma ocorrência pode conter informações como descrição, localização, data do ocorrido e imagens do ocorrido.

#### Análise de ocorrências

As ocorrências registradas ficam disponíveis para análise dos responsáveis pela **Unidade de Conservação**.

O sistema permite acompanhar o estado de uma ocorrência desde seu registro até sua análise.

#### Missões

O **ConPort** possui um sistema de missões voltado à participação dos usuários.

As missões representam ações relacionadas à preservação ambiental e podem conceder XP ao usuário após sua conclusão e validação.

O objetivo é incentivar a participação dos usuários em ações relacionadas à preservação ambiental.

---

## Arquitetura

O projeto é organizado em três partes principais:

```text
ConPort/
├── Backend/
├── FrontEnd/
└── Documentação/
```

#### Backend

Responsável pela **API**, **regras de negócio**, **persistência dos dados** e **comunicação com o banco de dados**.

O backend disponibiliza uma **API REST** que recebe e processa as requisições realizadas pelo frontend, sendo responsável pelo **gerenciamento das informações** e **aplicação das regras do sistema**.

##### Tecnologias principais:
- **Java**
- **Spring Boot**
- **Spring Data JPA**
- **PostgreSQL**
- **Maven**
- **Docker**

#### Frontend

Responsável pela interface utilizada pelos usuários para consultar informações das Unidades de Conservação, visualizar indicadores, registrar ocorrências e interagir com as funcionalidades da plataforma.

O frontend realiza a comunicação com o backend através da API REST e apresenta as informações recebidas de forma visual para o usuário.

##### Tecnologias principais:
- **Flutter**
- **Dart**

#### Comunicação

A comunicação entre o frontend e o backend ocorre através de uma **API REST**, utilizando **requisições HTTP** e dados no **formato JSON**.

De forma simplificada:

```text
Usuário
   │
   ▼
Frontend
   │
   │ HTTP / JSON
   ▼
API REST
   │
   ▼
Backend
   │
   ▼
PostgreSQL
```

#### Documentação

Contém materiais utilizados para **descrever o projeto**, sua **arquitetura**, **funcionamento** e demais informações relevantes para o desenvolvimento.


A documentação detalhada dos **endpoints** pode ser encontrada em:
- `Documentação/Rotas.md`

A documentação detalhada sobre a **modelagem das entidades e modelos** pode ser encontrada em:
- `Documentação/Modelagem.md`

A documentação sobre os **requisitos** pode ser encontrada em:
- `Documentação/Requisitos.md`

A documentação sobre o **fluxo de usuário** pode ser encontrada em:
- `Documentação/FluxoDoUsuario.md`

---

## Tecnologias

#### Frontend
- **Flutter**
- **Dart**

#### Backend
- **Java**
- **Spring Boot**
- **Spring Data JPA**
- **Maven**

#### Banco de dados e infraestrutura
- **PostgreSQL**
- **Docker**
- **Docker Compose**

#### Comunicação
- **API REST**
- **JSON**

---

## Executando o projeto

#### Pré-requisitos

Antes de executar o projeto, certifique-se de possuir:
- Java
- Maven
- Docker
- PostgreSQL, caso não utilize o ambiente Docker disponibilizado pelo projeto
- Flutter, para executar o frontend

#### Clone o repositório

```cmd
git clone https://github.com/Characaio/ConPort.git
cd ConPort
```

##### Backend

Entre no diretório do backend:
```cmd
cd Backend
```

Execute a aplicação utilizando Maven:
```cmd
./mvnw spring-boot:run
```

No Windows:
```cmd
.\mvnw.cmd spring-boot:run
```

##### Frontend

Em outro terminal:
```cmd
cd FrontEnd
flutter pub get
flutter run
```

A configuração do banco de dados e demais variáveis necessárias para execução devem ser definidas conforme a configuração presente no projeto.

---

#### Docker

O projeto possui suporte à execução através de containers, permitindo que a aplicação e seus serviços sejam executados em um ambiente reproduzível.

Para iniciar os serviços:
```cmd
docker compose up --build
```

Para encerrar os containers:
```cmd
docker compose down
```

---

#### API

O backend disponibiliza uma **API REST** responsável pela comunicação entre o frontend e os dados da aplicação.

Entre os principais recursos do sistema estão:

```text
Unidades
├── Dados da unidade
├── Indicadores ambientais
└── Ocorrências

Ocorrências
├── Registro
├── Consulta
├── Análise
└── Atualização de status

Missões
├── Tipo
├── Disponibilização
├── Conclusão
└── Recompensa
```


---

### Status do projeto

#### Em desenvolvimento

O **ConPort** está sendo desenvolvido como um **protótipo funcional**. Algumas funcionalidades e integrações ainda **podem sofrer alterações durante o desenvolvimento**.

---

## Contexto acadêmico

O projeto foi desenvolvido no contexto do curso técnico de Desenvolvimento de Sistemas, tendo como objetivo explorar a aplicação de tecnologias de desenvolvimento de software em um problema relacionado ao monitoramento e preservação ambiental.

Além da implementação do sistema, o projeto busca demonstrar conceitos de:
- desenvolvimento de APIs REST;
- desenvolvimento de aplicações multiplataforma;
- persistência de dados;
- desenvolvimento de interfaces;
- modelagem de sistemas;
- arquitetura de software;
- containerização;
- integração entre aplicações.

---

## Equipe

Integrantes:
- Evelyn: Frontend
- Flávio: Frontend
- Keirrisson: Integração e pesquisa
- Caio: Backend e infraestrutura 

## Agradecimentos especiais
- Victor: Ideia de missões, moedas e sequência
