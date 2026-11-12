# Arena FutStore - Avaliação Somativa PPDM (SENAI)

Aplicativo Mobile desenvolvido em **Flutter** integrado à **API RESTful JSON** hospedada no **Render**.

---

## 📱 Sobre o Aplicativo
O **Arena FutStore** é um aplicativo mobile focado no comércio de artigos esportivos oficiais de futebol e serviços de locação de quadras society.

O projeto atende a todos os critérios da avaliação somativa:
- **Programação Orientada a Objetos (POO)**: Superclasse `ItemFutebol` e subclasses com polimorfismo (`ProdutoOficial` e `ProdutoPromocao`), além do modelo `ClubeFutebol`.
- **Persistência Local (Segurança de Dados)**: Proteção dos dados sensíveis do torcedor (Nome, CPF, Clube do coração, CEP e Endereço de entrega) persistidos localmente no aparelho via `SharedPreferences`, sem exposição pública desnecessária.
- **Persistência Externa (CRUD Completo na Nuvem)**: Catálogo com operações completas de `GET`, `POST`, `PUT` e `DELETE` consumindo a API RESTful hospedada no Render.
- **Múltiplas APIs Integradas**:
  1. **API Própria no Render**: [https://api-mercadinho-ppdm.onrender.com](https://api-mercadinho-ppdm.onrender.com) (Rotas `/produtos`, `/clubes` e `/saude`).
  2. **API Pública TheSportsDB**: Pesquisa de clubes mundiais, escudos e estádios em tempo real.
  3. **API Pública ViaCEP**: Preenchimento automático de endereço via CEP.
- **Plataformas Homologadas**: Android e Web.

---

## 📂 Estrutura do Repositório

```text
├── api_futebol/       # API RESTful JSON Server (Node.js) configurada para deploy no Render
│   ├── db.json        # Base de dados JSON (produtos e clubes)
│   ├── server.js      # Servidor Node.js com CORS e tratamento de porta dinâmica
│   └── package.json   # Dependências e scripts de execução
├── app_futebol/       # Aplicativo Flutter (Mobile Android & Web)
│   ├── android/       # Plataforma nativa Android
│   ├── web/           # Plataforma Web
│   ├── lib/           # Código fonte Dart (telas, componentes, models e services)
│   └── test/          # Testes automatizados de modelos e serialização
├── render.yaml        # Blueprint de infraestrutura como código para o Render
└── README.md          # Documentação do projeto
```

---

## 🚀 Como Executar o Projeto

### 1. Aplicativo Flutter (`app_futebol`)
```bash
cd app_futebol
flutter pub get
flutter run
```
*O app já vem configurado por padrão para consumir a API oficial em produção no Render.*

### 2. Executar a API Localmente (`api_futebol`)
```bash
cd api_futebol
npm install
npm start
```

---

## 🌐 Links em Produção
- **API Online no Render**: [https://api-mercadinho-ppdm.onrender.com](https://api-mercadinho-ppdm.onrender.com)
- **Repositório da API**: [https://github.com/ThomasTonho/API-MERCADINHO-PPDM](https://github.com/ThomasTonho/API-MERCADINHO-PPDM)
- **Repositório do Projeto**: [https://github.com/ThomasTonho/avaliacao-ppdm](https://github.com/ThomasTonho/avaliacao-ppdm)
