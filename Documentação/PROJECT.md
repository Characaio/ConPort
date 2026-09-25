# ConPort

> Plataforma em desenvolvimento para centralização de Reports, Missões e outras formas de interação entre usuários, construída com uma arquitetura de frontend, backend e banco de dados.

---

## 1. Visão geral

O **ConPort** é um projeto de software desenvolvido com uma arquitetura dividida entre frontend, backend e banco de dados.

O projeto possui como elementos centrais os **Reports** e as **Missões**, além de funcionalidades relacionadas aos usuários e à navegação da aplicação.

Atualmente, o projeto encontra-se em uma fase de integração e evolução. A estrutura existente está sendo utilizada como base para uma expansão significativa da plataforma.

---

## 2. Objetivo

O ConPort tem como objetivo fornecer uma plataforma na qual os usuários possam interagir com informações e atividades disponibilizadas pelo sistema.

Entre os principais conceitos atualmente presentes no projeto estão:

- Reports;
    
- Missões;
    
- usuários;
    
- navegação entre diferentes áreas da aplicação;
    
- consulta de informações através da API.
    

A evolução planejada do projeto busca aumentar a participação dos usuários e criar mecanismos adicionais de progressão, confiabilidade e interação.

---

# 3. Estado atual do projeto

O projeto atualmente possui uma estrutura funcional dividida principalmente entre:

```text
ConPort
│
├── Frontend
│   └── Flutter / Dart
│
├── Backend
│   └── Java / API
│
└── Banco de dados
    └── PostgreSQL
```

O frontend e o backend estão sendo integrados progressivamente.

Parte das funcionalidades já possui comunicação com a API, enquanto outras ainda estão em processo de integração e estabilização.

---

# 4. Frontend

O frontend do ConPort é desenvolvido utilizando **Flutter e Dart**.

A aplicação possui uma estrutura de navegação entre diferentes páginas do sistema.

Entre as páginas/componentes já presentes na aplicação estão áreas relacionadas a:

- Home;
    
- Reports;
    
- Perfil;
    
- Repositórios;
    
- Unidades;
    
- Missões e outras funcionalidades relacionadas ao sistema.
    

A navegação é centralizada através da estrutura de carregamento de páginas do projeto.

---

## 4.1 Services

O frontend possui uma camada de serviços utilizada para comunicação com o backend.

Entre os serviços já trabalhados no projeto estão:

- `ReportService`;
    
- `MissaoService`.
    

Esses serviços são responsáveis por encapsular operações relacionadas às respectivas funcionalidades e realizar as chamadas à API.

---

## 4.2 Models

O frontend também possui modelos Dart utilizados para representar dados recebidos ou enviados pela aplicação.

Um exemplo presente na estrutura atual é o modelo de:

- `Mission`.
    

Os modelos são utilizados pelos serviços e pelas páginas para trabalhar com os dados da aplicação de maneira estruturada.

---

# 5. Backend

O backend do ConPort é desenvolvido em **Java** e fornece a API utilizada pelo frontend.

A API é responsável por disponibilizar os dados e operações necessários para que o frontend possa consumir as funcionalidades do sistema.

O backend possui funcionalidades relacionadas principalmente às entidades utilizadas pelo ConPort, incluindo Reports e Missões.

A estrutura exata dos endpoints e das regras de negócio deve ser considerada de acordo com a implementação atual da API.

---

# 6. Reports

Reports são uma das funcionalidades centrais do ConPort.

O frontend possui uma estrutura específica para consultar e exibir Reports através da API.

Também existe uma implementação de consulta de um Report completo através de seu identificador.

O fluxo geral utilizado pelo frontend é semelhante a:

```text
Página
  │
  ▼
ReportService
  │
  ▼
API
  │
  ▼
Backend
  │
  ▼
Dados do Report
  │
  ▼
Frontend
```

Durante o desenvolvimento, a integração entre a página de detalhes do Report e a API foi trabalhada para permitir a busca das informações completas de um Report.

---

# 7. Missões

Missões também fazem parte da estrutura atual do ConPort.

O frontend possui um serviço dedicado para comunicação com as funcionalidades de Missões.

Durante a fase de demonstração do projeto, determinadas Missões podem ser identificadas através de IDs definidos diretamente no código para simular o comportamento que posteriormente será realizado através da API real.

