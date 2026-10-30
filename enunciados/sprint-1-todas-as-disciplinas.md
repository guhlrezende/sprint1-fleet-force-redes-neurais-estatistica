# Challenge Sprint 1: enunciados das 9 disciplinas

Texto copiado do Portal da FIAP (Challenge Sprints, 1ª Sprint). Os títulos de seção foram acrescentados aqui; o texto de cada enunciado está como no Portal, inclusive erros de digitação. O que é só do formulário de envio (campo de RMs e botões de upload) foi retirado.

| | |
|---|---|
| Turma | 1TIAPR |
| Ano | 2026 |
| Nº da Sprint | 1 |
| Período para entrega | 08/10/2026 a 30/10/2026 |

**Descrição:** Desenvolvimento de uma Calculadora Inteligente de Custos de Frota para apoiar gestores e empresas na identificação de ineficiências e oportunidades de economia.

**Sobre a entrega:** Se você realizar a entrega, a responsabilidade de adicionar os outros alunos é sua. Então antes de realizar a entrega, tenha o RM dos outros alunos em mãos.

**Envio:** um arquivo por disciplina, de até 50 MB, nas extensões `.zip`, `.rar` ou `.7zip`.

Neste repositório estão as entregas de **Redes Neurais** e **Statistical Computing**. Os demais enunciados ficam aqui só como referência.

---

## 1. AI Challenges
Professor: André Godoi Chiovato

Challenge Sprint 1 – Planejamento da Primeira Entrega Sompo Seguros

**Contexto:**

Vocês estão participando de um projeto acadêmico em parceria com a empresa Sem Parar, utilizando a metodologia ágil Scrum. A Sprint Review com os representantes da empresa está agendada (22/outubro) e essa entrega, encerrá dia 30/outubro. Para estarmos preparados, precisamos organizar os cards do Trello, revisar as User Stories existentes e planejar os passos do projeto para a primeira entrega. Acesse a apresentação institucional da Sem Parar que está no canal Geral do Teams.

**Objetivo do Trabalho:**

1) Revisar e organizar criticamente os cards do Trello com base nas orientações fornecidas pelo professor nas aulas de AIC e pelo feedback da empresa que ela vai passar no dia 22/outubro.

2) Identificar quais User Stories do backlog da Sem Parar o grupo irá atender nesta sprint, criar/revisar os critérios de aceitação para cada User Story e priorizar os cards de acordo com o valor para o usuário. Lembrando que quanto mais User Stories da empresa forem atendidas, mais próximo o projeto estará do ideal perante a empresa.

**Entregáveis Obrigatórios:**

Documento de Análise Sprint Planning (PDF):

- Resumo das decisões do time para a Sprint Review1;
- Levantamento dos riscos e pontos validados pelo professor/empresa (feito no kickoff);
- Justificativas para os problemas identificados;
- Propostas de correção ou reestruturação das User Stories (se necessário).

Trello Atualizado:

- Prints dos principais cards do ponto de visto do grupo.
- Criação de novos cards (se necessário).
- Indicação clara das tarefas planejadas mirando na Sprint Review 1.
- Designação dos responsáveis por cada card.
- Critérios de aceitação que atenderão as US na Sprint Review 1 da Sem Parar.
- Incluir o link do Trello atualizado no PDF (sem mascarar o link).

Vídeo de até 5 minutos (YouTube "não listado"):

- Apresentação explicando o Trello e o que foi aprendido com as aulas do professor nas aulas de IAC.
- Como a equipe está se preparando e se organizou para a Sprint Review 1.
- Pode aproveitar o vídeo da CP2 de AIC para adicionar nesta entrega

Feedback da emprea:

- Trazer um resumo da gravação de áudio da reunião evidenciando o feedback da empresa;
- Análise crítica do grupo sobre esse feedback.

**Formato de Entrega**

Um arquivo PDF explicativo contendo:

