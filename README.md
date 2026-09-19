# saldo.sh

Gerenciador financeiro pessoal **local-first**, gratuito e configurável para
Android e Windows.

> **Projeto criado integralmente com inteligência artificial.** A ideia nasceu
> de uma necessidade pessoal: ter uma forma simples e gratuita de controlar
> meus gastos sem depender de um serviço fechado. Código, interface,
> documentação e testes foram produzidos por IA, sob minha direção, testes e
> feedback contínuo.

O saldo.sh é um projeto pessoal e experimental. Ele prioriza controle dos
dados, funcionamento offline e liberdade para configurar as integrações que
você realmente quer usar.

## Por que este projeto existe

Eu queria acompanhar contas, cartões, faturas e gastos futuros sem assinatura,
sem backend obrigatório e sem entregar toda a minha vida financeira para outra
plataforma.

O objetivo é manter o aplicativo:

- **simples**, para registrar e entender o dinheiro sem excesso de telas;
- **gratuito**, sem recursos essenciais presos atrás de assinatura;
- **local-first**, com os dados financeiros salvos primeiro no dispositivo;
- **configurável**, permitindo escolher IA e sincronização opcional;
- **transparente**, inclusive sobre o uso de IA em todo o desenvolvimento.

## Principais recursos

- Contas bancárias, carteiras e cartões de crédito.
- Transações com nome, categoria, data, conta e status.
- Parcelamentos e recorrências com projeções futuras.
- Faturas com pagamentos completos ou parciais e conta de origem.
- Orçamentos mensais por categoria.
- Relatórios, gráficos e evolução prevista do caixa.
- Assistente financeiro com histórico, ferramentas locais e gráficos.
- Provedor de IA OpenAI-compatible com API key do próprio usuário.
- Sincronização opcional e criptografada pelo Google Drive.
- Funcionamento completo do financeiro sem IA, Drive ou internet.

## Plataformas

- Android
- Windows

O mesmo conjunto de dados pode ser usado nos dois ambientes por meio da
sincronização opcional com o Google Drive.

## Privacidade e armazenamento

Os dados financeiros ficam em um banco SQLite local gerenciado com Drift.
Valores monetários são armazenados em centavos inteiros.

API keys, tokens OAuth e chaves de sincronização ficam no armazenamento seguro
do sistema e não são gravados no banco financeiro ou no arquivo do Drive.

Quando habilitada, a sincronização usa a pasta privada `appDataFolder` do
Google Drive. O snapshot é protegido com Argon2id e AES-256-GCM antes do
upload.

## Estrutura do projeto

```text
lib/
├── app/                  # composição da aplicação, tema e dependências
├── core/
│   ├── database/         # Drift, SQLite e identidade do dispositivo
│   ├── security/         # armazenamento seguro de segredos
│   └── sync/             # infraestrutura compartilhada de sincronização
└── features/
    ├── finance/          # domínio financeiro, casos de uso e interface
    ├── ai/               # assistente, providers, tools e conversas
    ├── settings/         # preferências e configurações
    └── sync/             # OAuth, Drive, criptografia, merge e conflitos

website/
└── dist/                 # site estático em HTML, CSS e JavaScript
```

## Executar localmente

Requisitos:

- Flutter compatível com o projeto.
- Android Studio para executar no Android.
- Visual Studio com o workload de C++ para executar no Windows.

```powershell
flutter pub get
flutter run
```

Para listar os dispositivos disponíveis:

```powershell
flutter devices
```

## Configurar a inteligência artificial

Abra **Configurações → Inteligência Artificial** e informe:

1. OpenAI, OpenRouter ou um endpoint OpenAI-compatible.
2. O modelo que deseja utilizar.
3. Sua própria API key.
4. Use **Testar conexão** antes de abrir o Assistente.

A IA consulta os dados somente por ferramentas controladas. Criações são
apresentadas como rascunhos e precisam ser revisadas antes de serem salvas.

## Configurar o Google Drive

A sincronização é opcional. Para habilitá-la:

1. Ative a Google Drive API em um projeto do Google Cloud.
2. Configure a tela de consentimento OAuth.
3. Crie uma credencial Android com o package e os SHA-1 corretos.
4. Crie um Client ID Web no mesmo projeto para o Android.
5. Crie separadamente uma credencial do tipo Aplicativo para computador para
   o Windows.

Execute passando somente os identificadores correspondentes ao ambiente:

```powershell
# Android
flutter run -d android `
  --dart-define=GOOGLE_ANDROID_SERVER_CLIENT_ID=SEU_CLIENT_ID_WEB

# Windows
flutter run -d windows `
  --dart-define=GOOGLE_DESKTOP_CLIENT_ID=SEU_CLIENT_ID_DESKTOP
```

Se a credencial desktop exigir um client secret, mantenha-o somente em um
arquivo local ignorado pelo Git. Nunca use o arquivo de configuração do Windows
para compilar o APK Android.

Ao conectar o primeiro dispositivo, escolha uma senha de sincronização com no
mínimo 12 caracteres. Outro dispositivo precisará da mesma senha para restaurar
os dados.

## Gerar builds

```powershell
# Android
flutter build apk --release `
  --dart-define=GOOGLE_ANDROID_SERVER_CLIENT_ID=SEU_CLIENT_ID_WEB

# Windows
flutter build windows --release `
  --dart-define=GOOGLE_DESKTOP_CLIENT_ID=SEU_CLIENT_ID_DESKTOP
```

Um build novo não inclui os dados do emulador ou do computador. Para testar uma
instalação realmente limpa, desinstale o app ou limpe seus dados antes de
instalar novamente.

## Qualidade

```powershell
flutter analyze
flutter test
```

Como o projeto foi desenvolvido por IA e continua evoluindo rapidamente,
revisões humanas, testes e contribuições são especialmente bem-vindos.
