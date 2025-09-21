#!/usr/bin/env python3
"""
Script de teste para verificar se a funcionalidade de verificação de email está funcionando
"""

import requests
import json
from datetime import datetime

# Configuração
API_BASE_URL = "https://truckload-u4nu.onrender.com"
# API_BASE_URL = "http://localhost:8000"  # Para teste local

def test_email_verification_endpoint():
    """Testa o endpoint de verificação de email"""
    print("🔍 Testando endpoint de verificação de email...")
    
    # Casos de teste
    test_cases = [
        {
            "email": "teste@email.com",
            "description": "Email válido e disponível",
            "expected_valid": True,
            "expected_available": True
        },
        {
            "email": "teste.hash.api@email.com",
            "description": "Email já cadastrado (caminhoneiro)",
            "expected_valid": True,
            "expected_available": False
        },
        {
            "email": "empresa.teste.hash@email.com",
            "description": "Email já cadastrado (empresa)",
            "expected_valid": True,
            "expected_available": False
        },
        {
            "email": "email_invalido",
            "description": "Email com formato inválido",
            "expected_valid": False,
            "expected_available": False
        },
        {
            "email": "teste@dominio_inexistente_12345.com",
            "description": "Email com domínio inexistente",
            "expected_valid": False,
            "expected_available": False
        },
        {
            "email": "usuario@gmail.com",
            "description": "Email válido do Gmail",
            "expected_valid": True,
            "expected_available": True
        },
        {
            "email": "empresa@outlook.com",
            "description": "Email válido do Outlook",
            "expected_valid": True,
            "expected_available": True
        }
    ]
    
    results = []
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n  📧 Teste {i}: {test_case['description']}")
        print(f"     Email: {test_case['email']}")
        
        try:
            response = requests.post(
                f"{API_BASE_URL}/auth/verify-email",
                json={"email": test_case["email"]},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"     ✅ Status: {response.status_code}")
                print(f"     ✅ Válido: {data['is_valid']}")
                print(f"     ✅ Disponível: {data['is_available']}")
                print(f"     ✅ Mensagem: {data['message']}")
                if data.get('domain'):
                    print(f"     ✅ Domínio: {data['domain']}")
                
                # Verificar se o resultado está conforme esperado
                valid_match = data['is_valid'] == test_case['expected_valid']
                available_match = data['is_available'] == test_case['expected_available']
                
                if valid_match and available_match:
                    print(f"     ✅ RESULTADO: PASSOU")
                    results.append(True)
                else:
                    print(f"     ❌ RESULTADO: FALHOU")
                    print(f"        Esperado: válido={test_case['expected_valid']}, disponível={test_case['expected_available']}")
                    print(f"        Obtido: válido={data['is_valid']}, disponível={data['is_available']}")
                    results.append(False)
            else:
                print(f"     ❌ Erro HTTP: {response.status_code}")
                print(f"     ❌ Resposta: {response.text}")
                results.append(False)
                
        except requests.exceptions.RequestException as e:
            print(f"     ❌ Erro de conexão: {e}")
            results.append(False)
        except Exception as e:
            print(f"     ❌ Erro inesperado: {e}")
            results.append(False)
    
    return results

