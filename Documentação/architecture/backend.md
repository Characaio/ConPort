# Arquitetura do Backend

## 1. Responsabilidade do Backend
O backend tem como principal responsabilidade aplicar a regra de negocio, lidar com o tratamento e persistencia de dados. O backend disponibiliza uma API para permitir o acesso as informações

## 2. Estrutura interna
A estrutura interna do backend segue o seguinte diagrama:
```text
BackEnd/
├── Controllers/
│   └── ...
├── DTOs/
│   ├── Request/
│   │   └── ...
│   └── Response/
│       └── ...
├── Exceptions/
│   └── ...
├── Models/
│   ├── enum/
│   │   └── ...
│   └── ...
├── Repositories/
│   ├── ...
│   └── ...
├── Services/
│   └── ...
└── Configs/
    └── ...
```

## 3. Fluxo de uma requisição
Toda requisição recebida pela API é direcionada ao Controller correspondente, que encaminha seu processamento para a camada de Service. Quando necessario, o Service utiliza os Repositories para consultar ou persistir dados no banco de dados.

Todo informação que entra ou sai da API retorna em formato de JSON.

Rotas que retornam uma resposta é baseada em um DTO da pasta DTOs/Response
Rotas que recebem uma request é baseada em um DTO da pasta DTOs/Request

Os dados retornados seguem o fluxo inverso da requisição, passando novamente pelas camdas responsaveis até serem retornados ao usuario pela API.
## 4. Camada de API
#### 4.1 Controller
Essa camada representa o ponto de entrada das requisições HTTP da API, ela recebe requisições e manda resposta em formato JSON. Essas requisições são processadas e tratadas na camada de Service.

#### 4.2 Service
Essa camada é a camada onde as regras de negócio é aplicada, ela pode chamar metodos do repository para pegar dados do banco de dados. Com o acesso a todas essas informações, ela irá tratar e processar qualquer requisição passada pelo Controller

#### 4.3 Repository
Essa camada é a mais proxima do Banco de dados, ela tem metodos e cuida de toda query SQL feita ao banco de dados

## 5. Regras de negócio

As regras de negócio listam as condições e comportamentos que o ConPort precisa respeitar, independentemente de como o código será implementado. Essas regras orientam como a aplicação deve tratar, validar e gerenciar seus dados e operações.
#### 5.1 Usuários
Regras de negócio dos usuários:
- Um usuário pode realizar suas missões.
- Um usuário pode visualizar suas próprias informações.
- Um usuário pode visualizar seus Reports.
- Um usuário pode criar um Report.
- Um usuário será automaticamente associado à unidade de conservação mais próxima com base em sua localização atual. Essa associação permite ao usuário acessar rapidamente as informações da unidade.
- Um usuário poderá visualizar informações de outras unidades.
- Um usuário poderá criar um Report somente quando estiver dentro do raio definido da unidade de conservação e associado a ela.
- Todo usuário terá um sistema interno de reputação.
- Um usuário poderá ser classificado como Usuário Sustentável ao atingir o nível necessário.
- Usuários Sustentáveis terão acesso a privilégios específicos.
- Um Usuário Sustentável poderá solicitar a recompensa associada à sua classificação.
- Um Usuário Sustentável poderá utilizar moedas obtidas pela realização de missões para adquirir itens ou recompensas disponíveis no sistema.
#### 5.2 Unidades
Regras de negócio das unidades:
- Uma unidade terá parte de seus dados obtidos por órgãos públicos.
- Dados que não possam ser obtidos por fontes públicas serão cadastrados pela própria unidade.
- Reports tratados pela unidade serão disponibilizados em uma área de informações avançadas da unidade.
#### 5.3 Reports
Regras de negócio dos Reports:
- Um Report não tratado poderá ser visualizado apenas pelo usuário responsável por sua criação e por Supervisores.
- Um Report tratado poderá ser visualizado por qualquer usuário.
- Todo Report estará associado a uma unidade.
- Todo Report estará associado a um usuário.
- Todo Report que passar pela análise deverá estar associado ao Supervisor responsável pela análise.
- Todo Report rejeitado deverá possuir uma mensagem do Supervisor informando o motivo da rejeição.
- Todo Report possuirá um nível de prioridade definido pelo usuário responsável por sua criação.
- As prioridades disponíveis serão: Baixa, Média, Alta e Alarmante.
- A prioridade Alarmante estará disponível apenas para usuários com nível de confiabilidade ou reputação definido pelo sistema.
- A confiabilidade de um Report será determinada com base na reputação do usuário responsável por sua criação.
- Um Report aceito e tratado após a análise de um Supervisor contribuirá ligeiramente para a reputação do usuário que o criou.
- O envio recorrente de Reports considerados falsos poderá resultar em restrições à criação de novos Reports. Em casos recorrentes ou graves, o usuário poderá sofrer uma penalidade mais severa, conforme as regras de moderação definidas pelo sistema.
#### 5.4 Missões
Regras de negócio das missões:
- As missões ativas do usuário serão disponibilizadas em uma área dedicada.
- Um usuário poderá realizar apenas suas próprias missões ativas.
- Um usuário poderá visualizar todas as suas missões ativas e concluídas.
- Uma missão terá validade de 24 horas a partir de sua criação.
- Caso o usuário não possua missões ativas e acesse o sistema, novas missões serão geradas.
- As missões serão geradas a partir de um conjunto de missões previamente definido, utilizando um processo de seleção semialeatório.
- Um usuário poderá possuir no máximo três missões ativas simultaneamente.
- Ao concluir uma missão, o usuário receberá XP e moedas.
- A realização de missões não contribuirá diretamente para a reputação do usuário, mas influenciará seu indicador de participação.
#### 5.5 Reputação (AINDA PARA IMPLEMENTAR)
A reputação representa o grau de confiabilidade das informações fornecidas pelo usuário ao sistema.

A lógica de cálculo da reputação ainda está em definição.

A reputação poderá considerar fatores como:

1. Reports aceitos e tratados;
2. Avistamentos;
3. Outros comportamentos relacionados à confiabilidade das informações fornecidas pelo usuário.

A realização de missões não contribuirá diretamente para a reputação do usuário. Entretanto, poderá influenciar o indicador de participação do usuário.

#### 5.6 Progressão e recompensas
- O usuário acumulará XP por meio da realização de atividades do sistema.
- O XP acumulado determinará o nível do usuário.
- A quantidade de XP necessária para alcançar o próximo nível será calculada pela fórmula `50 + (50 × nível atual)`.
- Ao atingir o nível necessário, o usuário será classificado como Usuário Sustentável.
- Usuários Sustentáveis terão acesso a privilégios específicos.
- Usuários Sustentáveis poderão solicitar a recompensa associada à sua classificação.
- O usuário receberá moedas pela conclusão de determinadas missões.
- As moedas poderão ser utilizadas para adquirir itens ou recompensas disponíveis no sistema.

## 6. Acesso ao banco

## 7. Models / entidades

## 8. Validação

## 9. Tratamento de erros

## 10. Respostas da API

## 11. Autenticação e autorização

## 12. Comunicação com o PostgreSQL

## 13. Organização do código

## 14. Decisões arquiteturais