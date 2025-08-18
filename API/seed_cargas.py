#!/usr/bin/env python3
"""
Script para adicionar cargas de exemplo ao banco de dados
Execute este script após iniciar a API para popular o banco com dados de teste
"""

import os
import sys
from datetime import datetime, timedelta
from pymongo import MongoClient
from bson import ObjectId

# Adicionar o diretório pai ao path para importar os modelos
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def conectar_mongodb():
    """Conecta ao MongoDB usando a variável de ambiente"""
    MONGO_URI = os.getenv("MONGODB_URI")
    if not MONGO_URI:
        print("❌ Erro: Defina a variável de ambiente MONGODB_URI")
        sys.exit(1)
    
    try:
        client = MongoClient(MONGO_URI)
        db = client["truckload_db"]
        # Testar conexão
        db.command("ping")
        print("✅ Conectado ao MongoDB com sucesso!")
        return db
    except Exception as e:
        print(f"❌ Erro ao conectar ao MongoDB: {e}")
        sys.exit(1)

def obter_empresa_id(db, email):
    """Obtém o ID de uma empresa pelo email"""
    empresa = db.empresas.find_one({"email": email})
    if empresa:
        return str(empresa["_id"])
    return None

def criar_cargas_exemplo(db):
    """Cria cargas de exemplo para as empresas"""
    
    # Verificar se já existem cargas
    if db.cargas_empresa.count_documents({}) > 0:
        print("ℹ️  Já existem cargas no banco. Pulando criação...")
        return
    
    print("📦 Criando cargas de exemplo...")
    
    # Obter IDs das empresas
    empresa1_id = obter_empresa_id(db, "contato@abc.com")
    empresa2_id = obter_empresa_id(db, "contato@xyz.com")
    
    if not empresa1_id or not empresa2_id:
        print("❌ Erro: Empresas não encontradas. Execute a API primeiro para criar os dados de exemplo.")
        return
    
    # Cargas de exemplo para a primeira empresa
    cargas_empresa1 = [
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Transporte de Eletrônicos",
            "descricao": "Carga de eletrônicos diversos para loja de varejo. Requer cuidado especial no manuseio.",
            "tipoCarga": "Eletrônicos",
            "origem": "São Paulo, SP",
            "destino": "Rio de Janeiro, RJ",
            "peso": 1500.0,
            "preco": 2500.00,
            "data": datetime.now() + timedelta(days=3),
            "status": "disponivel",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Carga de Roupas",
            "descricao": "Transporte de roupas para loja de departamentos. Carga seca e leve.",
            "tipoCarga": "Têxtil",
            "origem": "São Paulo, SP",
            "destino": "Curitiba, PR",
            "peso": 800.0,
            "preco": 1800.00,
            "data": datetime.now() + timedelta(days=5),
            "status": "disponivel",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Móveis para Escritório",
            "descricao": "Transporte de móveis para escritório. Requer embalagem adequada.",
            "tipoCarga": "Móveis",
            "origem": "São Paulo, SP",
            "destino": "Belo Horizonte, MG",
            "peso": 2500.0,
            "preco": 3200.00,
            "data": datetime.now() + timedelta(days=2),
            "status": "em_transito",
            "created_at": datetime.utcnow()
        }
    ]
    
    # Cargas de exemplo para a segunda empresa
    cargas_empresa2 = [
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Produtos Químicos",
            "descricao": "Transporte de produtos químicos industriais. Requer documentação especial.",
            "tipoCarga": "Químicos",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Salvador, BA",
            "peso": 3000.0,
            "preco": 4500.00,
            "data": datetime.now() + timedelta(days=7),
            "status": "disponivel",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Alimentos Perecíveis",
            "descricao": "Transporte de alimentos perecíveis. Requer refrigeração.",
            "tipoCarga": "Alimentos",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Brasília, DF",
            "peso": 1200.0,
            "preco": 2800.00,
            "data": datetime.now() + timedelta(days=1),
            "status": "disponivel",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Máquinas Industriais",
            "descricao": "Transporte de máquinas industriais pesadas. Requer equipamento especializado.",
            "tipoCarga": "Máquinas",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Porto Alegre, RS",
            "peso": 5000.0,
            "preco": 8000.00,
            "data": datetime.now() + timedelta(days=10),
            "status": "disponivel",
            "created_at": datetime.utcnow()
        }
    ]
    
    # Inserir cargas
    todas_cargas = cargas_empresa1 + cargas_empresa2
    
    try:
        resultado = db.cargas_empresa.insert_many(todas_cargas)
        print(f"✅ {len(resultado.inserted_ids)} cargas criadas com sucesso!")
        
        # Mostrar algumas estatísticas
        total_disponiveis = db.cargas_empresa.count_documents({"status": "disponivel"})
        total_empresa1 = db.cargas_empresa.count_documents({"empresaId": ObjectId(empresa1_id)})
        total_empresa2 = db.cargas_empresa.count_documents({"empresaId": ObjectId(empresa2_id)})
        
        print(f"📊 Estatísticas:")
        print(f"   - Total de cargas disponíveis: {total_disponiveis}")
        print(f"   - Cargas da empresa 1: {total_empresa1}")
        print(f"   - Cargas da empresa 2: {total_empresa2}")
        
    except Exception as e:
        print(f"❌ Erro ao criar cargas: {e}")

def main():
    """Função principal"""
    print("🚛 TruckLoad - Script de Criação de Cargas de Exemplo")
    print("=" * 60)
    
    # Conectar ao MongoDB
    db = conectar_mongodb()
    
    # Criar cargas de exemplo
    criar_cargas_exemplo(db)
    
    print("\n✅ Script executado com sucesso!")
    print("💡 Agora você pode testar a API com dados reais!")

if __name__ == "__main__":
    main()