- Link do Trello atualizado. Não mascarar o link no PDF porque dá problema.
- Link do vídeo explicativo. Não mascarar o link no PDF.
- Documentação A4 com prints das User Stories e suas justificativas e critérios de aceitação para confrontar com o link.
- Resumo do feedback recebido da empresa no dia da Sprint Review 1.
- Nomes e papéis dos integrantes (Scrum Master, Devs).

---

## 2. AI Computer Systems & Sensors
Professor: Norisvaldo Ferraz Junior

Sprint 1 - Coleta de medições e contexto da frota

**Enunciado**

Nesta Sprint, a equipe deverá criar a base inicial de telemetria com ESP32, representando situações da operação da frota ligadas a custos ou ineficiências.

**1. Montagem e leitura inicial no ESP32 (30 pontos)**

Usar ESP32, físico ou simulado no Wokwi, com pelo menos duas entradas de dados escolhidas conforme a proposta do grupo.

Exibir as leituras no Monitor Serial e demonstrar alterações nos valores das entradas.

**2. Contexto operacional e contribuição para o Challenge (50 pontos)**

Apresentar, no formato de um desenho de arquitetura de comunicação, como a telemetria proposta poderá contribuir para identificar ineficiências e apoiar decisões relacionadas à operação e aos custos da frota.

Demonstrar pelo menos dois cenários operacionais pertinentes à proposta e explicar o que as entradas representam em cada um, indicando quais dados são medidos.

**3. Estruturação do dado coletado (20 pontos)**

Organizar os registros no Monitor Serial em formato definido pelo grupo, identificando o elemento monitorado (local, objeto, equipamento ou veículo), a sessão de coleta e o contexto de operação.

Apresentar o significado das variáveis e suas unidades, quando aplicáveis.

**4. Conteúdo da entrega**

- Vídeo curto de até 5 minutos, publicado no YouTube como "não listado", apresentando a proposta do grupo, a explicação do código e a demonstração das atividades.
- Relatório com o nome e RM dos integrantes, contendo o desenho de arquitetura de comunicação.
- Código-fonte do ESP32, incluindo os arquivos do circuito quando utilizado o Wokwi.

---

## 3. Cognitive Data Science
Professor: Fernando Timóteo Fernandes

**SPRINT 1 - CONSTRUÇÃO DA BASE DA FROTA**

**ORIENTAÇÕES GERAIS:**

- Todos os integrantes do grupo são responsáveis pela entrega final;
- Colocar o nome completo e o número de matrícula de todos os integrantes;
- Não envie links, poste todos os entregáveis diretamente no PDF e no PORTAL, nos formatos exigidos;
- Serão descontados até 2,0 pontos em caso de cadastro ou entrega inadequados no sistema;
- Após o prazo de entrega, o sistema não aceitará envios posteriores;

**Objetivo:** Modelar e preparar a base de dados para a gestão de frotas

**Atividades:** Construir uma base de dados capaz de consolidar informações que atualmente estão espalhadas em diferentes sistemas: veículos, abastecimentos, pedágios, manutenção, multas e impostos.

a) Modelo Conceitual (3 pontos) - Desenvolva o modelo conceitual NO BRMODELO que permita registrar no mínimo:

Cliente, Veículo, Abastacimento, Pedágio, Manutenção, Multa, Imposto

b) Modelo Lógico (3 pontos) - Transforme o modelo conceitual em modelo lógico, evidenciando as chaves primárias, estrangeiras tipos de dados e relacionamentos.

c) Modelo Físico e preparação de dados (4 pontos) - Crio banco de dados e as entidades do banco de dados e insira dados simulados.

Insira pelo menos: 3 clientes, 10 veículos, 20 abastecimentos, 20 registros de pedágio, 10 manutenções, 10 multas e 10 pagamentos de impostos.

**Forma de entrega:** Apenas 1 PDF com CAPA no padrão ABNT e nome de todos os integrantes.

**Obs:** Os diagramas todos deverão estar contidos no mesmo documento PDF. Links para diagramas externos serão ignorados.

---

## 4. Computational Thinking with Python
Professor: Leonardo Ruiz Orabona

*(O Portal mostrou este enunciado cortado em "VER MAIS". O texto abaixo é o que apareceu.)*

