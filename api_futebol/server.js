const jsonServer = require('json-server');
const cors = require('cors');
const path = require('path');

const servidor = jsonServer.create();
const roteador = jsonServer.router(path.join(__dirname, 'db.json'));
const intermediarios = jsonServer.defaults();

// O Render define a porta através da variável de ambiente PORT
const PORTA = process.env.PORT || 3000;
const HOSPEDEIRO = '0.0.0.0';

// Habilita CORS completo para qualquer cliente
servidor.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

servidor.use(intermediarios);

// Rota de status e verificação do servidor
servidor.get('/saude', (requisicao, resposta) => {
  resposta.status(200).json({
    status: 'conectado',
    servico: 'Arena FutStore',
    tempoAtivoSegundos: Math.floor(process.uptime()),
    rotas: {
      produtos: '/produtos',
      clubes: '/clubes'
    }
  });
});

servidor.get('/health', (requisicao, resposta) => {
  resposta.status(200).json({
    status: 'conectado',
    servico: 'Arena FutStore'
  });
});

// Integra o roteador dos dados em JSON
servidor.use(roteador);

servidor.listen(PORTA, HOSPEDEIRO, () => {
  console.log(`=================================================`);
  console.log(` Servidor da Arena FutStore iniciado com sucesso! `);
  console.log(` Endereço: http://${HOSPEDEIRO}:${PORTA}`);
  console.log(` Rotas disponíveis:`);
  console.log(`   /produtos  (Listar, Cadastrar, Atualizar, Excluir)`);
  console.log(`   /clubes    (Listar Clubes)`);
  console.log(`   /saude     (Verificar Status)`);
  console.log(`=================================================`);
});
