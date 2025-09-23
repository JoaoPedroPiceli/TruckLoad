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
    """Cria cargas de exemplo para as empresas reais"""
    
    print("📦 Criando cargas de exemplo para empresas reais...")
    
    # Obter IDs das empresas reais
    empresa1_id = obter_empresa_id(db, "piceli@gmail.com")
    empresa2_id = obter_empresa_id(db, "Piceli.Piceli@gmail.com")
    
    if not empresa1_id:
        print("❌ Erro: Empresa 'piceli@gmail.com' não encontrada.")
        return
    
    if not empresa2_id:
        print("❌ Erro: Empresa 'Piceli.Piceli@gmail.com' não encontrada.")
        return
    
    print(f"✅ Empresa 1 encontrada: {empresa1_id}")
    print(f"✅ Empresa 2 encontrada: {empresa2_id}")
    
    # Cargas para a empresa 1 (piceli@gmail.com)
    cargas_empresa1 = [
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Transporte de Eletrônicos para Loja",
            "descricao": "Carga de smartphones, notebooks e tablets para loja de varejo. Requer cuidado especial no manuseio e embalagem adequada.",
            "tipoCarga": "Eletrônicos",
            "origem": "São Paulo, SP",
            "destino": "Rio de Janeiro, RJ",
            "peso": 1200.0,
            "preco": 2800.00,
            "data": datetime.now() + timedelta(days=3),
            "status": "disponivel",
            "regras": "Manuseio cuidadoso, embalagem original preservada",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Carga de Roupas para Shopping",
            "descricao": "Transporte de roupas de verão para loja de departamentos. Carga seca e leve, mas volumosa.",
            "tipoCarga": "Têxtil",
            "origem": "São Paulo, SP",
            "destino": "Curitiba, PR",
            "peso": 800.0,
            "preco": 1800.00,
            "data": datetime.now() + timedelta(days=5),
            "status": "em_transito",
            "regras": "Proteger da umidade, empilhamento máximo 2m",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Móveis para Escritório Corporativo",
            "descricao": "Transporte de mesas, cadeiras e armários para escritório. Requer embalagem adequada e montagem no destino.",
            "tipoCarga": "Móveis",
            "origem": "São Paulo, SP",
            "destino": "Belo Horizonte, MG",
            "peso": 2500.0,
            "preco": 4200.00,
            "data": datetime.now() + timedelta(days=2),
            "status": "concluida",
            "regras": "Embalagem individual, proteção contra arranhões",
            "created_at": datetime.utcnow() - timedelta(days=5)
        },
        {
            "empresaId": ObjectId(empresa1_id),
            "titulo": "Produtos de Higiene para Farmácia",
            "descricao": "Transporte de produtos de higiene pessoal e limpeza para rede de farmácias.",
            "tipoCarga": "Higiene",
            "origem": "São Paulo, SP",
            "destino": "Campinas, SP",
            "peso": 600.0,
            "preco": 1200.00,
            "data": datetime.now() + timedelta(days=1),
            "status": "disponivel",
            "regras": "Proteger da umidade, temperatura ambiente",
            "created_at": datetime.utcnow()
        }
    ]
    
    # Cargas para a empresa 2 (Piceli.Piceli@gmail.com)
    cargas_empresa2 = [
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Produtos Químicos Industriais",
            "descricao": "Transporte de produtos químicos para indústria. Requer documentação especial e certificados de segurança.",
            "tipoCarga": "Químicos",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Salvador, BA",
            "peso": 3000.0,
            "preco": 5500.00,
            "data": datetime.now() + timedelta(days=7),
            "status": "disponivel",
            "regras": "Documentação completa, transporte especializado",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Alimentos Perecíveis para Supermercado",
            "descricao": "Transporte de frutas, verduras e laticínios. Requer refrigeração e controle de temperatura.",
            "tipoCarga": "Alimentos",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Brasília, DF",
            "peso": 1500.0,
            "preco": 3200.00,
            "data": datetime.now() + timedelta(days=1),
            "status": "em_transito",
            "regras": "Refrigeração constante, entrega urgente",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Máquinas Industriais Pesadas",
            "descricao": "Transporte de máquinas para fábrica. Requer equipamento especializado e rota planejada.",
            "tipoCarga": "Máquinas",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Porto Alegre, RS",
            "peso": 8000.0,
            "preco": 12000.00,
            "data": datetime.now() + timedelta(days=10),
            "status": "disponivel",
            "regras": "Equipamento especializado, rota autorizada",
            "created_at": datetime.utcnow()
        },
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Material de Construção para Obra",
            "descricao": "Transporte de cimento, tijolos e ferragens para canteiro de obras.",
            "tipoCarga": "Construção",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Niterói, RJ",
            "peso": 4000.0,
            "preco": 2800.00,
            "data": datetime.now() + timedelta(days=2),
            "status": "concluida",
            "regras": "Proteger da umidade, empilhamento adequado",
            "created_at": datetime.utcnow() - timedelta(days=3)
        },
        {
            "empresaId": ObjectId(empresa2_id),
            "titulo": "Equipamentos Médicos para Hospital",
            "descricao": "Transporte de equipamentos médicos delicados. Requer cuidado extremo e certificados.",
            "tipoCarga": "Médico",
            "origem": "Rio de Janeiro, RJ",
            "destino": "Vitória, ES",
            "peso": 800.0,
            "preco": 4500.00,
            "data": datetime.now() + timedelta(days=4),
            "status": "disponivel",
            "regras": "Manuseio delicado, certificados obrigatórios",
            "created_at": datetime.utcnow()
        }
    ]
    
    # Limpar cargas existentes para evitar duplicação
    print("🧹 Limpando cargas existentes...")
    db.cargas_empresa.delete_many({})
    
    # Inserir cargas
    todas_cargas = cargas_empresa1 + cargas_empresa2
    
    try:
        resultado = db.cargas_empresa.insert_many(todas_cargas)
        print(f"✅ {len(resultado.inserted_ids)} cargas criadas com sucesso!")
        
        # Mostrar estatísticas detalhadas
        total_disponiveis = db.cargas_empresa.count_documents({"status": "disponivel"})
        total_em_transito = db.cargas_empresa.count_documents({"status": "em_transito"})
        total_concluidas = db.cargas_empresa.count_documents({"status": "concluida"})
        total_empresa1 = db.cargas_empresa.count_documents({"empresaId": ObjectId(empresa1_id)})
        total_empresa2 = db.cargas_empresa.count_documents({"empresaId": ObjectId(empresa2_id)})
        
        print(f"\n📊 Estatísticas das Cargas:")
        print(f"   - Total de cargas: {len(todas_cargas)}")
        print(f"   - Status 'disponivel': {total_disponiveis}")
        print(f"   - Status 'em_transito': {total_em_transito}")
        print(f"   - Status 'concluida': {total_concluidas}")
        print(f"   - Cargas da empresa 1 (piceli@gmail.com): {total_empresa1}")
        print(f"   - Cargas da empresa 2 (Piceli.Piceli@gmail.com): {total_empresa2}")
        
        print(f"\n🏢 Cargas por Empresa:")
        print(f"   Empresa 1 - piceli@gmail.com:")
        for i, carga in enumerate(cargas_empresa1, 1):
            print(f"     {i}. {carga['titulo']} - Status: {carga['status']} - R$ {carga['preco']:.2f}")
        
        print(f"\n   Empresa 2 - Piceli.Piceli@gmail.com:")
        for i, carga in enumerate(cargas_empresa2, 1):
            print(f"     {i}. {carga['titulo']} - Status: {carga['status']} - R$ {carga['preco']:.2f}")
        
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
    print("💡 Agora você pode testar o app com dados reais de cargas!")
    print("📱 Teste as telas de 'Cargas Realizadas' e 'Cargas Pendentes' no app!")

if __name__ == "__main__":
    main()