**Challenge Python: Calculadora Inteligente de Custos de Frota**

**1. Contexto do desafio**

A gestão de uma frota envolve diferentes categorias de despesas, como combustível, manutenção, pedágios, multas e outros custos operacionais. O problema apresentado pela Sem Parar Empresas é que essas informações podem estar dispersas, dificultando a identificação de onde a operação está perdendo dinheiro.

O desafio dos alunos será desenvolver, utilizando Python, uma aplicação capaz de receber informações de uma frota, calcular e consolidar seus custos, identificar possíveis ineficiências e apresentar recomendações para redução de despesas.

O projeto seguirá uma abordagem incremental:

- Sprint 1 - Cadastro e cálculos básicos
- Sprint 2 - Persistência e análise dos custos
- Sprint 3 - Diagnóstico, benchmark e recomendações
- Sprint 4 - Produto final integrado e relatório executivo

A aplicação deverá evoluir durante as quatro sprints. Portanto, cada sprint deverá aproveitar e aprimorar o código desenvolvido anteriormente.

**Sprint 1: Fundamentos da Calculadora de Frota**

**Objetivo**

Desenvolver a primeira versão funcional da calculadora utilizando os fundamentos de programação em Python.

Nesta etapa, o sistema deverá permitir que o usuário informe os principais dados de uma frota e obtenha uma primeira visão consolidada de seus custos.

**Requisitos mínimos**

O programa deverá solicitar dados como:

- quantidade de veículos;
- quilômetros percorridos;
- consumo de combustível;
- valor gasto com combustível;
- manutenção;
- pedágios;
- multas;
- impostos e/ou outros custos;
- período referente aos dados.

A aplicação deverá realizar cálculos que permitam apresentar, no mínimo:

- custo total da frota;
- custo médio por veículo;
- custo por quilômetro;
- participação percentual de cada categoria no custo total;
- identificação da categoria com maior custo.

Os alunos deverão utilizar adequadamente:

- variáveis;
- tipos de dados;
- operadores;
- entrada e saída;
- estruturas condicionais;
- estruturas de repetição;
- listas e/ou dicionários;
- funções.

**Entrega**

Código-fonte Python organizado e executável, acompanhado de um README.md contendo descrição da solução e instruções de execução.

**Barema da Sprint 1**

| Critério | Pontos |
|---|---|
| Entrada e validação básica dos dados da frota | 20 |
| Cálculo correto dos custos e indicadores | 40 |
| Uso adequado de condicionais, repetições e estruturas de dados | 20 |
| Organização do programa em funções | 10 |
| Organização do código, legibilidade e documentação | 10 |
| Total | 100 |

---

## 5. Cognitive Cybersecurity
Professor: Leonardo Ruiz Orabona

**Challenge Cyber Security**
Proteção da Plataforma de Gestão de Custos de Frota

**Contexto**

A Sem Parar Empresas pretende disponibilizar uma solução capaz de receber dados de uma frota, consolidar custos, identificar ineficiências, calcular oportunidades de economia e produzir informações para gestores e lideranças.

Entre as funcionalidades previstas estão a inserção de dados da frota, acompanhamento periódico dos custos e geração de recomendações.

Essas funcionalidades também criam uma superfície de ataque.

Uma vulnerabilidade poderá permitir, por exemplo:

- acesso indevido aos dados de clientes;
- vazamento de informações financeiras e operacionais;
- alteração dos custos registrados;
- manipulação dos resultados apresentados;
- roubo de credenciais;
- indisponibilidade da plataforma;
- utilização indevida dos dados de clientes e leads.

**Missão**

Os alunos formarão uma equipe de Cyber Security contratada para analisar, projetar, implementar e testar a segurança da plataforma.

Ao longo de quatro sprints, deverão responder quatro perguntas:

- Sprint 1: O que precisamos proteger e contra quem?
- Sprint 2: Como devemos proteger?
- Sprint 3: As proteções realmente funcionam?
- Sprint 4: Conseguimos detectar, investigar e responder a um ataque?

