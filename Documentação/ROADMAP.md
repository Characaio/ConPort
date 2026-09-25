# ConPort — Roadmap

Este documento registra a evolução planejada do ConPort.

O roadmap não representa necessariamente funcionalidades já existentes. Os itens são classificados de acordo com seu estado para evitar que planejamento seja confundido com implementação.

---

# 1. Status

|Status|Significado|
|---|---|
|🟢 Implementado|Funcionalidade existente no projeto|
|🟡 Em desenvolvimento|Funcionalidade sendo implementada ou integrada|
|🔵 Planejado|Funcionalidade definida para uma próxima etapa|
|⚪ Em discussão|Ideia que ainda pode sofrer alterações|
|🔴 Descartado|Ideia que deixou de fazer parte do planejamento|

---

# 2. Estado atual

## 🟢 Estrutura do Frontend

O frontend Flutter já possui uma estrutura de páginas, navegação, modelos e serviços.

Entre os componentes já trabalhados estão:

- Home;
    
- Reports;
    
- Perfil;
    
- Repositórios;
    
- Unidades;
    
- estrutura de navegação;
    
- serviços de comunicação com a API;
    
- modelos Dart.
    

---

## 🟢 Integração com API

O frontend possui integração com o backend através de serviços.

Entre os serviços já trabalhados estão:

- `ReportService`;
    
- `MissaoService`.
    

---

## 🟢 Sistema de Reports

O sistema de Reports já faz parte da aplicação.

Existe estrutura no frontend para:

- acessar Reports;
    
- buscar informações de Reports;
    
- buscar um Report completo através de um ID;
    
- apresentar as informações recebidas da API.
    

A integração ainda está passando por ajustes durante o desenvolvimento.

---

## 🟢 Sistema de Missões

O sistema de Missões já possui integração no frontend através de um serviço dedicado.

Durante a demonstração, alguns IDs de Missões podem ser definidos diretamente no código para simular o comportamento de uma integração completa com a API.

---

## 🟢 Backend

O backend Java e sua API fazem parte da estrutura atual do projeto.

A API é utilizada pelo frontend para obter e processar os dados necessários para as funcionalidades da aplicação.

---

## 🟢 PostgreSQL

O PostgreSQL faz parte da arquitetura atual do projeto e é utilizado como banco de dados.

---

# 3. Expansão atual

A próxima grande etapa do ConPort consiste em expandir significativamente as funcionalidades existentes.

A expansão está dividida em diferentes frentes.

---

# 4. Frontend

## 🔵 Revamp do Frontend

O frontend deverá passar por uma reformulação significativa.

### Objetivos

- melhorar a experiência do usuário;
    
- modernizar a interface;
    
- reorganizar componentes;
    
- melhorar a navegação;
    
- preparar a interface para os novos sistemas;
    
- tornar as informações mais claras.
    

O escopo visual e estrutural definitivo ainda poderá mudar durante o desenvolvimento.

---

# 5. Reports

## 🔵 Sistema de prioridade

Está planejada a adição de um grau de prioridade aos Reports.

A prioridade deverá permitir diferenciar Reports de acordo com sua importância.

### Questões ainda abertas

- quantidade de níveis;
    
- critérios de classificação;
    
- quem poderá alterar a prioridade;
    
- relação da prioridade com outros sistemas.
    

---

## 🔵 Informações de qualidade

Também está planejada uma expansão das informações internas associadas aos Reports.

A intenção é fornecer informações adicionais que permitam representar melhor a qualidade de um Report.

### Questões ainda abertas

- quais dados serão utilizados;
    
- como a qualidade será determinada;
    
- quais informações serão exibidas para o usuário;
    
- quais informações permanecerão internas;
    
- relação com reputação e confiabilidade.
    

---

# 6. Missões

## 🔵 Expansão do sistema de Missões

O sistema de Missões deverá receber novas possibilidades de interação.

A expansão tem como objetivo aumentar a participação dos usuários e tornar as Missões uma parte mais relevante da experiência do ConPort.

Possíveis áreas de expansão:

- novos tipos de Missão;
    
- novos objetivos;
    
- progressão;
    
- integração com reputação;
    
- integração com Badges.
    

A especificação definitiva ainda deverá ser definida.

---

# 7. Reputação

## 🔵 Sistema de Reputação

Está planejada a criação de um sistema de Reputação.

A ideia é utilizar a atividade e as contribuições dos usuários para construir uma representação de seu histórico dentro da plataforma.

O sistema de Reputação poderá funcionar como uma forma de progressão.

---

## ⚪ Confiabilidade

A confiabilidade está sendo considerada como parte do conceito de reputação.

Uma possibilidade discutida é utilizar a confiabilidade como uma espécie de classificação ou dimensão da reputação do usuário.

Entretanto, a estrutura definitiva ainda não está fechada.

Não está definido, neste momento, exatamente:

- como a confiabilidade será calculada;
    
