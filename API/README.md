# 🚛 TruckLoad API

API backend para o sistema TruckLoad, desenvolvida com FastAPI e MongoDB.

## 🚀 Funcionalidades

### ✅ Implementadas
- **Autenticação**: Login para caminhoneiros e empresas
- **Caminhoneiros**: CRUD completo com perfil agregado
- **Empresas**: CRUD completo com perfil agregado
- **Cargas**: Sistema de cargas para caminhoneiros
- **Cargas Empresariais**: CRUD completo para cargas de empresas
- **Avaliações**: Sistema de avaliações empresa → caminhoneiro
- **Busca de Cargas**: Filtros por origem, destino, tipo, peso e preço
- **Dados de Exemplo**: População automática do banco com dados de teste

### 🔄 Endpoints Principais

#### Autenticação
- `POST /auth/login` - Login para caminhoneiros e empresas

#### Caminhoneiros
- `POST /caminhoneiros/` - Criar caminhoneiro
- `GET /caminhoneiros/` - Listar caminhoneiros
- `GET /caminhoneiros/{id}` - Obter caminhoneiro
- `PATCH /caminhoneiros/{id}` - Atualizar caminhoneiro
- `DELETE /caminhoneiros/{id}` - Remover caminhoneiro
- `GET /perfil/caminhoneiro/{id}` - Perfil agregado com métricas

#### Empresas
- `POST /empresas/` - Criar empresa
- `GET /empresas/` - Listar empresas
- `GET /empresas/{id}` - Obter empresa
- `PATCH /empresas/{id}` - Atualizar empresa
- `DELETE /empresas/{id}` - Remover empresa
- `GET /perfil/empresa/{id}` - Perfil agregado com métricas

#### Cargas Empresariais
- `POST /cargas-empresa/` - Criar carga empresarial
- `GET /cargas-empresa/` - Listar cargas empresariais
- `GET /cargas-empresa/{id}` - Obter carga empresarial
- `PATCH /cargas-empresa/{id}` - Atualizar carga empresarial
- `DELETE /cargas-empresa/{id}` - Deletar carga empresarial

#### Busca e Filtros
- `GET /cargas/disponiveis` - Buscar cargas disponíveis com filtros
- `GET /avaliacoes/` - Listar avaliações
- `POST /avaliacoes/` - Criar avaliação

## 🛠️ Configuração

### Variáveis de Ambiente
```bash
MONGODB_URI=mongodb://seu_servidor:porta/nome_do_banco
```

### Instalação
```bash
pip install -r requirements.txt
```

### Execução
```bash
# Iniciar a API
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Em produção (Render)
# A API será iniciada automaticamente
```

## 📊 Dados de Exemplo

A API cria automaticamente dados de exemplo na primeira execução:

### Caminhoneiros
- **João Silva** (joao.silva@email.com / 123456)
- **Maria Santos** (maria.santos@email.com / 123456)

### Empresas
- **Transportes ABC Ltda** (contato@abc.com / 123456)
- **Logística XYZ** (contato@xyz.com / 123456)

### Cargas de Exemplo
Execute o script `seed_cargas.py` para criar cargas de exemplo:
```bash
python seed_cargas.py
```

## 🔍 Exemplos de Uso

### Login
```bash
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "joao.silva@email.com", "senha": "123456", "tipo": "caminhoneiro"}'
```

### Buscar Cargas Disponíveis
```bash
curl "http://localhost:8000/cargas/disponiveis?origem=São Paulo&pesoMax=2000&precoMax=3000"
```

### Perfil de Empresa
```bash
curl "http://localhost:8000/perfil/empresa/{empresa_id}"
```

## 📈 Métricas e Estatísticas

### Perfil Caminhoneiro
- Avaliação média
- Quantidade de avaliações
- Taxa de cancelamento

### Perfil Empresa
- Avaliação média
- Total de cargas
- Cargas concluídas
- Taxa de conclusão

## 🚧 Próximos Passos

- [ ] Sistema de notificações
- [ ] Chat entre usuários
- [ ] Sistema de pagamentos
- [ ] Upload de documentos
- [ ] Avaliações para empresas
- [ ] Sistema de geolocalização

## 📝 Notas

- **Senhas**: Atualmente em texto claro (apenas para testes)
- **CORS**: Configurado para aceitar todas as origens (ajustar em produção)
- **Validação**: Usa Pydantic para validação de dados
- **Índices**: Configurados automaticamente para performance

## 🆘 Suporte

Para dúvidas ou problemas, verifique:
1. Conexão com MongoDB
2. Variáveis de ambiente
3. Logs da aplicação
4. Documentação da API em `/docs` (Swagger UI)