**Sprint 1: Análise de Riscos e Modelagem de Ameaças**

**Objetivo**

Antes de implementar controles de segurança, a equipe deverá compreender o ambiente que está protegendo.

Os alunos deverão realizar uma análise de riscos da Calculadora de Redução de Custos de Frota, identificando ativos, ameaças, vulnerabilidades e possíveis impactos para o negócio.

O documento do Challenge prevê informações de custos, benchmarks, diagnósticos, oportunidades financeiras e dados de clientes. Isso fornece diferentes ativos que precisam ser considerados na análise.

**Parte 1: Identificação dos ativos**

O grupo deverá identificar pelo menos 8 ativos relevantes.

Exemplos:

| Ativo | Tipo | Importância |
|---|---|---|
| Credenciais | Acesso | Crítica |
| Dados dos clientes | Dados | Crítica |
| Custos da frota | Financeiro | Alta |
| Histórico de análises | Dados | Alta |
| Relatórios executivos | Documento | Alta |
| Aplicação | Software | Crítica |
| Banco de dados | Infraestrutura | Crítica |
| Logs | Segurança | Alta |

Os alunos deverão justificar a classificação.

**Parte 2: Tríade**

Os ativos deverão ser analisados considerando:

- Confidencialidade: quem pode visualizar?
- Integridade: quem pode modificar?
- Disponibilidade: qual o impacto se ficar indisponível?

**Parte 3: Modelagem de ameaças**

O grupo deverá construir um diagrama simplificado da arquitetura, contendo pelo menos:

Usuário → Aplicação → API / Backend → Banco de Dados

*(No Portal as setas apareceram como "?". Foram trocadas por "→" aqui.)*

A partir dele deverão identificar possíveis ameaças.

Sugestões:

- roubo de credenciais;
- força bruta;
- SQL Injection;
- XSS;
- acesso indevido à API;
- quebra de controle de acesso;
- vazamento de dados;
- interceptação de comunicação;
- alteração de informações;
- indisponibilidade.

**Parte 4: Matriz de riscos**

Deverão ser identificados pelo menos 10 riscos.

Para cada risco:

| Risco | Probabilidade | Impacto | Severidade | Mitigação |
|---|---|---|---|---|
| Roubo de credenciais | Alta | Alto | Crítico | MFA |
| SQL Injection | Média | Alto | Alto | Queries parametrizadas |
| Vazamento de dados | Média | Alto | Alto | Controle de acesso |

**Entrega**

Relatório de Análise de Segurança contendo:

- identificação dos ativos;
- análise;
- arquitetura;
- ameaças;
- vulnerabilidades;
- matriz de riscos;
- priorização dos riscos;
- propostas iniciais de mitigação.

**Barema da Sprint 1**

| Critério | Pontos |
|---|---|
| Identificação e classificação dos ativos | 30 |
| Aplicação da tríade | 20 |
| Diagrama e compreensão da arquitetura | 10 |
| Identificação das ameaças e vulnerabilidades | 20 |
| Matriz e classificação dos riscos | 10 |
| Qualidade técnica e justificativas | 10 |
| Total | 100 |

---

## 6. Machine Learning & Modelling
Professor: Mario Andre de Deus

**SPRINT 1 - Machine Learning & Modelling**

**Contexto do desafio**

A Sem Parar (Corpay) busca aprimorar a gestão de frotas por meio da integração e análise de dados operacionais, atualmente distribuídos entre diferentes sistemas.

Informações sobre veículos, abastecimentos, pedágios, manutenções, multas e impostos podem ser utilizadas para identificar oportunidades de redução de custos, antecipar problemas e apoiar decisões mais eficientes.

O desafio da disciplina é desenvolver uma solução de Machine Learning aplicada à gestão de frotas, transformando dados operacionais em previsões e informações úteis para os gestores.

**1º ENTREGÁVEL: Definição do problema e proposta de solução**

**Objetivo:** Compreender o desafio da Sem Parar e definir uma aplicação de Machine Learning que gere valor para a gestão de frotas.

**Atividades:**