Esse comportamento é específico do estado de demonstração/desenvolvimento e não deve ser considerado necessariamente como a arquitetura definitiva do sistema.

---

# 8. Banco de dados

O projeto utiliza **PostgreSQL** como banco de dados.

O banco é responsável pela persistência das informações utilizadas pelo backend.

A estrutura do banco deve acompanhar as entidades e regras de negócio implementadas no backend.

Detalhes específicos de tabelas, colunas e relacionamentos devem ser documentados separadamente conforme o schema atual do banco seja estabilizado.

---

# 9. Comunicação entre as camadas

O fluxo geral do sistema é:

```text
┌───────────────────┐
│      Usuário      │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Flutter / Frontend│
└─────────┬─────────┘
          │
          │ HTTP / API
          ▼
┌───────────────────┐
│ Java / Backend    │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ PostgreSQL        │
└───────────────────┘
```

O frontend não deve ser responsável diretamente pelas regras de negócio ou pelo acesso ao banco.

A API atua como intermediária entre a aplicação cliente e os dados persistidos.

---

# 10. Estado de desenvolvimento

O ConPort ainda está em desenvolvimento.

Atualmente, uma parte importante do trabalho está concentrada na integração entre as camadas do sistema e na estabilização das funcionalidades existentes.

Entre os trabalhos já realizados estão:

- estruturação das páginas do frontend;
    
- estruturação da navegação;
    
- criação de modelos;
    
- criação de serviços para comunicação com a API;
    
- integração de Reports;
    
- integração de Missões;
    
- implementação e utilização da API;
    
- integração com PostgreSQL;
    
- execução e testes do frontend em diferentes ambientes.
    

Ainda existem pontos de integração e comportamento que estão sendo ajustados.

---

# 11. Demonstração

Durante o desenvolvimento e preparação das demonstrações, algumas funcionalidades podem utilizar valores definidos diretamente no código para representar comportamentos que posteriormente serão obtidos dinamicamente pela API.

Essas implementações devem ser entendidas como mecanismos de demonstração ou desenvolvimento e não necessariamente como a implementação final do sistema.

---

# 12. Expansão planejada

A estrutura atual do ConPort serve como base para uma expansão significativa.

Entre as principais ideias atualmente discutidas estão:

- revamp do Frontend;
    
- evolução dos Reports;
    
- sistema de prioridade para Reports;
    
- informações adicionais relacionadas à qualidade dos Reports;
    
- expansão do sistema de Missões;
    
- sistema de Reputação;
    
- sistema de confiabilidade;
    
- sistema de Badges;
    
- aumento da interação dos usuários com a plataforma.
    

Essas funcionalidades fazem parte do planejamento e **não devem ser consideradas funcionalidades já implementadas** enquanto não forem incorporadas ao sistema.

---

# 13. Filosofia de evolução

O ConPort está sendo desenvolvido de forma incremental.

A arquitetura atual deve servir como base para novas funcionalidades, mas decisões tomadas durante a expansão podem alterar estruturas existentes.

Por esse motivo, a documentação deve distinguir claramente:

- funcionalidades implementadas;
    
- funcionalidades em desenvolvimento;
    
- funcionalidades planejadas;
    
- ideias ainda em discussão.
    

---

# 14. Tecnologias atualmente utilizadas

## Frontend

- Flutter
    
- Dart
    
- Material Symbols
    

## Backend

- Java
    

## Banco de dados

- PostgreSQL
    

## Controle de versão

- Git
    

---

# 15. Estrutura de documentação

A documentação do projeto deverá ser organizada de forma progressiva.

```text
docs/
├── README.md
├── PROJECT.md
├── ROADMAP.md
│
├── architecture/
├── api/
├── database/
├── features/
├── development/
└── decisions/
```

O conteúdo desses diretórios deverá ser expandido conforme a arquitetura e as funcionalidades do ConPort forem estabilizadas.

---

# 16. Status deste documento

Este documento representa uma visão geral do estado atual conhecido do ConPort.

Detalhes de implementação devem ser mantidos em documentos técnicos específicos.

Quando uma funcionalidade planejada for implementada, ela deverá deixar de ser descrita apenas como planejamento e passar a ser documentada de acordo com seu comportamento real.