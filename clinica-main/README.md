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
| Estado da conversa | Riverpod controla mensagens e o nome do anexo selecionado |
| Armazenamento no Flutter | Lista em memória, sem persistência em banco |
| Backend do chatbot | Aplicação FastAPI inicializada, schemas Pydantic e classes iniciais de serviço e repositório |
| Agendamento | Funil definido para implementação; ainda não executa reservas |
| Inteligência artificial | Nenhum modelo ou provedor integrado |
| Comunicação Flutter–Python | Ainda não implementada |
| Recepcionista e profissional | Pastas de camadas criadas, sem funcionalidades |

**Enviar uma mensagem na tela atual apenas adiciona a mensagem à demonstração local.** Não existe resposta automática do robô nem envio para o backend. Selecionar um arquivo armazena somente seu nome; não há upload.

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

**Pydantic não é Pydantic AI.** O projeto usa Pydantic para validar dados e não possui um framework de agentes ou integração com modelo de IA. Também não há banco, ORM ou cliente HTTP Flutter definidos para essa integração.

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
    │       │   │   └── repositories/
    │       │   │       └── conversa_local_repository.dart
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

O backend mantém a separação por **arquivos**, sem criar uma pasta para cada camada. A organização prevista é:

```text
main.py recebe HTTP
    → schemas.py valida os dados
    → service.py conduz o funil
    → repository.py consulta a agenda e registra a reserva
```

Essa sequência descreve a responsabilidade pretendida. As chamadas entre esses arquivos ainda não estão implementadas.

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

O contrato atual é síncrono e serve ao armazenamento em memória. Uma futura integração HTTP pode exigir um contrato assíncrono; trocar apenas a implementação não elimina essa necessidade.

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

## Paciente: presentation

Esta pasta pertence ao **frontend Flutter** e contém os elementos visuais e seu estado.

### Pasta `presentation/pages/`

Contém a composição da tela completa.

#### `paciente_page.dart`

[Abrir arquivo](app/lib/repositorios/paciente/presentation/pages/paciente_page.dart).

Define `PacientePage`, um `ConsumerStatefulWidget`, e seu estado `_PacientePageState`.

Responsabilidades:

- Observar `conversaProvider` para exibir mensagens e o anexo selecionado.
- Montar o fundo, o gradiente, a marca, a lista de mensagens e o campo de entrada.
- Ajustar espaçamento e composição com `SafeArea` e `LayoutBuilder`.
- Usar uma composição compacta abaixo de 700 pixels de largura e um cabeçalho reduzido abaixo de 540 pixels de altura disponível.
- Limitar a largura da conversa e do campo de entrada a 760 pixels em telas maiores.
- Criar e descartar os controllers de texto e rolagem.

Métodos importantes:

- `_enviar()`: chama o controller Riverpod, limpa o texto quando o envio local é aceito e desloca a lista para a mensagem mais recente.
- `_anexar()`: abre o seletor, encaminha somente o nome do arquivo ao estado e mostra uma mensagem caso a seleção falhe.
- `dispose()`: libera os controllers quando a tela é removida.

A tela não contém integração com o backend e não recebe mensagens de um robô.

### Pasta `presentation/providers/`

Contém o estado da conversa e os comandos que a interface executa.

#### `conversa_provider.dart`

[Abrir arquivo](app/lib/repositorios/paciente/presentation/providers/conversa_provider.dart).

| Elemento | Responsabilidade |
|---|---|
| `conversaRepositoryProvider` | Criar a implementação `ConversaLocalRepository`, exposta como `ConversaRepository` |
| `conversaProvider` | Disponibilizar o `ConversaController` e seu estado por meio de `NotifierProvider` |
| `ConversaState` | Representar a lista de mensagens e o nome do anexo pendente |
| `ConversaController.build()` | Carregar as mensagens do repositório para o estado inicial |
| `ConversaController.anexar(nome)` | Selecionar um anexo ou removê-lo ao receber `null` |
| `ConversaController.enviar(texto)` | Remover espaços nas extremidades, validar o envio, adicionar a mensagem e atualizar o estado |

`enviar()` retorna `false` quando não há texto nem anexo. Quando aceita a mensagem, retorna `true` e limpa o anexo pendente. Esse resultado indica somente que a mensagem foi adicionada localmente.

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

Backend Python com a estrutura mínima aprovada. Não possui pasta visual ou uma camada `presentation` própria.

### `main.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/main.py).

- Importa FastAPI.
- Cria `app = FastAPI(...)`, com título e versão da API.
- Reserva o local para adicionar as futuras rotas, que deverão chamar o serviço.

**Não há endpoints de negócio implementados.** Ao iniciar o servidor, estão disponíveis as páginas padrão de documentação do FastAPI, mas não operações de conversa ou agendamento.

### `schemas.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/schemas.py).

Define os formatos de dados previstos para a API:

| Modelo | Responsabilidade |
|---|---|
| `Etapa` | Enumerar `especialidade`, `profissional`, `data_horario` e `confirmacao` |
| `MensagemRequest` | Validar uma entrada com o campo `texto` |
| `OpcaoResponse` | Representar uma opção por `id` e `descricao` |
| `MensagemResponse` | Representar a etapa, a mensagem do chatbot e a lista de opções |