- Identificar um problema de negócio relacionado à operação de frotas, como previsão de custos, identificação de despesas atípicas ou classificação de veículos por perfil de utilização.
- Definir o problema de Machine Learning, indicando se será utilizada classificação ou regressão e qual será a variável alvo.
- Identificar as principais variáveis (features) necessárias para o modelo.
- Propor uma solução que permita utilizar os resultados do modelo, como dashboard, aplicação web ou API.

**Entregável:** Apresentação em PDF ou slides, explicando o problema, a abordagem de Machine Learning e o valor esperado para a Sem Parar.

---

## 7. Plataformas, Serviços Cognitivos & Cloud Computing
Professor: Fernando Timóteo Fernandes

**SPRINT 1 - BANCO DE DADOS NA NUVEM**

**ORIENTAÇÕES GERAIS:**

- UTILIZAR EXCLUSIVAMENTE O AWS ACADEMY LEARNER LAB PARA OS EXERCÍCIOS.
- Apenas um membro do grupo deverá postar a solução no portal.
- Vídeo não listado no youtube demonstrando a solução completa.

**Objetivo:** Construir uma solução na AWS capaz de receber dados de uma frota e armazená-los de forma segura na nuvem, para posterior processamento.

**Atividades:** A empresa deseja permitir que seus clientes enviem dados relacionados à operação das frotas.

a) Criação de página institucional no S3 (4 pontos).

Crie um bucket S3 para hospedar uma página institucional da empresa, exibindo os serviços ofertados. Exiba o site.

b) Criação de banco de dados na nuvem - RDS (6 pontos)

Crie um banco de dados MySQL gratuito no Learner Lab com uma base de dados chamada dbFrota uma tabela chamada veiculos.

Replique a modelagem realizada no Sprint 1 de Cognitive Data Science, incluindo os registros.

**Forma de entrega:** Vídeo não listado no youtube.

---

## 8. Redes Neurais Artificiais, Deep Learning e Algoritmos Genéticos
Professora: Juliana Scudilio Rodrigues

**Sprint 1: Do problema de negócio à pipeline de redes neurais**

**O que vocês vão fazer**

Cada grupo vai desenhar uma pipeline de redes neurais para ajudar a Sem Parar Empresas a resolver um problema real. Pipeline é o caminho completo da solução: de onde vêm os dados até o resultado que chega para o usuário.

Nesta sprint não é preciso treinar o modelo. O que vale é planejar bem. O grupo escolhe o problema, os dados e as redes neurais. Descobrir qual rede serve para cada problema faz parte da atividade.

**Sobre a empresa**

A Sem Parar Empresas ajuda quem tem frota de veículos. Ela oferece Tag, Vale-Pedágio, Multiabastece, Gestor de Multas, Gestão de Manutenção, Antecipação de Recebíveis e Seguros.

Um problema comum dos clientes: o gestor sabe quanto gastou, mas não sabe onde está perdendo dinheiro. Os custos ficam em lugares diferentes e chegam em formatos diferentes, como planilha, texto, foto ou extrato.

**O que entregar**

Um PDF com as partes abaixo.

- Problema de negócio. Quem tem o problema? Qual o prejuízo? Como a Sem Parar pode ajudar?
- Dados. Quais dados a solução usa? De onde vêm? Em que formato estão? Que problemas eles podem ter, como dados faltando ou errados? Se vocês criarem dados de teste (simulados), expliquem como e por quê.
- Redes neurais. Quais redes poderiam ajudar a resolver o problema? Por que cada uma combina com os dados e com a tarefa? Apresentem pelo menos duas opções e expliquem qual escolheram.
- Pipeline. Um desenho e um texto curto mostrando o caminho completo: dados, tratamento, treino, teste e resultado para o usuário.
- Como medir o sucesso. Como vocês vão saber se a solução funciona?
- Riscos e limites. O que pode dar errado? O que a solução não resolve?

Ao longo do texto, indiquem de onde vieram as informações que vocês usaram.

**Ideias de problemas**

