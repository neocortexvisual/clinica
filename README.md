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
| Interface do paciente | Tela responsiva de chat conectada à API demonstrativa; mostra perguntas e opções numeradas |
| Estado da conversa | Riverpod controla mensagens, carregamento, erros e a conversa ativa |
| Armazenamento no Flutter | Lista em memória, sem persistência em banco |
| Backend do chatbot | API FastAPI conectada ao Flutter, com agenda demonstrativa em memória |
| Agendamento | Escolhas por número para especialidade, profissional, data e horário; confirmação explícita e dados fictícios |
| Inteligência artificial | Nenhum modelo ou provedor integrado |
| Anexos | Seletor disponível, mas arquivos ainda não são enviados ao atendimento |
| Recepcionista e profissional | Pastas de camadas criadas, sem funcionalidades |

O atendimento segue um fluxo guiado: digite o número da especialidade, do profissional, da data e do horário exibidos. A reserva só é criada após confirmação. Os dados são fictícios e ficam na memória do backend; não usar para consultas reais. O Flutter precisa estar com a API em execução para iniciar o chat.

## Tecnologias e dependências

### Aplicativo Flutter

As restrições abaixo estão declaradas em [app/pubspec.yaml](app/pubspec.yaml). As versões resolvidas ficam em [app/pubspec.lock](app/pubspec.lock).

| Tecnologia | Restrição declarada | Responsabilidade |
|---|---|---|
| Dart | `^3.12.0` | Linguagem do aplicativo |
| Flutter | SDK Flutter | Construção da interface e execução nas plataformas suportadas pelo projeto |
| Material 3 | Incluído no Flutter | Tema, campos, botões e componentes visuais |
| `flutter_riverpod` | `^3.4.3` | Gerenciamento de estado e composição do repositório da conversa |
| `file_picker` | `^12.2.0` | Abrir o seletor de arquivos do sistema |
| `http` | `^1.6.0` | Comunicação do app com a API de atendimento |
| `flutter_test` | SDK Flutter; desenvolvimento | Testes de widgets e do estado da conversa |
| `flutter_lints` | `^6.0.0`; desenvolvimento | Regras de análise estática |

### Backend Python

As restrições estão em [requirements.txt](app/lib/repositorios/paciente/chatbot/requirements.txt). Elas são intervalos permitidos, não um registro das versões instaladas.

| Tecnologia | Restrição declarada | Responsabilidade |
|---|---|---|
| Python | 3.11 ou superior | Linguagem do backend; o código usa `StrEnum` |
| FastAPI | `>=0.115,<1.0` | Aplicação HTTP e futura declaração das rotas |
| Pydantic | `>=2.10,<3.0` | Validação de entradas e estruturação de respostas |
| Uvicorn | `>=0.30,<1.0` | Servidor que executa a aplicação FastAPI |

**Pydantic não é Pydantic AI.** O projeto usa Pydantic para validar dados e não possui um framework de agentes ou integração com modelo de IA. Também não há banco, ORM ou integração com uma agenda oficial.

## Estrutura do projeto

```text
clinica/
├── README.md
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
    │       ├── paciente/
    │       │   ├── domain/
    │       │   │   ├── entities/
    │       │   │   │   └── mensagem_paciente.dart
    │       │   │   └── repositories/
    │       │   │       └── conversa_repository.dart
    │       │   ├── data/
    │       │   │   ├── repositories/
    │       │   │   │   └── conversa_local_repository.dart
    │       │   │   └── services/
    │       │   │       └── chatbot_api.dart
    │       │   ├── presentation/
    │       │   │   ├── pages/
    │       │   │   │   └── paciente_page.dart
    │       │   │   ├── providers/
    │       │   │   │   └── conversa_provider.dart
    │       │   │   └── widgets/
    │       │   │       ├── clinica_brand.dart
    │       │   │       └── mensagem_composer.dart
    │       │   └── chatbot/
    │       │       ├── main.py
    │       │       ├── schemas.py
    │       │       ├── service.py
    │       │       ├── repository.py
    │       │       ├── requirements.txt
    │       │       └── .gitignore
    │       ├── recepcionista/
    │       │   ├── domain/
    │       │   ├── data/
    │       │   └── presentation/
    │       └── profissional_saude/
    │           ├── domain/
    │           ├── data/
    │           └── presentation/
    ├── test/
    │   └── widget_test.dart
    ├── android/
    ├── ios/
    ├── linux/
    ├── macos/
    ├── web/
    └── windows/
```

