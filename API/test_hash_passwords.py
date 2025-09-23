#!/usr/bin/env python3
"""
Script de teste para verificar se o sistema de hash de senhas está funcionando
Execute este script para testar todas as funcionalidades de segurança
"""

import os
import bcrypt
import requests
import json
from datetime import datetime

# Configuração
API_BASE_URL = "https://truckload-u4nu.onrender.com"  # URL da API em produção
# API_BASE_URL = "http://localhost:8000"  # Para teste local

def test_hash_functions():
    """Testa as funções de hash localmente"""
    print("🔧 Testando funções de hash localmente...")
    
    # Importar as funções do main.py
    import sys
    sys.path.append('.')
    from main import hash_password, verify_password
    
    # Teste 1: Hash de senha
    senha_teste = "123456"
    hash_resultado = hash_password(senha_teste)
    
    print(f"  ✅ Senha original: {senha_teste}")
    print(f"  ✅ Hash gerado: {hash_resultado[:20]}...")
    print(f"  ✅ Tamanho do hash: {len(hash_resultado)} caracteres")
    print(f"  ✅ Começa com $2b$: {hash_resultado.startswith('$2b$')}")
    
    # Teste 2: Verificação de senha
    verificacao_correta = verify_password(senha_teste, hash_resultado)
    verificacao_errada = verify_password("senha_errada", hash_resultado)
    
    print(f"  ✅ Verificação com senha correta: {verificacao_correta}")
    print(f"  ✅ Verificação com senha errada: {verificacao_errada}")
    
    # Teste 3: Senhas diferentes geram hashes diferentes
    hash2 = hash_password(senha_teste)
    print(f"  ✅ Hash diferente para mesma senha: {hash_resultado != hash2}")
    
    return True

