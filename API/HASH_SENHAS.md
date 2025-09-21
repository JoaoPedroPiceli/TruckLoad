# 🔐 Sistema de Hash de Senhas - TruckLoad API

## 📋 Visão Geral

A API TruckLoad agora implementa hash de senhas usando **bcrypt** para garantir a segurança dos dados dos usuários. Todas as senhas são armazenadas em formato hash, impossibilitando a visualização em texto claro.

## 🛡️ Segurança Implementada

### ✅ **Funcionalidades de Segurança:**
- **Hash bcrypt**: Senhas são criptografadas com salt aleatório
- **Verificação segura**: Comparação de senhas usando bcrypt.checkpw()
- **Migração automática**: Script para converter senhas existentes
- **Dados de exemplo seguros**: Novos usuários criados com senhas em hash

### 🔧 **Arquivos Modificados:**
- `main.py` - Endpoints de autenticação e criação de usuários
- `update_passwords.py` - Script de atualização de senhas
- `migrate_passwords.py` - Script de migração (NOVO)
- `requirements.txt` - Adicionada dependência bcrypt

## 🚀 Como Usar

### 1. **Instalar Dependências**
```bash
pip install -r requirements.txt
```

### 2. **Migrar Senhas Existentes** (IMPORTANTE!)
Se você já tem usuários no banco de dados, execute o script de migração:

```bash
python migrate_passwords.py
```

Este script irá:
- Identificar senhas em texto claro
- Converter para hash bcrypt
- Pular senhas já migradas
- Mostrar relatório de migração

### 3. **Usar a API**
A API funciona normalmente, mas agora com segurança:

```python
# Login (funciona igual)
POST /auth/login
{
    "email": "usuario@email.com",
    "senha": "123456",
    "tipo": "caminhoneiro"
}

# Criação de usuário (senha é automaticamente hasheada)
POST /caminhoneiros/
{
    "nome": "João Silva",
    "email": "joao@email.com",
    "senha": "minhasenha123",  # Será convertida para hash
    "cpf": "123.456.789-00",
    "telefone": "(11) 99999-9999",
    "tipoCaminhao": "Truck 3/4"
}
```

## 🔍 Verificação de Segurança

### **Como Verificar se as Senhas Estão Seguras:**

1. **No Banco de Dados:**
   - Senhas em hash começam com `$2b$`
   - Têm exatamente 60 caracteres
   - Exemplo: `$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4Jd.4QKQ2`

2. **Script de Verificação:**
```python
# Verificar se senha está em hash
def is_hashed_password(password: str) -> bool:
    return password.startswith('$2b$') and len(password) == 60
```

## 📊 Status da Migração

### **Antes da Migração:**
- ❌ Senhas em texto claro no banco
- ❌ Vulnerabilidade de segurança
- ❌ Dados sensíveis expostos

### **Após a Migração:**
- ✅ Senhas com hash bcrypt
- ✅ Segurança máxima
- ✅ Dados protegidos
- ✅ Compatibilidade mantida

## 🛠️ Scripts Disponíveis

### **1. migrate_passwords.py**
```bash
python migrate_passwords.py
```
- Migra senhas existentes para hash
- Detecta senhas já migradas
- Relatório detalhado

### **2. update_passwords.py**
```bash
python update_passwords.py
```
- Adiciona senhas padrão para usuários sem senha
- Usa hash bcrypt automaticamente
- Cria dados de exemplo seguros

## 🔒 Benefícios de Segurança

1. **Proteção contra vazamentos**: Senhas não podem ser lidas em texto claro
2. **Salt aleatório**: Cada hash é único, mesmo para senhas iguais
3. **Algoritmo robusto**: bcrypt é considerado seguro e resistente a ataques
4. **Compatibilidade**: API funciona normalmente, sem mudanças no frontend
5. **Migração transparente**: Usuários existentes continuam funcionando

## ⚠️ Importante

- **Execute a migração** antes de usar em produção
- **Backup do banco** antes de executar scripts
- **Teste** em ambiente de desenvolvimento primeiro
- **Monitore logs** durante a migração

## 🎯 Próximos Passos

1. Execute `migrate_passwords.py` no ambiente de produção
2. Teste login com usuários existentes
3. Verifique se todas as senhas estão em hash
4. Monitore a API para garantir funcionamento normal

---

**🔐 Suas senhas agora estão seguras!** A API TruckLoad implementa as melhores práticas de segurança para proteção de dados sensíveis.