As pastas de plataforma contêm os projetos nativos, configurações e pontos de inicialização gerados pelo Flutter. Sua presença não significa que todas as plataformas tenham sido compiladas e verificadas.

Os arquivos `.gitkeep` em `recepcionista` e `profissional_saude` permitem versionar pastas ainda vazias. Eles não executam código.

## Arquitetura e responsabilidades

O frontend segue uma separação inspirada em Clean Architecture:

| Pasta | Responsabilidade |
|---|---|
| `lib/` | Código Dart da aplicação |
| `lib/repositorios/` | Agrupa as três frentes do projeto; apesar do nome, contém módulos completos, não apenas classes de repositório |
| `paciente/` | Funcionalidades e interface voltadas ao paciente, além da pasta do backend do chatbot |
| `paciente/domain/` | Entidade de mensagem e contrato de armazenamento da conversa |
| `paciente/data/` | Implementação concreta do armazenamento local |
| `paciente/presentation/` | Tela, widgets e controle de estado Riverpod |
| `paciente/chatbot/` | Backend Python independente, com cinco arquivos principais |

O domínio Dart não importa Flutter, Riverpod ou uma implementação concreta de armazenamento. O provider escolhe `ConversaLocalRepository` e o utiliza através do contrato `ConversaRepository`.

O backend mantém a separação por **arquivos**, sem criar uma pasta para cada camada. A organização implementada é:

```text
main.py recebe HTTP
    → schemas.py valida os dados
    → service.py conduz o funil
    → repository.py consulta a agenda e registra a reserva
```

Essa sequência descreve o fluxo implementado. O Flutter chama as rotas HTTP e exibe a mensagem e as opções recebidas.

O Flutter e o backend são processos separados. Guardar Python dentro de `lib/` organiza o repositório, mas não faz o Flutter iniciar ou executar o backend.

## Entrada do aplicativo

### `app/lib/main.dart`

[Abrir arquivo](app/lib/main.dart).

- `main()` inicia o aplicativo dentro de um `ProviderScope`, necessário para disponibilizar o estado Riverpod.
- `MyApp` configura o `MaterialApp`, o título e o tema escuro baseado em verde.
- Define `PacientePage` como tela inicial.

Este arquivo conecta a aplicação à tela. As regras de envio local ficam no controller Riverpod.

## Paciente: domain

### Pasta `domain/entities/`

Agrupa os objetos que representam os dados da funcionalidade, sem componentes visuais.

#### `mensagem_paciente.dart`

[Abrir arquivo](app/lib/repositorios/paciente/domain/entities/mensagem_paciente.dart).

Define `MensagemPaciente`, com dois campos imutáveis:

| Campo | Tipo | Significado |
|---|---|---|
| `texto` | `String` | Conteúdo da mensagem |
| `nomeAnexo` | `String?` | Nome opcional do arquivo selecionado |

A entidade não guarda bytes do arquivo, autor, horário ou status de entrega. Esses dados não fazem parte do modelo atual.

### Pasta `domain/repositories/`

Agrupa os contratos de acesso aos dados. Um contrato declara as operações necessárias sem escolher onde armazenar os dados.

#### `conversa_repository.dart`

[Abrir arquivo](app/lib/repositorios/paciente/domain/repositories/conversa_repository.dart).

Define a interface `ConversaRepository`:

- `listar()`: retorna as mensagens armazenadas.
- `adicionar(mensagem)`: adiciona uma mensagem.

O contrato atual é síncrono porque representa apenas o histórico local. A comunicação HTTP com o chatbot é feita separadamente pelo serviço `ChatbotApi`.

## Paciente: data

### Pasta `data/repositories/`

Contém a implementação concreta do contrato de conversa.

#### `conversa_local_repository.dart`

[Abrir arquivo](app/lib/repositorios/paciente/data/repositories/conversa_local_repository.dart).

Define `ConversaLocalRepository`, que implementa `ConversaRepository`:

- Guarda mensagens em uma lista privada `_mensagens`.
- `listar()` devolve uma cópia não modificável da lista.
- `adicionar()` inclui uma mensagem na lista interna.

Não acessa API, banco ou arquivos. Os dados duram enquanto a instância do repositório existir e não são restaurados após encerrar a aplicação.

### Pasta `data/services/`

#### `chatbot_api.dart`

[Abrir arquivo](app/lib/repositorios/paciente/data/services/chatbot_api.dart).

