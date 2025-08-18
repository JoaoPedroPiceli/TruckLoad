#!/usr/bin/env python3
"""
Script para atualizar senhas de usuários existentes no banco de dados
Execute este script para definir senhas padrão para todos os usuários
"""

import os
from pymongo import MongoClient
from datetime import datetime

# Configuração do MongoDB
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
DB_NAME = "truckload"

def update_passwords():
    """Atualiza senhas de usuários existentes"""
    try:
        # Conectar ao MongoDB
        client = MongoClient(MONGO_URI)
        db = client[DB_NAME]
        
        print("🔐 Atualizando senhas de usuários existentes...")
        
        # Atualizar caminhoneiros sem senha
        caminhoneiros_sem_senha = db.caminhoneiros.find({"senha": {"$exists": False}})
        count_caminhoneiros = 0
        for caminhoneiro in caminhoneiros_sem_senha:
            db.caminhoneiros.update_one(
                {"_id": caminhoneiro["_id"]},
                {"$set": {"senha": "123456"}}
            )
            count_caminhoneiros += 1
            print(f"  ✅ Senha adicionada para caminhoneiro: {caminhoneiro.get('email', 'N/A')}")
        
        # Atualizar empresas sem senha
        empresas_sem_senha = db.empresas.find({"senha": {"$exists": False}})
        count_empresas = 0
        for empresa in empresas_sem_senha:
            db.empresas.update_one(
                {"_id": empresa["_id"]},
                {"$set": {"senha": "123456"}}
            )
            count_empresas += 1
            print(f"  ✅ Senha adicionada para empresa: {empresa.get('email', 'N/A')}")
        
        print(f"\n📊 Resumo:")
        print(f"  - Caminhoneiros atualizados: {count_caminhoneiros}")
        print(f"  - Empresas atualizadas: {count_empresas}")
        
        if count_caminhoneiros == 0 and count_empresas == 0:
            print("  ℹ️  Todos os usuários já possuem senhas definidas")
        
        print("\n🔑 Senha padrão definida: 123456")
        print("💡 Use estas credenciais para fazer login no app")
        
        # Mostrar usuários disponíveis para teste
        print("\n👥 Usuários disponíveis para teste:")
        
        print("\n🚛 Caminhoneiros:")
        caminhoneiros = list(db.caminhoneiros.find({}, {"email": 1, "nome": 1}))
        for c in caminhoneiros:
            print(f"  - {c.get('email', 'N/A')} ({c.get('nome', 'N/A')})")
        
        print("\n🏢 Empresas:")
        empresas = list(db.empresas.find({}, {"email": 1, "nome": 1}))
        for e in empresas:
            print(f"  - {e.get('email', 'N/A')} ({e.get('nome', 'N/A')})")
        
        client.close()
        print("\n✅ Processo concluído com sucesso!")
        
    except Exception as e:
        print(f"❌ Erro ao atualizar senhas: {e}")

if __name__ == "__main__":
    update_passwords()