Em `MensagemRequest`, Pydantic remove espaços nas extremidades, exige de 1 a 2.000 caracteres e rejeita campos adicionais. Os schemas ainda não estão associados a rotas.

Exemplo **ilustrativo** de um objeto compatível com `MensagemResponse`:

```json
{
  "etapa": "especialidade",
  "mensagem": "Qual especialidade você procura?",
  "opcoes": [
    {"id": "clinica_geral", "descricao": "Clínico geral"},
    {"id": "cardiologia", "descricao": "Cardiologia"}
  ]
}
```

Esse exemplo não representa uma resposta já produzida pelo backend. O estado da conversa, sua identificação, o resumo e o resultado da reserva ainda precisam ser definidos durante a implementação.

### `service.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/service.py).

Contém a classe inicial `ChatbotService`, ainda sem métodos. Sua responsabilidade prevista é conduzir o funil e executar as regras da conversa:

1. Solicitar a especialidade.
2. Solicitar um profissional daquela especialidade.
3. Solicitar data e horário disponíveis.
4. Apresentar o resumo e exigir confirmação antes da reserva.

O serviço deverá acessar a agenda pelo repositório. Não deve construir respostas HTTP nem conhecer detalhes de SQL ou de uma API externa.

### `repository.py`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/repository.py).

Contém a classe inicial `AgendaRepository`, ainda sem métodos ou conexão configurada. Suas responsabilidades previstas são:

- Consultar especialidades e profissionais.
- Consultar horários disponíveis por profissional e data.
- Registrar o agendamento sem permitir duas reservas do mesmo horário.
- Utilizar a mesma fonte de agenda das frentes de recepção e profissional de saúde.

A fonte de dados ainda não foi escolhida. Não há agenda fictícia ou banco implementado neste arquivo.

### `requirements.txt`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/requirements.txt).

Declara FastAPI, Pydantic e Uvicorn. Permite instalar as dependências do backend em um ambiente virtual Python independente das dependências Flutter.

### `.gitignore`

[Abrir arquivo](app/lib/repositorios/paciente/chatbot/.gitignore).

Evita versionar o ambiente `.venv/`, caches Python, arquivos compilados, cache de pytest e `.env`. A entrada de pytest apenas prepara a regra de exclusão; pytest não está declarado como dependência e não há suíte Python no estado atual.

## Fluxos do sistema

### Fluxo implementado: mensagem local

```text
Paciente digita na tela
    → MensagemComposer chama onEnviar
    → PacientePage chama ConversaController.enviar
    → Controller cria MensagemPaciente
    → ConversaLocalRepository adiciona a mensagem à lista
    → Riverpod publica o novo estado
    → PacientePage exibe a mensagem
```

Esse caminho termina no frontend. Não faz uma chamada para Python.

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

Uma futura integração com IA poderá interpretar frases e extrair preferências. A validação das escolhas e a efetivação da reserva continuarão sendo responsabilidade do serviço e da agenda oficial. Nenhum desses comportamentos de backend está implementado nesta base.

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

```bash
cd app
flutter pub get
flutter run -d chrome
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

As páginas de documentação ainda não apresentam operações de negócio, pois as rotas de conversa e agendamento não foram implementadas. A raiz `/` não tem rota cadastrada.

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

- Três testes de tela: 1920 × 1080, 390 × 844 e 844 × 390. Verificam os elementos principais, o envio local, a limpeza do campo e a ausência de erros de layout nessas condições.
- Um teste do controller: verifica rejeição de texto vazio sem anexo, envio com anexo e remoção do anexo pendente.

Esses testes não cobrem o seletor nativo de arquivos, upload, integração com backend, IA ou reserva de consultas.

### Backend

Não há testes automatizados Python implementados. Para verificar somente a sintaxe dos quatro arquivos Python, dentro da pasta `chatbot`:

```bash
python -m py_compile main.py schemas.py service.py repository.py
```

Essa verificação não executa a API, não valida o funil e não substitui testes de integração.

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

Leia primeiro a entidade de mensagem e seu contrato; depois o repositório local, o controller e a tela. Para o backend, comece pelos schemas, entenda o funil documentado no serviço e então defina as operações de agenda necessárias.

## Próximas etapas

As tarefas abaixo são evolução prevista, não funcionalidades existentes:

1. Definir onde ficam o estado e a identificação de cada conversa.
2. Definir as operações da agenda e sua fonte oficial compartilhada pelas três frentes.
3. Implementar o funil em `ChatbotService` e testar as transições, correções e confirmações.
4. Implementar as operações de `AgendaRepository`, incluindo proteção contra reservas duplicadas na fonte de dados.
5. Expor as operações por rotas FastAPI usando os schemas Pydantic.
6. Definir autenticação e vincular conversas e consultas ao paciente correspondente.
7. Integrar o Flutter à API com um cliente HTTP e adaptar o estado Riverpod ao processamento assíncrono.
8. Configurar as origens CORS permitidas para a interface web.
9. Escolher e integrar o modelo de IA, mantendo as credenciais no backend e as regras de reserva no serviço.

A estrutura Python pode permanecer nos cinco arquivos enquanto as responsabilidades forem pequenas. A divisão em novas pastas deve acompanhar necessidades concretas do código.