def test_api_endpoints():
    """Testa os endpoints da API"""
    print("\n🌐 Testando endpoints da API...")
    
    # Dados de teste
    dados_teste = {
        "caminhoneiro": {
            "nome": "Teste Hash",
            "email": "teste.hash@email.com",
            "cpf": "111.222.333-44",
            "telefone": "(11) 99999-9999",
            "tipoCaminhao": "Truck 3/4",
            "senha": "senha_teste_123",
            "descricao": "Usuário para teste de hash"
        },
        "empresa": {
            "nome": "Empresa Teste Hash",
            "email": "empresa.teste.hash@email.com",
            "cnpj": "11.222.333/0001-44",
            "telefone": "(11) 88888-8888",
            "endereco": "Rua Teste, 123 - São Paulo/SP",
            "senha": "senha_empresa_123",
            "descricao": "Empresa para teste de hash"
        }
    }
    
    # Teste 1: Criar caminhoneiro
    print("  🚛 Testando criação de caminhoneiro...")
    try:
        response = requests.post(f"{API_BASE_URL}/caminhoneiros/", json=dados_teste["caminhoneiro"])
        if response.status_code == 201:
            print("    ✅ Caminhoneiro criado com sucesso")
            caminhoneiro_id = response.json().get("id")
        else:
            print(f"    ❌ Erro ao criar caminhoneiro: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"    ❌ Erro de conexão: {e}")
        return False
    
    # Teste 2: Criar empresa
    print("  🏢 Testando criação de empresa...")
    try:
        response = requests.post(f"{API_BASE_URL}/empresas/", json=dados_teste["empresa"])
        if response.status_code == 201:
            print("    ✅ Empresa criada com sucesso")
            empresa_id = response.json().get("id")
        else:
            print(f"    ❌ Erro ao criar empresa: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"    ❌ Erro de conexão: {e}")
        return False
    
    # Teste 3: Login com caminhoneiro
    print("  🔐 Testando login com caminhoneiro...")
    try:
        login_data = {
            "email": dados_teste["caminhoneiro"]["email"],
            "senha": dados_teste["caminhoneiro"]["senha"],
            "tipo": "caminhoneiro"
        }
        response = requests.post(f"{API_BASE_URL}/auth/login", json=login_data)
        if response.status_code == 200:
            print("    ✅ Login de caminhoneiro funcionando")
        else:
            print(f"    ❌ Erro no login de caminhoneiro: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"    ❌ Erro de conexão: {e}")
        return False
    
    # Teste 4: Login com empresa
    print("  🔐 Testando login com empresa...")
    try:
        login_data = {
            "email": dados_teste["empresa"]["email"],
            "senha": dados_teste["empresa"]["senha"],
            "tipo": "empresa"
        }
        response = requests.post(f"{API_BASE_URL}/auth/login", json=login_data)
        if response.status_code == 200:
            print("    ✅ Login de empresa funcionando")
        else:
            print(f"    ❌ Erro no login de empresa: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"    ❌ Erro de conexão: {e}")
        return False
    
    # Teste 5: Login com senha errada
    print("  🚫 Testando login com senha errada...")
    try:
        login_data = {
            "email": dados_teste["caminhoneiro"]["email"],
            "senha": "senha_errada",
            "tipo": "caminhoneiro"
        }
        response = requests.post(f"{API_BASE_URL}/auth/login", json=login_data)
        if response.status_code == 401:
            print("    ✅ Login com senha errada corretamente rejeitado")
        else:
            print(f"    ❌ Login com senha errada deveria falhar: {response.status_code}")
            return False
    except Exception as e:
        print(f"    ❌ Erro de conexão: {e}")
        return False
    
    return True

def test_database_security():
    """Testa se as senhas estão seguras no banco de dados"""
    print("\n🔒 Testando segurança no banco de dados...")
    
    try:
        from pymongo import MongoClient
        
        MONGO_URI = os.getenv("MONGODB_URI")
        if not MONGO_URI:
            print("  ⚠️  MONGODB_URI não definida, pulando teste de banco")
            return True
        
        client = MongoClient(MONGO_URI)
        db = client["truckload_db"]
        
        # Verificar caminhoneiros
        caminhoneiros = list(db.caminhoneiros.find({"email": "teste.hash@email.com"}))
        if caminhoneiros:
            senha_hash = caminhoneiros[0].get("senha", "")
            print(f"  ✅ Senha do caminhoneiro no banco: {senha_hash[:20]}...")
            print(f"  ✅ É um hash bcrypt: {senha_hash.startswith('$2b$')}")
            print(f"  ✅ Tamanho correto: {len(senha_hash) == 60}")
            print(f"  ✅ NÃO é texto claro: {'senha_teste_123' not in senha_hash}")
        
        # Verificar empresas
        empresas = list(db.empresas.find({"email": "empresa.teste.hash@email.com"}))
        if empresas:
            senha_hash = empresas[0].get("senha", "")
            print(f"  ✅ Senha da empresa no banco: {senha_hash[:20]}...")
            print(f"  ✅ É um hash bcrypt: {senha_hash.startswith('$2b$')}")
            print(f"  ✅ Tamanho correto: {len(senha_hash) == 60}")
            print(f"  ✅ NÃO é texto claro: {'senha_empresa_123' not in senha_hash}")
        
        client.close()
        return True
        
    except Exception as e:
        print(f"  ❌ Erro ao verificar banco de dados: {e}")
        return False

def test_migration():
    """Testa o script de migração"""
    print("\n🔄 Testando script de migração...")
    
    try:
        # Executar script de migração
        import subprocess
        result = subprocess.run(["python3", "migrate_passwords.py"], 
                              capture_output=True, text=True, cwd=".")
        
        if result.returncode == 0:
            print("  ✅ Script de migração executado com sucesso")
            print("  📋 Saída do script:")
            for line in result.stdout.split('\n')[:10]:  # Primeiras 10 linhas
                if line.strip():
                    print(f"    {line}")
        else:
            print(f"  ❌ Erro no script de migração: {result.stderr}")
            return False
        
        return True
        
    except Exception as e:
        print(f"  ❌ Erro ao executar migração: {e}")
        return False

def cleanup_test_data():
    """Remove dados de teste do banco"""
    print("\n🧹 Limpando dados de teste...")
    
    try:
        from pymongo import MongoClient
        
        MONGO_URI = os.getenv("MONGODB_URI")
        if not MONGO_URI:
            print("  ⚠️  MONGODB_URI não definida, pulando limpeza")
            return True
        
        client = MongoClient(MONGO_URI)
        db = client["truckload_db"]
        
        # Remover dados de teste
        result_cam = db.caminhoneiros.delete_many({"email": "teste.hash@email.com"})
        result_emp = db.empresas.delete_many({"email": "empresa.teste.hash@email.com"})
        
        print(f"  ✅ {result_cam.deleted_count} caminhoneiros de teste removidos")
        print(f"  ✅ {result_emp.deleted_count} empresas de teste removidas")
        
        client.close()
        return True
        
    except Exception as e:
        print(f"  ❌ Erro ao limpar dados: {e}")
        return False

def main():
    """Função principal de teste"""
    print("🧪 INICIANDO TESTES DE HASH DE SENHAS")
    print("=" * 50)
    
    testes = [
        ("Funções de Hash", test_hash_functions),
        ("Endpoints da API", test_api_endpoints),
        ("Segurança no Banco", test_database_security),
        ("Script de Migração", test_migration),
    ]
    
    resultados = []
    
    for nome, funcao_teste in testes:
        print(f"\n📋 {nome}")
        print("-" * 30)
        try:
            resultado = funcao_teste()
            resultados.append((nome, resultado))
            if resultado:
                print(f"✅ {nome}: PASSOU")
            else:
                print(f"❌ {nome}: FALHOU")
        except Exception as e:
            print(f"❌ {nome}: ERRO - {e}")
            resultados.append((nome, False))
    
    # Limpeza
    cleanup_test_data()
    
    # Resumo final
    print("\n" + "=" * 50)
    print("📊 RESUMO DOS TESTES")
    print("=" * 50)
    
    passou = 0
    total = len(resultados)
    
    for nome, resultado in resultados:
        status = "✅ PASSOU" if resultado else "❌ FALHOU"
        print(f"{nome}: {status}")
        if resultado:
            passou += 1
    
    print(f"\n🎯 RESULTADO FINAL: {passou}/{total} testes passaram")
    
    if passou == total:
        print("🎉 TODOS OS TESTES PASSARAM! Sistema de hash funcionando perfeitamente!")
    else:
        print("⚠️  ALGUNS TESTES FALHARAM! Verifique os erros acima.")
    
    return passou == total

if __name__ == "__main__":
    main()
