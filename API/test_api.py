#!/usr/bin/env python3
"""
Script de teste para a API TruckLoad
Execute este script para verificar se todos os endpoints estão funcionando
"""

import os
import sys
import requests
import json
from datetime import datetime

# Configuração
BASE_URL = "http://localhost:8000"  # Altere para sua URL da API
TIMEOUT = 10

def test_endpoint(method, endpoint, data=None, expected_status=200):
    """Testa um endpoint da API"""
    url = f"{BASE_URL}{endpoint}"
    
    try:
        if method.upper() == "GET":
            response = requests.get(url, timeout=TIMEOUT)
        elif method.upper() == "POST":
            response = requests.post(url, json=data, timeout=TIMEOUT)
        elif method.upper() == "PATCH":
            response = requests.patch(url, json=data, timeout=TIMEOUT)
        elif method.upper() == "DELETE":
            response = requests.delete(url, timeout=TIMEOUT)
        else:
            print(f"❌ Método HTTP inválido: {method}")
            return False
        
        if response.status_code == expected_status:
            print(f"✅ {method} {endpoint} - Status: {response.status_code}")
            if response.content:
                try:
                    result = response.json()
                    if isinstance(result, dict) and len(result) > 0:
                        print(f"   Resposta: {json.dumps(result, indent=2, default=str)}")
                except:
                    print(f"   Resposta: {response.text[:100]}...")
            return True
        else:
            print(f"❌ {method} {endpoint} - Status: {response.status_code}")
            print(f"   Erro: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ {method} {endpoint} - Erro de conexão: {e}")
        return False
    except Exception as e:
        print(f"❌ {method} {endpoint} - Erro inesperado: {e}")
        return False

def main():
    """Função principal de teste"""
    print("🚛 TruckLoad - Teste da API")
    print("=" * 50)
    print(f"🔗 URL Base: {BASE_URL}")
    print(f"⏰ Início: {datetime.now().strftime('%H:%M:%S')}")
    print()
    
    # Testar health check
    print("🏥 Testando Health Check...")
    test_endpoint("GET", "/health")
    print()
    
    # Testar listagem de caminhoneiros
    print("👨‍💼 Testando Caminhoneiros...")
    test_endpoint("GET", "/caminhoneiros/")
    print()
    
    # Testar listagem de empresas
    print("🏢 Testando Empresas...")
    test_endpoint("GET", "/empresas/")
    print()
    
    # Testar login de caminhoneiro
    print("🔐 Testando Login de Caminhoneiro...")
    login_data = {
        "email": "joao.silva@email.com",
        "senha": "123456",
        "tipo": "caminhoneiro"
    }
    test_endpoint("POST", "/auth/login", login_data)
    print()
    
    # Testar login de empresa
    print("🔐 Testando Login de Empresa...")
    login_data = {
        "email": "contato@abc.com",
        "senha": "123456",
        "tipo": "empresa"
    }
    test_endpoint("POST", "/auth/login", login_data)
    print()
    
    # Testar busca de cargas disponíveis
    print("📦 Testando Busca de Cargas Disponíveis...")
    test_endpoint("GET", "/cargas/disponiveis")
    print()
    
    # Testar listagem de cargas empresariais
    print("📦 Testando Cargas Empresariais...")
    test_endpoint("GET", "/cargas-empresa/")
    print()
    
    # Testar avaliações
    print("⭐ Testando Avaliações...")
    test_endpoint("GET", "/avaliacoes/")
    print()
    
    print("=" * 50)
    print(f"⏰ Fim: {datetime.now().strftime('%H:%M:%S')}")
    print("✅ Teste concluído!")

if __name__ == "__main__":
    main()