Vocês podem escolher uma destas ideias ou propor outra. Qualquer escolha precisa de um problema de negócio, de dados que existam ou possam ser simulados, e de um motivo para usar redes neurais.

- Receber dados da frota em vários formatos (planilha, foto, print, extrato) sem o gestor precisar arrumar nada antes.
- Descobrir quais veículos ou frotas gastam mais do que deveriam.
- Perceber quando algo foge do normal na operação.
- Estimar o custo total da frota, mesmo com poucas informações.
- Estimar quanto dinheiro uma frota poderia economizar.
- Sugerir ações ou produtos da Sem Parar conforme o perfil da frota.
- Fazer perguntas ao gestor para descobrir quais dados faltam.

**Como será a nota**

| O que será avaliado | Peso |
|---|---|
| Problema claro e ligado à Sem Parar | 25% |
| Escolha e justificativa dos dados | 25% |
| Redes neurais adequadas ao problema e aos dados | 25% |
| Pipeline completa e fácil de entender | 20% |
| Medidas de sucesso, riscos e organização | 5% |

**Regras:**

- Se vocês assumirem algo sem ter certeza, escrevam que é uma suposição.
- Toda escolha de dado ou de rede precisa de uma justificativa.
- Não inventem informações. Se não souberem algo, digam.

---

## 9. Statistical Computing with R & Python
Professor: Rodolfo Magliari de Paiva

**1º SEMESTRE – CHALLENGE SPRINT 1:**

**ORIENTAÇÕES GERAIS:**

- Esta avaliação vale 10,0 pontos;
- Todos os integrantes do grupo são responsáveis pela entrega final;
- Colocar o nome completo e o número de matrícula de todos os integrantes;
- Não envie links, poste todos os entregáveis diretamente no Portal, nos formatos exigidos;
- Serão descontados 2,0 pontos em caso de cadastro ou entrega inadequados no sistema;
- Após o prazo de entrega, o sistema não aceitará envios posteriores;
- O(s) arquivo(s) enviado(s) será(ão) o(s) avaliado(s), não sendo permitida substituição após o prazo;
- Será descontado 1,0 ponto por item ausente e/ou não atendido na avaliação.

**01) (4,0 pontos)** Os alunos deverão se organizar em grupos para realizar uma pesquisa utilizando uma base de dados que tenha relação com o tema proposto e com a empresa.

A base de dados poderá ser escolhida livremente pelo grupo, desde que seja adequada ao contexto e devidamente justificada, não sendo aceitas bases geradas artificialmente ou com dados fictícios.

A base de dados deverá estar no formato Excel e conter:

a) No mínimo 2 variáveis qualitativas nominais e 2 variáveis qualitativas ordinais, com pelo menos 100 observações.

b) No mínimo 2 variáveis quantitativas discretas e 2 variáveis quantitativas contínuas, com pelo menos 100 observações.

**02) (4,0 pontos)** Utilizando a base de dados do exercício 01), montar a Tabela de Distribuição de Frequências utilizando a Linguagem de Programação R ou Python para:

a) 1 variável quantitativa discreta.

b) 1 variável quantitativa contínua.

**03) (2,0 pontos)** Elaborar um relatório técnico contendo os principais insights obtidos nas análises realizadas nos itens 01 e 02, destacando de que forma os resultados podem contribuir para a tomada de decisão e/ou geração de valor para a empresa.

Assuma que este relatório será apresentado a uma empresa ou cliente que, além de utilizar as informações para apoiar a tomada de decisão, também avaliará seu desempenho e rigor como profissional da área técnica.

**04)** Em seguida, apenas um representante de cada grupo deverá postar no Portal:

a) O arquivo com a base de dados, obrigatoriamente em formato .csv (Comma-Separated Values) ou .xlsx (Excel);

b) Os códigos desenvolvidos, obrigatoriamente em formato .r (R) ou .py (Python);

c) O relatório técnico, obrigatoriamente em formato .pdf (PDF).

OBS: As entregas devem ser realizadas estritamente conforme as orientações e formatos definidos e trabalhados em aula pelo(a) respectivo(a) professor(a) da disciplina durante o semestre.
