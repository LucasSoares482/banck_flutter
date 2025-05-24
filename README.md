<<<<<<< HEAD
# bank_novo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# 🏦 BankFlutter

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white" alt="Material Design">
</div>

<div align="center">
  <h3>🚀 Aplicativo bancário digital completo desenvolvido em Flutter</h3>
  <p>
    <strong>Experiência bancária moderna • Interface responsiva • Cotações em tempo real</strong>
  </p>
</div>

---

## 📱 Sobre o Projeto

O **BankFlutter** é uma aplicação bancária digital que oferece uma experiência completa de banco digital, incluindo autenticação segura, transferências entre contas, visualização de cotações de moedas em tempo real e conversor de moedas integrado.

### ✨ Principais Funcionalidades

- 🔐 **Autenticação Biométrica** - Login com impressão digital/Face ID
- 💸 **Transferências** - Entre contas com suporte a múltiplas moedas
- 📊 **Cotações em Tempo Real** - Integração com AwesomeAPI
- 💱 **Conversor de Moedas** - Conversão bidirecional entre 11 moedas
- 📈 **Gráficos Históricos** - Visualização de tendências de cotações
- 📋 **Histórico de Transações** - Extrato completo com filtros
- 📱 **Design Responsivo** - Otimizado para todos os tamanhos de tela
- 🎨 **Material Design 3** - Interface moderna e intuitiva

---

## 🖼️ Screenshots

<div align="center">
  <img src="screenshots/login.png" width="200" alt="Tela de Login">
  <img src="screenshots/home.png" width="200" alt="Tela Principal">
  <img src="screenshots/transfer.png" width="200" alt="Transferência">
  <img src="screenshots/currency.png" width="200" alt="Cotações">
</div>

---

## 🚀 Começando

