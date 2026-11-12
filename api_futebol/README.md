# API Arena FutStore (JSON Server REST API)

API RESTful pronta para produção e hospedagem gratuita no **Render** (https://render.com).

## 🚀 Como Executar Localmente

```bash
cd api_futebol
npm install
npm start
```

A API iniciará por padrão em `http://0.0.0.0:3000`.

### Rotas disponíveis:
- `GET /health` -> Verificação de saúde da API
- `GET /produtos` -> Lista todos os produtos
- `GET /produtos/:id` -> Detalhes de um produto
- `POST /produtos` -> Cria um novo produto
- `PUT /produtos/:id` -> Atualiza um produto existente
- `DELETE /produtos/:id` -> Remove um produto
- `GET /clubes` -> Lista clubes e seus estádios/escudos

---

## 🌐 Como Subir no Render (Passo a Passo)

1. Envie esta pasta ou o repositório completo para o **GitHub** ou **GitLab**.
2. Acesse seu painel no [Render](https://dashboard.render.com).
3. Clique no botão **New +** e selecione **Web Service**.
4. Conecte o repositório do projeto.
5. Preencha as configurações:
   - **Name**: `api-arena-futstore` (ou o nome que preferir)
   - **Region**: Oregon (EUA) ou Frankfurt
   - **Branch**: `main` (ou a branch que estiver usando)
   - **Root Directory**: `api_futebol`
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Instance Type**: `Free`
6. Clique em **Create Web Service**.
7. Aguarde a finalização do build. Quando estiver "Live", você receberá uma URL pública como:
   `https://api-arena-futstore-xxxx.onrender.com`
8. Abra essa URL no navegador ou teste no seu aplicativo Flutter.