def test_user_creation_with_email_validation():
    """Testa criação de usuários com validação de email"""
    print("\n👤 Testando criação de usuários com validação de email...")
    
    # Teste 1: Criar caminhoneiro com email válido
    print("\n  🚛 Teste: Criar caminhoneiro com email válido")
    try:
        dados_caminhoneiro = {
            "nome": "Teste Email Validação",
            "email": "teste.email.validacao@email.com",
            "cpf": "111.222.333-55",
            "telefone": "(11) 99999-9999",
            "tipoCaminhao": "Truck 3/4",
            "senha": "senha_teste_123",
            "descricao": "Teste de validação de email"
        }
        
        response = requests.post(f"{API_BASE_URL}/caminhoneiros/", json=dados_caminhoneiro)
        
        if response.status_code == 201:
            print("    ✅ Caminhoneiro criado com sucesso")
            caminhoneiro_id = response.json().get("id")
        else:
            print(f"    ❌ Erro ao criar caminhoneiro: {response.status_code}")
            print(f"    ❌ Resposta: {response.text}")
            return False
            
    except Exception as e:
        print(f"    ❌ Erro: {e}")
        return False
    
    # Teste 2: Tentar criar caminhoneiro com email já cadastrado
    print("\n  🚫 Teste: Tentar criar caminhoneiro com email já cadastrado")
    try:
        response = requests.post(f"{API_BASE_URL}/caminhoneiros/", json=dados_caminhoneiro)
        
        if response.status_code == 400:
            print("    ✅ Email duplicado corretamente rejeitado")
            print(f"    ✅ Mensagem: {response.json().get('detail', 'N/A')}")
        else:
            print(f"    ❌ Deveria rejeitar email duplicado: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"    ❌ Erro: {e}")
        return False
    
    # Teste 3: Tentar criar caminhoneiro com email inválido
    print("\n  🚫 Teste: Tentar criar caminhoneiro com email inválido")
    try:
        dados_invalidos = dados_caminhoneiro.copy()
        dados_invalidos["email"] = "email_invalido_sem_arroba"
        dados_invalidos["cpf"] = "111.222.333-66"  # CPF diferente
        
        response = requests.post(f"{API_BASE_URL}/caminhoneiros/", json=dados_invalidos)
        
        if response.status_code == 400:
            print("    ✅ Email inválido corretamente rejeitado")
            print(f"    ✅ Mensagem: {response.json().get('detail', 'N/A')}")
        else:
            print(f"    ❌ Deveria rejeitar email inválido: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"    ❌ Erro: {e}")
        return False
    
    return True

def test_email_case_insensitive():
    """Testa se o sistema trata emails como case-insensitive"""
    print("\n🔤 Testando case-insensitive para emails...")
    
    # Teste 1: Verificar email em maiúsculas
    print("  📧 Teste: Email em maiúsculas")
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/verify-email",
            json={"email": "TESTE.EMAIL.VALIDACAO@EMAIL.COM"}
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"    ✅ Email normalizado: {data['email']}")
            print(f"    ✅ Válido: {data['is_valid']}")
            print(f"    ✅ Disponível: {data['is_available']}")
        else:
            print(f"    ❌ Erro: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"    ❌ Erro: {e}")
        return False
    
    return True

def main():
    """Função principal de teste"""
    print("🧪 TESTE DE VERIFICAÇÃO DE EMAIL")
    print("=" * 50)
    
    testes = [
        ("Endpoint de Verificação", test_email_verification_endpoint),
        ("Criação de Usuários", test_user_creation_with_email_validation),
        ("Case-Insensitive", test_email_case_insensitive),
    ]
    
    resultados = []
    
    for nome, funcao_teste in testes:
        print(f"\n📋 {nome}")
        print("-" * 30)
        try:
            resultado = funcao_teste()
            if isinstance(resultado, list):
                # Para o teste de endpoint que retorna lista
                passou = sum(resultado)
                total = len(resultado)
                print(f"\n  📊 Resultado: {passou}/{total} testes passaram")
                resultados.append(passou == total)
            else:
                # Para outros testes que retornam boolean
                if resultado:
                    print(f"✅ {nome}: PASSOU")
                    resultados.append(True)
                else:
                    print(f"❌ {nome}: FALHOU")
                    resultados.append(False)
        except Exception as e:
            print(f"❌ {nome}: ERRO - {e}")
            resultados.append(False)
    
    # Resumo final
    print("\n" + "=" * 50)
    print("📊 RESUMO DOS TESTES")
    print("=" * 50)
    
    passou = sum(resultados)
    total = len(resultados)
    
    print(f"🎯 RESULTADO FINAL: {passou}/{total} testes passaram")
    
    if passou == total:
        print("🎉 TODOS OS TESTES PASSARAM!")
        print("📧 Sistema de verificação de email funcionando perfeitamente!")
    else:
        print("⚠️  ALGUNS TESTES FALHARAM!")
    
    return passou == total

if __name__ == "__main__":
    main()