Implementa o cliente HTTP usado pelo controller para criar conversas e enviar as escolhas ao backend. A URL padrão é `http://127.0.0.1:8000` e pode ser alterada com `--dart-define=CHATBOT_API_URL=...`. O histórico mostrado no app continua sendo mantido em memória pelo repositório local. HTTP sem TLS serve apenas ao desenvolvimento local; em produção, use HTTPS.

## Paciente: presentation

Esta pasta pertence ao **frontend Flutter** e contém os elementos visuais e seu estado.

### Pasta `presentation/pages/`

Contém a composição da tela completa.

#### `paciente_page.dart`

[Abrir arquivo](app/lib/repositorios/paciente/presentation/pages/paciente_page.dart).

Define `PacientePage`, um `ConsumerStatefulWidget`, e seu estado `_PacientePageState`.

Responsabilidades:

- Iniciar a conversa com a API e observar `conversaProvider` para exibir mensagens, opções e erros.
- Montar o fundo, o gradiente, a marca, a lista de mensagens e o campo de entrada.
- Ajustar espaçamento e composição com `SafeArea` e `LayoutBuilder`.
- Usar uma composição compacta abaixo de 700 pixels de largura e um cabeçalho reduzido abaixo de 540 pixels de altura disponível.
- Limitar a largura da conversa e do campo de entrada a 760 pixels em telas maiores.
- Criar e descartar os controllers de texto e rolagem.

Métodos importantes:

- `_enviar()`: encaminha a escolha ao backend pelo controller Riverpod e limpa o texto após uma resposta válida.
- `_anexar()`: abre o seletor, encaminha somente o nome do arquivo ao estado e mostra uma mensagem caso a seleção falhe.
- `dispose()`: libera os controllers quando a tela é removida.

A tela recebe as mensagens e as opções do chatbot pelo backend.

### Pasta `presentation/providers/`

Contém o estado da conversa e os comandos que a interface executa.

#### `conversa_provider.dart`

[Abrir arquivo](app/lib/repositorios/paciente/presentation/providers/conversa_provider.dart).

| Elemento | Responsabilidade |
|---|---|
| `chatbotApiProvider` | Criar e liberar o cliente HTTP da API |
| `conversaRepositoryProvider` | Criar a implementação `ConversaLocalRepository`, exposta como `ConversaRepository` |
| `conversaProvider` | Disponibilizar o `ConversaController` e seu estado por meio de `NotifierProvider` |
| `ConversaState` | Representar mensagens, etapa de carregamento, erros e conversa ativa |
| `ConversaController.iniciar()` | Criar a conversa na API e exibir a primeira pergunta |
| `ConversaController.anexar(nome)` | Selecionar um anexo ou removê-lo ao receber `null` |
| `ConversaController.enviar(texto)` | Enviar a escolha digitada à API e atualizar o histórico |

`iniciar()` cria a conversa remota. `enviar()` encaminha a escolha digitada à API e atualiza o histórico local com a mensagem e a resposta. O app informa quando não consegue alcançar o backend. Anexos não são enviados.

### Pasta `presentation/widgets/`

Contém componentes visuais menores utilizados pela página.

#### `clinica_brand.dart`

[Abrir arquivo](app/lib/repositorios/paciente/presentation/widgets/clinica_brand.dart).

- `ClinicaBrand` exibe o nome **Clínica Vida & Saúde**, o slogan e o símbolo de ramo.
- O parâmetro `compact` ajusta o tamanho da tipografia.
- `_RamoPainter` desenha o símbolo usando `CustomPainter`, sem depender de uma imagem externa.
- `Semantics` fornece uma descrição acessível da marca.

#### `mensagem_composer.dart`

[Abrir arquivo](app/lib/repositorios/paciente/presentation/widgets/mensagem_composer.dart).

Define `MensagemComposer`, o componente de entrada de mensagem:

- Exibe o botão de anexo, o `TextField` e o botão de envio.
- Mostra um `InputChip` com o nome do anexo e a ação para removê-lo.
- Aplica borda arredondada, transparência e desfoque com `BackdropFilter`.
- Aceita de uma a quatro linhas no campo de texto.
- Usa `ValueListenableBuilder` para atualizar a disponibilidade do botão de envio conforme o texto.
- Recebe `onEnviar`, `onAnexar` e `onRemoverAnexo` como callbacks.

O widget não acessa o repositório nem chama HTTP. A página fornece as ações.

## Paciente: chatbot