- quais ações afetarão a confiabilidade;
    
- se haverá níveis;
    
- como a confiabilidade afetará outros sistemas.
    

---

# 8. Badges

## 🔵 Sistema de Badges

Está planejada a implementação de um sistema de Badges.

Os Badges deverão representar conquistas ou marcos alcançados pelos usuários.

O principal objetivo é aumentar o incentivo à interação com o ConPort.

---

## ⚪ Estrutura de Badges

Ainda estão em discussão:

- tipos de Badges;
    
- critérios de obtenção;
    
- categorias;
    
- níveis;
    
- raridade;
    
- relação com Missões;
    
- relação com Reputação;
    
- forma de exibição no perfil.
    

---

# 9. Integração entre os sistemas

Uma das metas da expansão é fazer com que as funcionalidades deixem de funcionar como sistemas isolados.

A direção atualmente discutida é semelhante a:

```text
             Usuário
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
    Reports  Missões   Outras
       │        │        │
       └────────┼────────┘
                ▼
           Reputação
                │
                ▼
             Badges
```

Esse diagrama representa apenas o conceito planejado.

As relações concretas entre os sistemas deverão ser definidas antes ou durante a implementação.

---

# 10. Qualidade e confiabilidade

Uma das possíveis evoluções do ConPort é tornar a qualidade das informações mais relevante para o funcionamento da plataforma.

A expansão dos Reports poderá fornecer dados adicionais que posteriormente sejam utilizados por outros sistemas.

Uma possível evolução seria:

```text
Report
  │
  ├── Prioridade
  │
  ├── Informações de qualidade
  │
  └── Histórico / interações
           │
           ▼
      Outros sistemas
           │
           └── Reputação / Confiabilidade
```

Esse fluxo ainda é conceitual e não representa uma implementação existente.

---

# 11. Gamificação

Os sistemas de Missões, Reputação e Badges fazem parte de uma direção de expansão voltada para aumentar a participação do usuário.

A ideia geral é criar um ciclo de interação:

```text
Usuário participa
       │
       ▼
Realiza atividades
       │
       ├──────────────┐
       ▼              ▼
    Missões        Reports
       │              │
       └──────┬───────┘
              ▼
          Progressão
              │
       ┌──────┴──────┐
       ▼             ▼
   Reputação       Badges
```

As regras definitivas desse ciclo ainda não foram implementadas.

---

# 12. Estabilização da integração

Antes ou durante a implementação da expansão, a integração atual deverá ser estabilizada.

Entre os pontos importantes estão:

- comunicação Flutter ↔ API;
    
- tratamento de respostas da API;
    
- tratamento de valores nulos;
    
- modelos;
    
- carregamento assíncrono;
    
- navegação;
    
- identificação das entidades através de IDs;
    
- tratamento de erros.
    

---

# 13. Documentação técnica

Após a estabilização das principais mudanças, a documentação deverá ser aprofundada.

### Planejado

- documentação completa da arquitetura;
    
- documentação dos endpoints da API;
    
- documentação dos modelos;
    
- documentação do banco de dados;
    
- documentação das regras de negócio;
    
- documentação das funcionalidades;
    
- registro de decisões arquiteturais.
    

---

# 14. Ordem geral de evolução

A ordem abaixo representa uma direção de trabalho e não uma obrigação rígida:

```text
Estado atual
    │
    ▼
Estabilização da integração
    │
    ▼
Revamp do Frontend
    │
    ▼
Evolução dos Reports
    │
    ├── Prioridade
    └── Qualidade
    │
    ▼
Expansão das Missões
    │
    ▼
Sistema de Reputação
    │
    ▼
Sistema de Badges
    │
    ▼
Integração entre sistemas
    │
    ▼
Estabilização
    │
    ▼
Documentação definitiva
```

Essa ordem poderá ser alterada conforme as necessidades técnicas do projeto.

---

# 15. Princípio do roadmap

O roadmap deve acompanhar o projeto, e não limitar o projeto.

Uma funcionalidade poderá ser:

```text
Planejada
    ↓
Redefinida
    ↓
Implementada
```

ou:

```text
Planejada
    ↓
Redefinida
    ↓
Descartada
```

Alterações no planejamento são esperadas durante o desenvolvimento.

O objetivo deste documento é manter uma visão compartilhada da direção do ConPort, e não congelar decisões que ainda estão sendo discutidas.

---

# 16. Próxima etapa

A próxima etapa consiste em transformar as ideias da expansão em especificações mais concretas.

Antes da implementação definitiva de cada sistema, devem ser definidos:

- objetivo;
    
- regras de negócio;
    
- entidades envolvidas;
    
- alterações necessárias no banco;
    
- endpoints necessários;
    
- alterações no frontend;
    
- dependências com outros sistemas;
    
- critérios para considerar a funcionalidade concluída.
    

Após essa definição, cada funcionalidade poderá receber sua própria documentação técnica.