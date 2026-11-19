# Clínica Vida & Saúde

Projeto acadêmico de uma clínica com três frentes: **paciente**, **recepcionista** e **profissional de saúde**. A interface usa Flutter e Riverpod. O backend do chatbot usa uma estrutura mínima com FastAPI e Pydantic.

Este README concentra a documentação do projeto e de **todas as pastas e arquivos do módulo paciente**. Os caminhos apresentados partem da raiz do repositório.

## Índice

- [Estado atual](#estado-atual)
- [Tecnologias e dependências](#tecnologias-e-dependências)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Arquitetura e responsabilidades](#arquitetura-e-responsabilidades)
- [Entrada do aplicativo](#entrada-do-aplicativo)
- [Paciente: domain](#paciente-domain)
- [Paciente: data](#paciente-data)
- [Paciente: presentation](#paciente-presentation)
- [Paciente: chatbot](#paciente-chatbot)
- [Fluxos do sistema](#fluxos-do-sistema)
- [Recursos visuais e configurações](#recursos-visuais-e-configurações)
- [Como executar](#como-executar)
- [Verificações e testes](#verificações-e-testes)
- [Guia de manutenção para iniciantes](#guia-de-manutenção-para-iniciantes)
- [Próximas etapas](#próximas-etapas)

## Estado atual

| Parte | O que existe hoje |
|---|---|
| Interface do paciente | Tela responsiva com fundo de cachoeira, marca da clínica, campo de mensagem, seleção de arquivo e exibição das mensagens locais |
| Estado da conversa | Riverpod controla mensagens do paciente e do assistente, espera, erros, nova tentativa e opções de atendimento |
| Armazenamento no Flutter | Histórico em memória e cliente HTTP para o backend Python |
| Backend do chatbot | Rota de mensagens com saudação, apresentação do serviço e escolha entre quatro atendimentos |
| Agendamento | Escolha inicial implementada no backend; datas, horários e reservas ainda não implementados |
| Inteligência artificial | Nenhum modelo ou provedor integrado |
| Comunicação Flutter–Python | Implementada por HTTP; mensagens e botões usam a mesma rota Python |
| Docker | Backend em container com healthcheck, publicado por padrão em `127.0.0.1:8000` |
| Recepcionista | Sidebar com quatro rotas e telas contendo somente o nome de cada feature |
| Profissional | Pastas de camadas criadas, sem funcionalidades |

**As mensagens da tela são enviadas ao backend Python e as respostas aparecem na conversa.** As regras atuais reconhecem saudações e a escolha entre os quatro atendimentos. O histórico permanece em memória no Flutter. Arquivos selecionados não são enviados; o atendimento recebe somente texto.

## Tecnologias e dependências

### Aplicativo Flutter

As restrições abaixo estão declaradas em [app/pubspec.yaml](app/pubspec.yaml). As versões resolvidas ficam em [app/pubspec.lock](app/pubspec.lock).

| Tecnologia | Restrição declarada | Responsabilidade |
|---|---|---|
| Dart | `^3.12.0` | Linguagem do aplicativo |
| Flutter | SDK Flutter | Construção da interface e execução nas plataformas suportadas pelo projeto |
| Material 3 | Incluído no Flutter | Tema, campos, botões e componentes visuais |
| `flutter_riverpod` | `^3.4.3` | Gerenciamento de estado e composição do repositório da conversa |
| `file_picker` | `^13.4.0` | Abrir o seletor de arquivos do sistema |
| `http` | `^1.6.0` | Enviar mensagens em JSON e receber respostas da API |
| `flutter_test` | SDK Flutter; desenvolvimento | Testes de widgets e do estado da conversa |
| `flutter_lints` | `^6.0.0`; desenvolvimento | Regras de análise estática |

### Backend Python

As restrições estão em [requirements.txt](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/requirements.txt). Elas são intervalos permitidos, não um registro das versões instaladas.

| Tecnologia | Restrição declarada | Responsabilidade |
|---|---|---|
| Python | 3.11 ou superior | Linguagem do backend; o código usa `StrEnum` |
| FastAPI | `>=0.115,<1.0` | Aplicação HTTP e futura declaração das rotas |
| Pydantic | `>=2.10,<3.0` | Validação de entradas e estruturação de respostas |
| Uvicorn | `>=0.30,<1.0` | Servidor que executa a aplicação FastAPI |

**Pydantic não é Pydantic AI.** O projeto usa Pydantic para validar dados e não possui um framework de agentes ou integração com modelo de IA. Não há banco ou ORM. A integração Flutter usa `http`, enquanto a execução local do backend é organizada por Docker Compose.

## Estrutura do projeto

```text
clinica/
├── README.md
├── compose.yaml
└── app/
    ├── README.md
    ├── pubspec.yaml
    ├── pubspec.lock
    ├── analysis_options.yaml
    ├── .gitignore
    ├── assets/
    │   ├── fonts/
    │   └── images/
    ├── lib/
    │   ├── main.dart
    │   └── repositorios/
    │       ├── paciente atendimento virtual/
    │       │   ├── domain/
    │       │   │   ├── entities/
    │       │   │   │   ├── mensagem_paciente.dart
    │       │   │   │   └── resposta_chatbot.dart
    │       │   │   └── repositories/
    │       │   │       └── conversa_repository.dart
    │       │   ├── data/
    │       │   │   └── repositories/
    │       │   │       └── conversa_api_repository.dart
    │       │   ├── presentation/
    │       │   │   ├── pages/
    │       │   │   │   └── paciente_page.dart
    │       │   │   ├── providers/
    │       │   │   │   └── conversa_provider.dart
    │       │   │   └── widgets/
    │       │   │       ├── clinica_brand.dart
    │       │   │       ├── mensagem_composer.dart
    │       │   │       └── mensagem_balao.dart
    │       │   └── backend do chatbot/
    │       │       ├── Dockerfile
    │       │       ├── .dockerignore
    │       │       ├── main.py
    │       │       ├── schemas.py
    │       │       ├── service.py
    │       │       ├── repository.py
    │       │       ├── requirements.txt
    │       │       ├── tests/
    │       │       │   ├── test_service.py
    │       │       │   └── test_api.py
    │       │       └── .gitignore
    │       ├── recepcionista/
    │       │   ├── features/
    │       │   │   ├── agenda/presentation/agenda_page.dart
    │       │   │   ├── pacientes/presentation/pacientes_page.dart
    │       │   │   ├── profissionais/presentation/profissionais_page.dart
    │       │   │   └── consultas/presentation/consultas_page.dart
    │       │   └── global/
    │       │       ├── recepcionista_routes.dart
    │       │       ├── domain/
    │       │       ├── data/
    │       │       └── presentation/
    │       │           ├── recepcionista_sidebar.dart
    │       │           └── recepcionista_layout.dart
    │       └── médicos/
    │           ├── domain/
    │           ├── data/
    │           └── presentation/
    ├── test/
    │   ├── widget_test.dart
    │   ├── chatbot_api_integration_test.dart
    │   └── recepcionista_navigation_test.dart
    ├── android/
    ├── ios/
    ├── linux/
    ├── macos/
    ├── web/
    └── windows/
```

As pastas de plataforma contêm os projetos nativos, configurações e pontos de inicialização gerados pelo Flutter. Sua presença não significa que todas as plataformas tenham sido compiladas e verificadas.

Os arquivos `.gitkeep` em `recepcionista` e `médicos` permitem versionar pastas ainda vazias. Eles não executam código.

## Arquitetura e responsabilidades

O frontend segue uma separação inspirada em Clean Architecture:

| Pasta | Responsabilidade |
|---|---|
| `lib/` | Código Dart da aplicação |
| `lib/repositorios/` | Agrupa as três frentes do projeto; apesar do nome, contém módulos completos, não apenas classes de repositório |
| `paciente atendimento virtual/` | Funcionalidades e interface voltadas ao paciente, além da pasta do backend do chatbot |
| `paciente atendimento virtual/domain/` | Entidades da conversa, opções, resposta do atendimento e contrato do repositório |
| `paciente atendimento virtual/data/` | Histórico em memória, chamadas HTTP e conversão da resposta Python para entidades Dart |
| `paciente atendimento virtual/presentation/` | Tela, widgets e controle de estado Riverpod |
| `paciente atendimento virtual/backend do chatbot/` | Backend Python independente, com cinco arquivos principais |

O domínio Dart não importa Flutter, Riverpod ou uma implementação concreta de armazenamento. O provider escolhe `ConversaApiRepository` e o utiliza através do contrato `ConversaRepository`.

O backend mantém a separação por **arquivos**, sem criar uma pasta para cada camada. A organização prevista é:

```text
main.py recebe HTTP
    → schemas.py valida os dados
    → service.py conduz o funil
    → repository.py fornece o catálogo inicial; disponibilidade e reserva são próximas etapas
```

A abertura já conecta rota, schemas, serviço e catálogo de atendimentos. A consulta de disponibilidade e a reserva continuam previstas para implementação.

O Flutter e o backend são processos separados. Guardar Python dentro de `lib/` organiza o repositório, mas não faz o Flutter iniciar ou executar o backend.

## Entrada do aplicativo

### `app/lib/main.dart`

[Abrir arquivo](app/lib/main.dart).

- `main()` inicia o aplicativo dentro de um `ProviderScope`, necessário para disponibilizar o estado Riverpod.
- `MyApp` configura o `MaterialApp`, o título e o tema escuro baseado em verde.
- Define `PacientePage` como tela inicial e registra as rotas nomeadas da recepcionista.

Este arquivo conecta a aplicação à tela. As regras de envio local ficam no controller Riverpod.

## Paciente: domain

### Pasta `domain/entities/`

Agrupa os objetos que representam os dados da funcionalidade, sem componentes visuais.

#### `mensagem_paciente.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/domain/entities/mensagem_paciente.dart).

Define `MensagemPaciente`, usada para as falas do paciente e do assistente:

| Campo | Tipo | Significado |
|---|---|---|
| `texto` | `String` | Conteúdo da mensagem |
| `nomeAnexo` | `String?` | Nome opcional do arquivo selecionado, apenas para exibição local |
| `autor` | `AutorMensagem` | Distingue `paciente` de `assistente`; o padrão é paciente |
| `opcoes` | `List<OpcaoAtendimento>` | Botões de escolha que acompanham uma resposta do backend |

A entidade não guarda bytes do arquivo, horário ou status de entrega. Esses dados não fazem parte do modelo atual.

#### `resposta_chatbot.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/domain/entities/resposta_chatbot.dart).

- `OpcaoAtendimento`: contém o ID e a descrição de uma opção enviada pelo backend.
- `RespostaChatbot`: contém etapa, mensagem, opções e atendimento selecionado. Representa a resposta já convertida para Dart, sem depender de JSON ou HTTP.

### Pasta `domain/repositories/`

Agrupa os contratos de acesso aos dados. Um contrato declara as operações necessárias sem escolher onde armazenar os dados.

#### `conversa_repository.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/domain/repositories/conversa_repository.dart).

Define a interface `ConversaRepository`:

- `listar()`: retorna as mensagens armazenadas.
- `adicionar(mensagem)`: adiciona uma mensagem ao histórico da tela.
- `responder(texto)`: retorna `Future<RespostaChatbot>` com a resposta do atendimento.

O acesso ao histórico é síncrono; a comunicação com o atendimento é assíncrona. A interface conhece esse contrato, sem importar o pacote HTTP.

## Paciente: data

### Pasta `data/repositories/`

Contém a implementação concreta do contrato de conversa.

#### `conversa_api_repository.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/data/repositories/conversa_api_repository.dart).

Define `ConversaApiRepository`, que implementa `ConversaRepository`:

- Mantém as mensagens em uma lista privada durante a sessão da tela.
- Recebe um `http.Client` e a URL do backend por injeção.
- Envia `POST /chatbot/mensagens` com `{"texto": "..."}` em JSON.
- Decodifica a resposta como UTF-8, preservando os acentos em nomes como Psicólogo.
- Converte `etapa`, `mensagem`, `opcoes` e `atendimento_selecionado` para entidades Dart.
- Trata status HTTP diferente de 200 e formato inválido como falhas.
- Limita a espera a 15 segundos, configuráveis no construtor.

O arquivo substitui a implementação exclusivamente local anterior. O histórico ainda não é persistido em banco.

## Paciente: presentation

Esta pasta pertence ao **frontend Flutter** e contém os elementos visuais e seu estado.

### Pasta `presentation/pages/`

Contém a composição da tela completa.

#### `paciente_page.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/presentation/pages/paciente_page.dart).

Define `PacientePage`, um `ConsumerStatefulWidget`, e seu estado `_PacientePageState`.

Responsabilidades:

- Observar `conversaProvider` para exibir mensagens, espera, erros e opções de atendimento.
- Montar o fundo, o gradiente, a marca, a lista de mensagens e o campo de entrada.
- Ajustar espaçamento e composição com `SafeArea` e `LayoutBuilder`.
- Usar uma composição compacta abaixo de 700 pixels de largura e um cabeçalho reduzido abaixo de 540 pixels de altura disponível.
- Limitar a largura da conversa e do campo de entrada a 760 pixels em telas maiores.
- Criar e descartar os controllers de texto e rolagem.

Métodos importantes:

- `_enviar()`: encaminha texto ou ID de uma opção ao controller e limpa o campo assim que o envio é aceito. A rolagem acompanha mensagens e mudanças no estado de espera.
- `_anexar()`: abre o seletor, encaminha somente o nome do arquivo ao estado e mostra uma mensagem caso a seleção falhe.
- `dispose()`: libera os controllers quando a tela é removida.

A tela chama o controller, que consulta o backend pelo repositório. As falas do paciente aparecem à direita, e as respostas do atendimento à esquerda. Mostra `Atendimento digitando...` durante a espera e permite tentar novamente após falha de conexão.

### Pasta `presentation/providers/`

Contém o estado da conversa e os comandos que a interface executa.

#### `conversa_provider.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/presentation/providers/conversa_provider.dart).

| Elemento | Responsabilidade |
|---|---|
| `conversaRepositoryProvider` | Criar o cliente HTTP, configurar a URL e disponibilizar `ConversaApiRepository`; fechar o cliente ao descartar o provider |
| `conversaProvider` | Disponibilizar `ConversaController` e seu estado |
| `ConversaState` | Guardar mensagens, anexo pendente, espera, erro, disponibilidade de nova tentativa e última resposta estruturada |
| `ConversaController.enviar()` | Validar o texto, mostrar a fala do paciente, aguardar a API e adicionar a resposta do assistente |
| `ConversaController.tentarNovamente()` | Repetir a última chamada que falhou, sem duplicar a mensagem do paciente |
| `ConversaController.anexar()` | Selecionar ou remover o nome de um arquivo para exibição local |

O controller impede envios simultâneos e mensagens acima de 2.000 caracteres. Uma mensagem vazia não é enviada, mesmo que exista um anexo. Falhas de HTTP, formato ou timeout resultam em uma mensagem de erro recuperável.

A URL vem de `--dart-define=CHATBOT_API_URL=...`, com padrão `http://127.0.0.1:8000`. O valor é definido ao iniciar ou compilar o Flutter.

`enviar()` retorna `Future<bool>`: `true` indica que a interface aceitou o envio, enquanto o resultado da comunicação fica no estado. `textoExibido` permite mostrar o nome do botão escolhido e enviar seu ID para a API.

### Pasta `presentation/widgets/`

Contém componentes visuais menores utilizados pela página.

#### `clinica_brand.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/presentation/widgets/clinica_brand.dart).

- `ClinicaBrand` exibe o nome **Clínica Vida & Saúde**, o slogan e o símbolo de ramo.
- O parâmetro `compact` ajusta o tamanho da tipografia.
- `_RamoPainter` desenha o símbolo usando `CustomPainter`, sem depender de uma imagem externa.
- `Semantics` fornece uma descrição acessível da marca.

#### `mensagem_composer.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/presentation/widgets/mensagem_composer.dart).

Define `MensagemComposer`, o componente de entrada de mensagem:

- Exibe o botão de anexo, o `TextField` e o botão de envio.
- Mostra um `InputChip` com o nome do anexo e a ação para removê-lo.
- Aplica borda arredondada, transparência e desfoque com `BackdropFilter`.
- Aceita de uma a quatro linhas e até 2.000 caracteres no campo de texto.
- Desabilita entrada, envio e alterações de anexo enquanto aguarda o backend. O envio exige texto.
- Usa `ValueListenableBuilder` para atualizar a disponibilidade do botão de envio conforme o texto.
- Recebe `onEnviar`, `onAnexar` e `onRemoverAnexo` como callbacks.

O widget não acessa o repositório nem chama HTTP. A página fornece as ações.

#### `mensagem_balao.dart`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/presentation/widgets/mensagem_balao.dart).

Define `MensagemBalao`, responsável pelo alinhamento e aparência de cada fala. Identifica mensagens do assistente com o título `Atendimento virtual` e apresenta as opções da API como `ActionChip`. Somente as opções da mensagem mais recente ficam ativas, e os botões são bloqueados durante o envio.

## Paciente: chatbot

Backend Python com a estrutura mínima aprovada. Não possui pasta visual ou uma camada `presentation` própria.

### `main.py`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/main.py).

Cria a aplicação FastAPI, conecta `AgendaRepository` a `ChatbotService` e expõe `POST /chatbot/mensagens`. A rota recebe `MensagemRequest`, chama o serviço e valida a saída com `MensagemResponse`.

`GET /health` retorna `{"status": "ok"}` para o healthcheck do Docker. O middleware CORS permite o Flutter web em `localhost` e `127.0.0.1`, em portas HTTP variáveis. Outras origens podem ser incluídas em `CORS_ORIGINS`, separadas por vírgula. O código também aceita `CORS_ORIGIN_REGEX` quando configurado diretamente no ambiente do processo.

### `schemas.py`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/schemas.py).

| Modelo | Responsabilidade |
|---|---|
| `Etapa` | Declarar `especialidade`, `atendimento_selecionado` e as etapas futuras `profissional`, `data_horario` e `confirmacao` |
| `MensagemRequest` | Validar o campo `texto`, removendo espaços nas extremidades, exigindo de 1 a 2.000 caracteres e rejeitando campos adicionais |
| `OpcaoResponse` | Representar uma opção por `id` e `descricao` |
| `MensagemResponse` | Retornar `etapa`, `mensagem`, `opcoes` e `atendimento_selecionado` |

`atendimento_selecionado` é `null` enquanto o paciente não escolher uma opção válida. Quando a escolha é identificada, o campo recebe a opção e a etapa passa a `atendimento_selecionado`. Isso não confirma nem cria uma consulta.

### `service.py`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/service.py).

`ChatbotService.responder(texto)` implementa a abertura, sem importar FastAPI ou Pydantic:

- Reconhece `oi`, `olá`, `bom dia`, `boa tarde` e `boa noite`, independentemente de caixa, acentos e pontuação.
- Corresponde ao cumprimento recebido; não deduz o período do dia pelo relógio.
- Apresenta o assistente e oferece os quatro atendimentos.
- Aceita número, ID, nome do atendimento ou nome dentro de uma frase simples.
- Aceita a grafia `oftamologista` como referência a `Oftalmologista`.
- Aproveita uma escolha já informada junto à saudação.
- Pede esclarecimento para respostas desconhecidas ou que mencionem mais de um atendimento.

A identificação é feita por regras e palavras, não por IA. Cada chamada é independente: ainda não há identificação, persistência ou histórico de conversa no backend. A resposta estruturada permite que o cliente apresente botões e envie o ID da opção no campo `texto`.

### `repository.py`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/repository.py).

`AgendaRepository.listar_atendimentos()` fornece o catálogo inicial na ordem dos números apresentados:

| Número | ID | Atendimento |
|---|---|---|
| 1 | `oftalmologista` | Oftalmologista |
| 2 | `psicologo` | Psicólogo |
| 3 | `dermatologista` | Dermatologista |
| 4 | `ortopedista` | Ortopedista |

Ainda não consulta banco, profissionais por nome, datas ou horários. A integração com a agenda oficial e a gravação de reservas serão implementadas posteriormente.

### `requirements.txt`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/requirements.txt).

Declara FastAPI, Pydantic e Uvicorn. Permite instalar as dependências do backend em um ambiente virtual Python independente das dependências Flutter.

### `.gitignore`

[Abrir arquivo](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/.gitignore).

Evita versionar o ambiente `.venv/`, caches Python, arquivos compilados, cache de pytest e `.env`. A entrada de pytest apenas prepara a regra de exclusão; pytest não está declarado como dependência; os testes Python usam `unittest`, da biblioteca padrão.

### Arquivos Docker

| Arquivo | Responsabilidade |
|---|---|
| [compose.yaml](compose.yaml), na raiz | Construir e iniciar o serviço `chatbot`, configurar origem CORS, publicar a porta e reiniciar o container quando necessário |
| [Dockerfile](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/Dockerfile) | Usar Python 3.12 slim, instalar dependências, copiar os quatro módulos Python e iniciar Uvicorn na porta 8000 como usuário sem privilégios de root |
| [.dockerignore](app/lib/repositorios/paciente%20atendimento%20virtual/backend%20do%20chatbot/.dockerignore) | Excluir ambientes virtuais, caches, testes e `.env` do contexto da imagem |

O healthcheck consulta `/health`. O container inclui as regras Python atuais; após alterá-las, reconstrua a imagem com `docker compose up --build -d --wait`.

## Fluxos do sistema

### Fluxo implementado: Flutter e backend Docker

```text
Paciente digita ou escolhe um botão
    → PacientePage chama ConversaController.enviar
    → Controller registra a fala e ativa o estado de espera
    → ConversaApiRepository envia JSON ao backend em Docker
    → FastAPI valida o corpo e chama as regras Python
    → Backend responde com mensagem, etapa e opções
    → Repository converte JSON para RespostaChatbot
    → Controller registra a fala do assistente e encerra a espera
    → Tela mostra a resposta e os botões de escolha
```

Se a chamada falhar, a tela encerra a espera e oferece nova tentativa. Repetir a chamada pela ação `Tentar novamente` não duplica o balão do paciente.

### Fluxo implementado no backend: abertura

```text
POST /chatbot/mensagens com {"texto": "Oi, boa tarde!"}
    → Validação Pydantic
    → ChatbotService reconhece a saudação
    → Resposta com apresentação do serviço e quatro opções

POST /chatbot/mensagens com {"texto": "2"}
    → Escolha identificada como Psicólogo
    → Resposta com etapa atendimento_selecionado
```

A tela Flutter usa essa mesma rota. Para testar o backend separadamente, use o Swagger em `/docs` ou, com o container iniciado:

```bash
curl -X POST http://127.0.0.1:8000/chatbot/mensagens \
  -H 'Content-Type: application/json' \
  -d '{"texto": "Oi, boa tarde!"}'
```

### Fluxo previsto: funil de agendamento

| Etapa | Interação esperada | Validação a implementar |
|---|---|---|
| Especialidade | Perguntar qual atendimento o paciente procura | A especialidade deve existir e estar disponível |
| Profissional | Apresentar os profissionais da especialidade | O profissional deve atender a especialidade selecionada |
| Data e horário | Oferecer datas e depois horários do profissional | O horário deve pertencer ao profissional e continuar disponível |
| Confirmação | Apresentar o resumo e solicitar confirmação | Revalidar a disponibilidade antes de registrar a reserva |

Regras previstas para implementação:

- Avançar somente com uma escolha válida para a etapa atual.
- Permitir corrigir escolhas anteriores e limpar as escolhas posteriores que dependem delas.
- Manter as etapas e escolhas sob controle do backend.
- Não criar uma consulta antes da confirmação do paciente.
- Impedir reserva duplicada e tratar a repetição da confirmação sem criar outra consulta.
- Se o horário for ocupado, oferecer novas opções preservando as escolhas que continuarem válidas.

Uma futura integração com IA poderá interpretar frases e extrair preferências. A validação das escolhas e a efetivação da reserva continuarão sendo responsabilidade do serviço e da agenda oficial. A abertura e a identificação da escolha inicial estão implementadas. As demais etapas e regras de reserva continuam pendentes.

## Recepcionista: sidebar e rotas

A sidebar está em `app/lib/repositorios/recepcionista/global/presentation/`. O fundo é azul claro, com o item atual destacado em verde. Contém somente Agenda, Pacientes, Profissionais e Consultas.

| Arquivo, relativo a `recepcionista/` | Responsabilidade |
|---|---|
| `global/presentation/recepcionista_sidebar.dart` | Marca da clínica, quatro itens e definição de seus nomes, ícones e caminhos em `MenuRecepcionista` |
| `global/presentation/recepcionista_layout.dart` | Composição compartilhada: sidebar fixa no desktop e drawer abaixo de 700 pixels de largura |
| `global/recepcionista_routes.dart` | Registro das quatro rotas, conectando cada página ao layout |
| `features/agenda/presentation/agenda_page.dart` | Exibir apenas o texto Agenda |
| `features/pacientes/presentation/pacientes_page.dart` | Exibir apenas o texto Pacientes |
| `features/profissionais/presentation/profissionais_page.dart` | Exibir apenas o texto Profissionais |
| `features/consultas/presentation/consultas_page.dart` | Exibir apenas o texto Consultas |

Rotas disponíveis:

- `/recepcionista/agenda`
- `/recepcionista/pacientes`
- `/recepcionista/profissionais`
- `/recepcionista/consultas`

Para iniciar diretamente a área da recepcionista, a partir da raiz do projeto:

```bash
cd app
flutter run -d chrome --web-port=3000 --dart-define=APP_AREA=recepcionista
```

`main.dart` lê `APP_AREA` e abre a Agenda quando o valor é `recepcionista`. Sem essa opção, a entrada padrão continua sendo o atendimento virtual do paciente.

Com o Flutter web executando na porta 3000, abra <http://localhost:3000/#/recepcionista/agenda>. A seleção dos itens utiliza as rotas nomeadas registradas no `MaterialApp`. As telas ainda não possuem agenda, cadastros ou consultas implementados.

`app/test/recepcionista_navigation_test.dart` verifica a troca entre as quatro páginas, o destaque do item atual e a abertura e fechamento do menu compacto.

## Recursos visuais e configurações

| Caminho | Responsabilidade |
|---|---|
| `app/assets/` | Recursos utilizados pela interface |
| `app/assets/images/` | Imagens e registro de geração do cenário |
| `app/assets/images/paciente_cachoeira.png` | Fundo horizontal da tela; fonte de 1672 × 941 pixels, ajustada ao espaço disponível por `BoxFit.cover` |
| `app/assets/images/paciente_cachoeira.prompt.txt` | Registro do prompt de geração e da dimensão efetiva do arquivo |
| `app/assets/fonts/` | Arquivo de fonte e sua licença |
| `app/assets/fonts/ClinicaSerif-Regular.ttf` | Fonte serifada registrada como `ClinicaSerif` para o nome da clínica |
| `app/assets/fonts/LICENSE-Liberation.txt` | Licença e informações de distribuição da fonte |
| `app/pubspec.yaml` | Nome, versão, SDK, dependências, recursos e fontes do aplicativo |
| `app/pubspec.lock` | Versões efetivamente resolvidas pelo gerenciador de pacotes Dart |
| `app/analysis_options.yaml` | Configuração de análise estática com as regras de `flutter_lints` |
| `app/.gitignore` | Exclusões de caches, builds, configurações locais e outros arquivos gerados |
| `app/.metadata` | Metadados do projeto administrados pelo Flutter |
| `app/README.md` | README inicial do template Flutter; a documentação específica do projeto está neste arquivo da raiz |
| `app/macos/Runner/DebugProfile.entitlements` | Permissões de leitura do arquivo selecionado e de conexão de rede como cliente |
| `app/macos/Runner/Release.entitlements` | Permissões de leitura do arquivo selecionado e de conexão de rede como cliente |
| `app/android/app/src/main/AndroidManifest.xml` | Inclui a permissão de acesso à internet |
| `app/android/app/src/debug/AndroidManifest.xml` | Permite HTTP local na versão debug para testar o backend de desenvolvimento |

## Como executar

Os comandos abaixo consideram o terminal aberto na raiz do repositório. A instalação de dependências exige acesso aos respectivos servidores de pacotes.

### Iniciar o backend com Docker

Na raiz do repositório, com Docker e Docker Compose disponíveis:

```bash
docker compose up --build -d --wait
```

A API ficará em <http://127.0.0.1:8000>, com documentação em `/docs`. Para acompanhar ou encerrar:

```bash
docker compose logs -f chatbot
docker compose down
```

O Compose publica somente na interface local por padrão. `CHATBOT_PORT` altera a porta do host e `CHATBOT_BIND` altera a interface de publicação. O endereço do Flutter precisa apontar para a mesma porta.

### Frontend no navegador

Use um Flutter compatível com a restrição Dart declarada no `pubspec.yaml`.

```bash
cd app
flutter pub get
flutter run -d chrome --web-port=3000
```

Para desktop Linux, com a ferramenta de compilação da plataforma configurada:

```bash
flutter run -d linux
```

Se as dependências já estiverem no cache e houver dificuldade de rede:

```bash
flutter pub get --offline
flutter run -d chrome --no-pub
```

O modo offline usa o que já existe no cache; não baixa pacotes ausentes nem atualizações.

### Configurar a URL da API no Flutter

Para Chrome e desktop no mesmo computador, o padrão `http://127.0.0.1:8000` já corresponde ao Compose. Para outra URL:

```bash
flutter run -d chrome --web-port=3000 --dart-define=CHATBOT_API_URL=http://127.0.0.1:8001
```

No emulador Android, o endereço do computador costuma ser `http://10.0.2.2:8000`; informe-o com o mesmo `--dart-define`. Em um dispositivo físico, use um endereço acessível por ele e ajuste a publicação da API. Somente debug Android está configurado para HTTP local; para distribuição, utilize HTTPS.

### Backend Python sem Docker, como alternativa

Não execute esta alternativa na mesma porta de um container ativo. Em outro terminal, a partir da raiz do repositório:

```bash
cd "app/lib/repositorios/paciente atendimento virtual/backend do chatbot"
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m uvicorn main:app --reload
```

Os comandos de ativação acima são para Linux/macOS. No PowerShell do Windows, a ativação correspondente é `.venv\Scripts\Activate.ps1`.

Com o servidor iniciado, acesse:

- Documentação interativa: <http://127.0.0.1:8000/docs>.
- Documentação alternativa: <http://127.0.0.1:8000/redoc>.
- Esquema OpenAPI: <http://127.0.0.1:8000/openapi.json>.

A documentação apresenta `POST /chatbot/mensagens`, que permite testar a abertura e a escolha de atendimento. A raiz `/` não tem rota cadastrada.

## Verificações e testes

### Frontend

A partir da raiz:

```bash
cd app
flutter analyze
flutter test
```

Quando as dependências já estiverem resolvidas, é possível utilizar `flutter analyze --no-pub` e `flutter test --no-pub` para evitar uma resolução automática de pacotes.

O arquivo [app/test/widget_test.dart](app/test/widget_test.dart) utiliza `MockClient` para testar a interface e o repositório sem exigir um servidor:

- Saudação e escolha por botão em 1920 × 1080, 390 × 844 e 844 × 390.
- Contrato HTTP, decodificação UTF-8 e mapeamento dos campos da resposta Python.
- Nova tentativa após falha sem duplicar a fala do paciente.
- Rejeição de anexo isolado e tratamento de resposta inválida.
- Indicador de espera, bloqueio de envio e timeout.

[app/test/chatbot_api_integration_test.dart](app/test/chatbot_api_integration_test.dart) usa o repositório e o controller reais contra o backend. Com Docker iniciado, dentro de `app/`:

```bash
flutter test --no-pub test/chatbot_api_integration_test.dart --dart-define=CHATBOT_INTEGRATION=true
```

O teste é desativado na execução comum para não exigir Docker de quem executa somente os testes de widgets. Quando habilitado, envia uma saudação, verifica as quatro opções e seleciona Psicólogo pela API real.

Esses testes não cobrem o seletor nativo de arquivos, upload, um modelo de IA ou reserva de consultas.

### Backend

Na pasta `backend do chatbot`, execute os testes da lógica, que não exigem os frameworks:

```bash
python3 -m unittest discover -s tests -p test_service.py -v
```

`tests/test_service.py` verifica saudação, catálogo, escolha por número/nome/ID, saudação com escolha, resposta desconhecida e ambiguidade.

Para executar também os testes HTTP, com as dependências da aplicação instaladas, instale o cliente de testes no ambiente virtual:

```bash
python -m pip install httpx
python -m unittest discover -s tests -v
```

`tests/test_api.py` verifica o contrato da rota, healthcheck, CORS e o retorno 422 para corpo inválido, texto vazio, texto excessivo e campos adicionais. Esses testes não envolvem reserva de consulta ou um modelo de IA.

## Guia de manutenção para iniciantes

| Quero alterar… | Onde começar |
|---|---|
| A tela inicial ou o tema | `app/lib/main.dart` |
| A posição dos elementos e a lista de mensagens | `presentation/pages/paciente_page.dart` |
| O nome, slogan ou símbolo da clínica | `presentation/widgets/clinica_brand.dart` |
| O campo de digitação e seus botões | `presentation/widgets/mensagem_composer.dart` |
| O estado e a validação do envio local | `presentation/providers/conversa_provider.dart` |
| Os dados que representam uma mensagem | `domain/entities/mensagem_paciente.dart` |
| As operações de armazenamento da conversa | `domain/repositories/conversa_repository.dart` |
| O histórico em memória e as chamadas HTTP | `data/repositories/conversa_api_repository.dart` |
| A URL da API | `--dart-define=CHATBOT_API_URL=...`, lido no provider |
| Os balões e botões do atendimento | `presentation/widgets/mensagem_balao.dart` |
| O formato da resposta usada pelo Flutter | `domain/entities/resposta_chatbot.dart` |
| Os campos aceitos e retornados pelo backend | `backend do chatbot/schemas.py` |
| A ordem das perguntas e as regras de avanço | `backend do chatbot/service.py` |
| A origem dos horários e a gravação da reserva | `backend do chatbot/repository.py` |
| As rotas da API | `backend do chatbot/main.py` |
| Dependências Flutter | `app/pubspec.yaml` |
| Dependências Python | `backend do chatbot/requirements.txt` |

Os caminhos curtos de `presentation`, `domain`, `data` e `backend do chatbot` nessa tabela são relativos a `app/lib/repositorios/paciente atendimento virtual/`.

Leia primeiro a entidade de mensagem e seu contrato; depois o repositório local, o controller e a tela. Para o backend, comece pelos schemas, entenda o funil documentado no serviço e então defina as operações de agenda necessárias.

## Próximas etapas

As tarefas abaixo são evolução prevista, não funcionalidades existentes:

1. Definir onde ficam o estado e a identificação de cada conversa.
2. Definir as operações da agenda e sua fonte oficial compartilhada pelas três frentes.
3. Continuar o funil em `ChatbotService` a partir da escolha inicial já implementada, acrescentando as transições, correções e confirmações.
4. Implementar as operações de `AgendaRepository`, incluindo proteção contra reservas duplicadas na fonte de dados.
5. Ampliar a rota de mensagens ou definir novas rotas para as próximas operações, usando schemas Pydantic.
6. Definir autenticação e vincular conversas e consultas ao paciente correspondente.
7. Definir as origens CORS e os endereços HTTPS do ambiente de publicação. A integração HTTP local já está implementada.
8. Escolher e integrar o modelo de IA, mantendo as credenciais no backend e as regras de reserva no serviço.

A estrutura Python pode permanecer nos cinco arquivos enquanto as responsabilidades forem pequenas. A divisão em novas pastas deve acompanhar necessidades concretas do código.