Backend Python com uma API de demonstração. Não possui pasta visual ou uma camada `presentation` própria. Conversas e reservas ficam apenas na memória do processo, e a agenda contém dados inteiramente fictícios; não utilizar para atendimento ou agendamentos reais.

### `main.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/main.py).

- Cria a API FastAPI e uma instância do serviço com agenda fictícia.
- `POST /conversas` inicia uma conversa e apresenta especialidades.
- `POST /conversas/{conversa_id}/mensagens` recebe uma escolha e devolve a próxima etapa.
- Retorna `404` quando o identificador da conversa não existe no processo atual.
- Habilita CORS para origens locais de desenvolvimento; para outros ambientes, configure `CLINICA_CORS_ORIGINS` com uma lista de origens separadas por vírgula.

As rotas estão disponíveis também na documentação interativa do FastAPI. O estado é perdido ao reiniciar o servidor e não é compartilhado entre múltiplos processos.

### `schemas.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/schemas.py).

Define os formatos de dados previstos para a API:

| Modelo | Responsabilidade |
|---|---|
| `Etapa` | Enumerar `especialidade`, `profissional`, `data_horario`, `horario`, `confirmacao` e `concluida` |
| `MensagemRequest` | Validar uma entrada com o campo `texto` |
| `OpcaoResponse` | Representar uma opção por `id` e `descricao` |
| `MensagemResponse` | Representar o identificador da conversa, a etapa, a mensagem e a lista de opções |

Em `MensagemRequest`, Pydantic remove espaços nas extremidades, exige de 1 a 2.000 caracteres e rejeita campos adicionais.

Exemplo **ilustrativo** de um objeto compatível com `MensagemResponse`:

```json
{
  "etapa": "especialidade",
  "mensagem": "Qual especialidade você procura?",
  "opcoes": [
    {"id": "pediatria", "descricao": "Pediatria"},
    {"id": "ginecologia", "descricao": "Ginecologia"}
  ]
}
```

As respostas reais incluem `conversa_id`; as opções aceitam o número exibido, o respectivo `id` ou a descrição exata.

### `service.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/service.py).

Contém `ChatbotService`, responsável por conduzir o funil e executar as regras da conversa:

1. Solicitar a especialidade.
2. Solicitar um profissional daquela especialidade.
3. Solicitar uma data e, em seguida, um horário disponível.
4. Apresentar o resumo e exigir confirmação antes da reserva.

O serviço valida cada escolha, permite corrigir especialidade, profissional, data ou horário e só reserva após confirmação. Se o horário for ocupado durante a confirmação, oferece as opções restantes. A confirmação repetida na mesma conversa não cria outra reserva.

### `repository.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/repository.py).

Contém `AgendaRepository`, que fornece dados fictícios para a demonstração:

- Consultar especialidades e profissionais.
- Consultar horários disponíveis por profissional e data.
- Registrar o agendamento sem permitir duas reservas do mesmo horário.
- Reservar o horário em memória, impedindo duplicidade dentro do processo.

Essa implementação **não é a agenda oficial**, não persiste dados e não deve ser usada em produção. A integração com uma fonte compartilhada pelas frentes de recepção e profissional de saúde ainda precisa ser definida.

### `requirements.txt`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/requirements.txt).

Declara FastAPI, Pydantic e Uvicorn. Permite instalar as dependências do backend em um ambiente virtual Python independente das dependências Flutter.

### `.gitignore`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/.gitignore).

Evita versionar o ambiente `.venv/`, caches Python, arquivos compilados, cache de pytest e `.env`. Os testes do backend usam `unittest`, incluído na biblioteca padrão do Python.

## Fluxos do sistema

### Fluxo implementado: atendimento numerado

```text
Paciente inicia o chat
    → Flutter cria uma conversa por POST /conversas
    → API mostra especialidades numeradas
    → Paciente envia um número por POST /conversas/{id}/mensagens
    → API responde com opções para a próxima etapa
    → O fluxo repete para profissional, data e horário
    → Paciente confirma ou cancela a reserva
```

As respostas e mensagens ficam em memória no Flutter e no backend. Reiniciar o backend encerra as conversas existentes.

### Etapas do funil de agendamento

| Etapa | Interação |
|---|---|
| Especialidade | Escolha numerada; Pediatria e Ginecologia aparecem primeiro |
| Profissional | Escolha numerada entre profissionais da especialidade |
| Data e horário | Escolha numerada entre datas úteis e horários disponíveis |
| Confirmação | `1` confirma e `2` cancela; a disponibilidade é validada novamente |

