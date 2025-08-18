# 🚛 TruckLoad - Integração com Banco de Dados

## 📋 Visão Geral

Este documento descreve a integração completa entre o aplicativo Flutter TruckLoad e o backend FastAPI com MongoDB. A integração permite que todas as telas do aplicativo interajam com dados reais do banco de dados.

## 🏗️ Estrutura da Integração

### Backend (API)
- **Framework**: FastAPI (Python)
- **Banco de Dados**: MongoDB
- **Deploy**: Render (https://truckload-u4nu.onrender.com)
- **Documentação**: Swagger UI disponível em `/docs`

### Frontend (Flutter)
- **Framework**: Flutter/Dart
- **HTTP Client**: `http` package
- **Service Layer**: `ApiService` centralizado
- **Models**: Classes de dados tipadas

## 🔗 Endpoints da API

### Autenticação
- `POST /auth/login` - Login para caminhoneiros e empresas

### Caminhoneiros
- `GET /perfil/caminhoneiro/{id}` - Perfil completo com métricas
- `GET /caminhoneiros/{id}` - Dados básicos
- `PATCH /caminhoneiros/{id}` - Atualizar dados
- `GET /cargas/?caminhoneiroId={id}` - Histórico de cargas
- `GET /avaliacoes/?caminhoneiroId={id}` - Avaliações recebidas

### Empresas
- `GET /perfil/empresa/{id}` - Perfil completo com métricas
- `GET /empresas/{id}` - Dados básicos
- `PATCH /empresas/{id}` - Atualizar dados
- `GET /cargas-empresa/?empresaId={id}` - Cargas da empresa
- `POST /cargas-empresa/` - Criar nova carga
- `PATCH /cargas-empresa/{id}` - Atualizar carga
- `DELETE /cargas-empresa/{id}` - Deletar carga

### Busca e Filtros
- `GET /cargas/disponiveis` - Buscar cargas disponíveis com filtros
- Filtros: origem, destino, tipoCarga, pesoMin, pesoMax, precoMin, precoMax

## 📱 Telas Integradas

### Caminhoneiros ✅
- ✅ **Tela Menu** - Navegação com userId
- ✅ **Tela Meu Perfil** - Dados reais do banco
- ✅ **Tela Editar Dados** - Atualização via API
- ✅ **Tela Histórico** - Cargas reais do banco
- ✅ **Tela Bancário** - Nome do usuário real
- ✅ **Tela Filtro Carga** - Busca de cargas disponíveis

### Empresas ✅
- ✅ **Tela Menu Empresarial** - Navegação com empresaId
- ✅ **Tela Perfil Empresarial** - Dados reais do banco
- ✅ **Tela Adicionar Carga** - Criação real de cargas
- ✅ **Tela Cargas Realizadas** - Cargas concluídas do banco
- ✅ **Tela Cargas Pendentes** - Gerenciamento completo de cargas
- ✅ **Tela Editar Carga** - Edição real de cargas
- ✅ **Tela Deletar Carga** - Exclusão real de cargas

## 🔧 Funcionalidades Implementadas

### ✅ Completamente Funcionais
1. **Autenticação e Login**
   - Login para caminhoneiros e empresas
   - Validação de credenciais
   - Retorno de dados do usuário

2. **Perfis de Usuário**
   - Caminhoneiros: avaliação média, quantidade, taxa de cancelamento
   - Empresas: total de cargas, cargas concluídas, taxa de conclusão

3. **Sistema de Cargas**
   - Cargas para caminhoneiros (histórico)
   - Cargas empresariais (CRUD completo)
   - Busca com filtros avançados

4. **Avaliações**
   - Sistema de avaliações empresa → caminhoneiro
   - Histórico de avaliações

5. **Gerenciamento de Cargas Empresariais**
   - Criação de novas cargas
   - Edição de cargas existentes
   - Exclusão de cargas
   - Visualização por status (pendentes, em trânsito, concluídas)
   - Validação de campos obrigatórios
   - Feedback visual de operações

### 🚧 Parcialmente Implementadas
1. **Sistema de Login Real**
   - Estrutura preparada
   - Falta implementar tela de login
   - Falta gerenciar tokens de autenticação

### 📋 Pendentes
1. **Funcionalidades Avançadas**
   - Sistema de notificações
   - Chat entre usuários
   - Sistema de pagamentos
   - Upload de documentos
   - Sistema de motoristas para cargas

## 🗄️ Dados de Exemplo

### Caminhoneiros
- **João Silva** (joao.silva@email.com / 123456)
- **Maria Santos** (maria.santos@email.com / 123456)

### Empresas
- **Transportes ABC Ltda** (contato@abc.com / 123456)
- **Logística XYZ** (contato@xyz.com / 123456)

### Cargas de Exemplo
- 6 cargas de exemplo criadas automaticamente
- Diferentes tipos, origens, destinos e preços
- Status variados (disponível, em trânsito)

## 🚀 Como Testar

### 1. Backend
```bash
cd API
# Configurar MONGODB_URI
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Dados de Exemplo
```bash
cd API
python seed_cargas.py
```

### 3. Teste da API
```bash
cd API
python test_api.py
```

### 4. Aplicativo Flutter
```bash
cd truckload
flutter run
```

## 🔍 Debugging e Troubleshooting

### Problemas Comuns
1. **Erro de Conexão**
   - Verificar se a API está rodando
   - Verificar URL base no ApiService
   - Verificar variáveis de ambiente

2. **Erro de Autenticação**
   - Verificar credenciais de exemplo
   - Verificar se o usuário existe no banco

3. **Dados não Carregam**
   - Verificar logs da API
   - Verificar se os dados de exemplo foram criados
   - Verificar parâmetros passados

### Logs Úteis
- **API**: Logs no console do uvicorn
- **Flutter**: Debug prints e console
- **MongoDB**: Logs de conexão e queries

## 📈 Próximos Passos

### Prioridade Alta
1. **Sistema de Login Real**
   - Tela de login funcional
   - Gerenciamento de sessão
   - Proteção de rotas

2. **Sistema de Motoristas**
   - Atribuir motoristas às cargas
   - Acompanhar status de entrega
   - Sistema de notificações

### Prioridade Média
1. **Melhorias de UX**
   - Loading states mais elaborados
   - Error handling avançado
   - Refresh de dados automático

2. **Funcionalidades de Negócio**
   - Sistema de notificações
   - Chat básico
   - Upload de documentos

### Prioridade Baixa
1. **Otimizações**
   - Cache de dados
   - Paginação
   - Filtros avançados
   - Busca por geolocalização

## 🎯 Funcionalidades Recém-Implementadas

### Gerenciamento de Cargas Empresariais
- **Criação**: Formulário completo com validação
- **Edição**: Campos editáveis com bloqueio inteligente
- **Exclusão**: Confirmação e feedback visual
- **Visualização**: Organização por status com cores
- **Validação**: Campos obrigatórios e formatação

### Melhorias de Interface
- **Loading States**: Indicadores visuais durante operações
- **Error Handling**: Mensagens claras de erro
- **Feedback Visual**: SnackBars para confirmações
- **Navegação**: Botões de voltar e refresh
- **Responsividade**: Layout adaptável

## 📚 Recursos Adicionais

- **Documentação da API**: `/docs` (Swagger UI)
- **Código Fonte**: Repositório Git
- **Scripts de Teste**: `test_api.py` e `seed_cargas.py`
- **Documentação Técnica**: README.md da API

---

**Última Atualização**: Dezembro 2024  
**Versão**: 3.0.0  
**Status**: Integração Empresarial Concluída ✅  
**Próximo Milestone**: Sistema de Login e Motoristas 🎯
