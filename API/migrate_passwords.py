#!/usr/bin/env python3
"""
Script para migrar senhas existentes de texto claro para hash
Execute este script para converter todas as senhas existentes no banco de dados
"""

import os
import bcrypt
from pymongo import MongoClient

# Configuração do MongoDB
MONGO_URI = os.getenv("MONGODB_URI")
if not MONGO_URI:
    print("❌ Erro: Defina a variável de ambiente MONGODB_URI")
    exit(1)

def hash_password(password: str) -> str:
    """Gera hash da senha usando bcrypt"""
    if not password:
        raise ValueError("Senha não pode ser vazia")
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def is_hashed_password(password: str) -> bool:
    """Verifica se a senha já está em formato hash (bcrypt)"""
    if not password or len(password) < 10:
        return False
    # Senhas bcrypt começam com $2b$ e têm 60 caracteres
    return password.startswith('$2b$') and len(password) == 60

def migrate_passwords():
    """Migra senhas de texto claro para hash"""
    try:
        # Conectar ao MongoDB
        client = MongoClient(MONGO_URI)
        db = client["truckload_db"]
        
        print("🔐 Iniciando migração de senhas...")
        
        # Migrar caminhoneiros
        caminhoneiros = db.caminhoneiros.find({"senha": {"$exists": True}})
        count_caminhoneiros = 0
        for caminhoneiro in caminhoneiros:
            try:
                senha_atual = caminhoneiro.get("senha", "")
                
                # Pular se já estiver em hash
                if is_hashed_password(senha_atual):
                    print(f"  ⏭️  Caminhoneiro {caminhoneiro.get('email', 'N/A')} já possui senha com hash")
                    continue
                
                # Converter para hash
                senha_hash = hash_password(senha_atual)
                db.caminhoneiros.update_one(
                    {"_id": caminhoneiro["_id"]},
                    {"$set": {"senha": senha_hash}}
                )
                count_caminhoneiros += 1
                print(f"  ✅ Senha migrada para caminhoneiro: {caminhoneiro.get('email', 'N/A')}")
            except Exception as e:
                print(f"  ❌ Erro ao migrar caminhoneiro {caminhoneiro.get('email', 'N/A')}: {e}")
        
        # Migrar empresas
        empresas = db.empresas.find({"senha": {"$exists": True}})
        count_empresas = 0
        for empresa in empresas:
            try:
                senha_atual = empresa.get("senha", "")
                
                # Pular se já estiver em hash
                if is_hashed_password(senha_atual):
                    print(f"  ⏭️  Empresa {empresa.get('email', 'N/A')} já possui senha com hash")
                    continue
                
                # Converter para hash
                senha_hash = hash_password(senha_atual)
                db.empresas.update_one(
                    {"_id": empresa["_id"]},
                    {"$set": {"senha": senha_hash}}
                )
                count_empresas += 1
                print(f"  ✅ Senha migrada para empresa: {empresa.get('email', 'N/A')}")
            except Exception as e:
                print(f"  ❌ Erro ao migrar empresa {empresa.get('email', 'N/A')}: {e}")
        
        print(f"\n📊 Resumo da migração:")
        print(f"  - Caminhoneiros migrados: {count_caminhoneiros}")
        print(f"  - Empresas migradas: {count_empresas}")
        
        if count_caminhoneiros == 0 and count_empresas == 0:
            print("  ℹ️  Todas as senhas já estavam em formato hash")
        else:
            print("  ✅ Migração concluída com sucesso!")
            print("  🔒 Todas as senhas agora estão seguras com hash bcrypt")
        
    except Exception as e:
        print(f"❌ Erro durante a migração: {e}")
        exit(1)
    finally:
        client.close()

if __name__ == "__main__":
    migrate_passwords()