O fluxo aceita o número, o identificador ou a descrição exata de uma opção. A agenda, os profissionais e os horários são demonstrativos, não uma agenda oficial.

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
| `app/macos/Runner/DebugProfile.entitlements` | Permissões do aplicativo macOS em debug/profile, incluindo leitura de arquivo selecionado pelo usuário |
| `app/macos/Runner/Release.entitlements` | Permissões do aplicativo macOS em release, incluindo leitura de arquivo selecionado pelo usuário |

## Como executar

Os comandos abaixo consideram o terminal aberto na raiz do repositório. A instalação de dependências exige acesso aos respectivos servidores de pacotes.

### Frontend no navegador

Use um Flutter compatível com a restrição Dart declarada no `pubspec.yaml`.
Inicie o backend em outro terminal antes de usar o chat.

```bash
cd app
flutter pub get
flutter run -d chrome --dart-define=CHATBOT_API_URL=http://127.0.0.1:8000
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

### Backend Python

Em outro terminal, a partir da raiz do repositório:

```bash
cd app/lib/repositorios/paciente/chatbot
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

Para testar manualmente: crie uma conversa com `POST /conversas`, copie o `conversa_id` retornado e envie escolhas com `POST /conversas/{conversa_id}/mensagens`, usando JSON como `{"texto":"1"}`. O número corresponde à ordem das opções exibidas em cada etapa. No Android Emulator, configure a URL do host com `--dart-define=CHATBOT_API_URL=http://10.0.2.2:8000`; em um aparelho físico, use o endereço IP da máquina que executa a API. A raiz `/` não tem rota cadastrada.

## Verificações e testes

### Frontend

A partir da raiz:

```bash
cd app
flutter analyze
flutter test
```

Quando as dependências já estiverem resolvidas, é possível utilizar `flutter analyze --no-pub` e `flutter test --no-pub` para evitar uma resolução automática de pacotes.

O arquivo [app/test/widget_test.dart](app/test/widget_test.dart) contém:

- Três testes de tela: 1920 × 1080, 390 × 844 e 844 × 390. Verificam as opções numeradas, o envio de uma escolha, a limpeza do campo e a ausência de erros de layout nessas condições.
- Um teste do controller: verifica a rejeição de texto vazio, informa que anexos não são enviados e valida a atualização do histórico após a resposta da API.

Esses testes não cobrem o seletor nativo de arquivos, upload, integração real com o backend, IA ou reserva de consultas.

### Backend

Dentro da pasta `chatbot`, execute os testes das regras e a verificação de sintaxe:

```bash
python -m unittest
python -m py_compile main.py schemas.py service.py repository.py test_service.py
```

Os testes cobrem escolhas inválidas, correções, confirmação sem duplicidade, cancelamento e conflito de horário. Ainda não há testes de integração HTTP que exercitem o fluxo completo entre API e Flutter.

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
| A implementação do armazenamento local | `data/repositories/conversa_local_repository.dart` |
| Os campos aceitos e retornados pelo backend | `chatbot/schemas.py` |
| A ordem das perguntas e as regras de avanço | `chatbot/service.py` |
| A origem dos horários e a gravação da reserva | `chatbot/repository.py` |
| As rotas da API | `chatbot/main.py` |
| Dependências Flutter | `app/pubspec.yaml` |
| Dependências Python | `chatbot/requirements.txt` |

Os caminhos curtos de `presentation`, `domain`, `data` e `chatbot` nessa tabela são relativos a `app/lib/repositorios/paciente/`.

Leia primeiro a entidade de mensagem e seu contrato; depois o repositório local, o controller e a tela. Para o backend, comece pelos schemas, serviço, repositório demonstrativo e rotas.

## Próximas etapas

Próximas etapas para transformar a demonstração em funcionalidade real:

1. Definir uma fonte oficial de agenda compartilhada pelas três frentes e substituir o repositório demonstrativo.
2. Persistir conversas e agendamentos; hoje o estado existe apenas na memória de um processo.
3. Definir autenticação e vincular conversas e consultas ao paciente correspondente.
4. Integrar o Flutter à API com um cliente HTTP e adaptar o estado Riverpod ao processamento assíncrono.
5. Configurar as origens CORS permitidas para a interface web, se aplicável.
6. Escolher e integrar um modelo de IA, mantendo as credenciais no backend e as regras de reserva no serviço.

A estrutura Python pode permanecer nos cinco arquivos enquanto as responsabilidades forem pequenas. A divisão em novas pastas deve acompanhar necessidades concretas do código.