### 📋 Pré-requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) 3.0+
- [Dart](https://dart.dev/get-dart) 3.0+
- Android Studio / VS Code
- Dispositivo físico ou emulador

### 🔧 Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/bankflutter.git
   cd bankflutter
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   flutter run
   ```

### 🧪 Dados de Demonstração

Para testar o aplicativo, use as credenciais padrão:

```
📧 Email: user@example.com
🔑 Senha: 123456
```

Ou registre uma nova conta diretamente no app!

---

## 🏗️ Arquitetura

### 📁 Estrutura do Projeto

```
lib/
├── 🎯 main.dart                     # Ponto de entrada
├── 🛣️ routes/                       # Gerenciamento de rotas
├── 📱 screens/                      # Telas da aplicação
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── transfer_screen.dart
│   └── currency_screen.dart
├── ⚙️ services/                     # Lógica de negócio
│   ├── auth_service.dart
│   ├── transaction_service.dart
│   └── currency_service.dart
├── 🎨 widgets/                      # Componentes reutilizáveis
├── 🛠️ utils/                        # Utilitários e helpers
└── 📊 models/                       # Modelos de dados
```

### 🔧 Tecnologias Utilizadas

- **State Management**: Provider Pattern
- **HTTP Requests**: http package
- **Local Storage**: SharedPreferences + SecureStorage
- **Biometric Auth**: local_auth
- **Charts**: fl_chart
- **UI**: Material Design 3

---

## 💱 Integração com APIs

### 🌐 AwesomeAPI - Cotações em Tempo Real

O app integra com a [AwesomeAPI](https://docs.awesomeapi.com.br/) para obter cotações atualizadas:

```dart
// Exemplo de uso
final currencyService = CurrencyService();
final currencies = await currencyService.getCurrencies();
```

**Moedas suportadas:**
- 🇧🇷 BRL (Real Brasileiro)
- 🇺🇸 USD (Dólar Americano)
- 🇪🇺 EUR (Euro)
- 🇬🇧 GBP (Libra Esterlina)
- 🇯🇵 JPY (Iene Japonês)
- 🇨🇦 CAD (Dólar Canadense)
- 🇦🇺 AUD (Dólar Australiano)
- 🇨🇭 CHF (Franco Suíço)
- 🇨🇳 CNY (Yuan Chinês)
- 🇦🇷 ARS (Peso Argentino)
- ₿ BTC (Bitcoin)

---

## 🎨 Design System

### 🎭 Tema e Cores

```dart
// Paleta de cores principal
Primary: #2196F3 (Azul)
Secondary: #03DAC6 (Ciano)
Background: #FFFFFF (Branco)
Surface: #F5F5F5 (Cinza claro)
```

### 📐 Responsividade

O app é totalmente responsivo e se adapta a:
- 📱 **Smartphones** (320px - 480px)
- 📱 **Tablets** (481px - 768px)
- 🖥️ **Dispositivos grandes** (769px+)

---

## 🔐 Segurança

### 🛡️ Medidas Implementadas

- **Armazenamento criptografado** para dados sensíveis
- **Autenticação biométrica** opcional
- **Validação rigorosa** de inputs
- **Timeout em requisições** HTTP
- **Sanitização** de dados do usuário

### 🔒 Fluxo de Autenticação

1. Verificação de sessão ativa
2. Prompt biométrico (se disponível)
3. Fallback para login tradicional
4. Persistência segura da sessão

---

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0                    # Gerenciamento de estado
  http: ^0.13.0                       # Requisições HTTP
  shared_preferences: ^2.0.0          # Storage local
  flutter_secure_storage: ^9.0.0     # Storage seguro
  local_auth: ^2.1.0                 # Autenticação biométrica
  intl: ^0.17.0                      # Formatação i18n
  fl_chart: ^0.60.0                  # Gráficos
  share_plus: ^6.0.0                 # Compartilhamento
```

---

## 🧪 Testing

### 🎯 Cenários de Teste

1. **Autenticação**
   - Login com credenciais padrão
   - Registro de novo usuário
   - Autenticação biométrica

2. **Transferências**
   - Transferência em BRL
   - Transferência com conversão de moeda
   - Validação de saldo insuficiente

3. **Cotações**
   - Visualização de cotações em tempo real
   - Gráficos históricos
   - Conversor de moedas

### 🚀 Executar Testes

```bash
flutter test
```

---

## 🤝 Contribuindo

Contribuições são sempre bem-vindas! Para contribuir:

1. **Fork** o projeto
2. Crie uma **branch** para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. Abra um **Pull Request**

### 📝 Padrões de Código

- Use **dart format** para formatação
- Siga as [convenções do Flutter](https://flutter.dev/docs/development/tools/formatting)
- Documente funções públicas
- Escreva testes para novas funcionalidades

---

## 🗺️ Roadmap

### 🎯 Próximas Funcionalidades

- [ ] 🔔 **Notificações Push** para transações
- [ ] 🏦 **Integração Open Banking** com bancos reais
- [ ] 💳 **Cartões virtuais** e físicos
- [ ] 📈 **Módulo de investimentos**
- [ ] 🇧🇷 **PIX brasileiro**
- [ ] 📷 **QR Code** para pagamentos
- [ ] 🌙 **Modo escuro** completo
- [ ] 🧪 **Testes automatizados** unitários e E2E

### 🛠️ Melhorias Técnicas

- [ ] **Clean Architecture** implementation
- [ ] **Dependency Injection** com get_it
- [ ] **Logs estruturados** para debugging
- [ ] **Analytics** e métricas de performance

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Seu Nome**

- 🌐 Website: [Em breve!](https://seusite.com)
- 📧 Email: dev.lucassoares482@gmail.com
- 🐙 GitHub: [@LucasSoares482](https://github.com/LucasSoares482)
- 💼 LinkedIn: [Lucas (Santos) Soares ](https://www.linkedin.com/in/lucas-soares-354738247/)

---

## 🙏 Agradecimentos

- [AwesomeAPI](https://docs.awesomeapi.com.br/) pelos dados de cotações
- [Flutter Team](https://flutter.dev/) pelo framework incrível
- [Material Design](https://material.io/) pelas diretrizes de design
- Comunidade Flutter pelo suporte e recursos

---

<div align="center">
  <h3>⭐ Se este projeto te ajudou, não esqueça de dar uma estrela!</h3>
  
  **Feito com ❤️ e Flutter**
</div>
>>>>>>> b52bcb4249ac39f62dc509294f58f5711268dd55
