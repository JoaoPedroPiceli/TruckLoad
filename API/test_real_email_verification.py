#!/usr/bin/env python3
"""
Script de teste para verificar se a funcionalidade de verificação real de email está funcionando
"""

import requests
import json
from datetime import datetime

# Configuração
API_BASE_URL = "https://truckload-u4nu.onrender.com"

def test_basic_email_verification():
    """Testa verificação básica de email"""
    print("🔍 Testando verificação básica de email...")
    
    test_cases = [
        {
            "email": "teste@gmail.com",
            "description": "Email válido do Gmail",
            "expected_valid": True
        },
        {
            "email": "teste@outlook.com",
            "description": "Email válido do Outlook",
            "expected_valid": True
        },
        {
            "email": "email_invalido",
            "description": "Email com formato inválido",
            "expected_valid": False
        },
        {
            "email": "teste@dominio_inexistente_12345.com",
            "description": "Email com domínio inexistente",
            "expected_valid": False
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
                timeout=15
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
                
                if valid_match:
                    print(f"     ✅ RESULTADO: PASSOU")
                    results.append(True)
                else:
                    print(f"     ❌ RESULTADO: FALHOU")
                    print(f"        Esperado: válido={test_case['expected_valid']}")
                    print(f"        Obtido: válido={data['is_valid']}")
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

def test_real_email_verification():
    """Testa verificação real de email com SMTP"""
    print("\n🔍 Testando verificação real de email...")
    
    test_cases = [
        {
            "email": "teste@gmail.com",
            "check_smtp": True,
            "description": "Email do Gmail com verificação SMTP"
        },
        {
            "email": "teste@outlook.com",
            "check_smtp": True,
            "description": "Email do Outlook com verificação SMTP"
        },
        {
            "email": "teste@email.com",
            "check_smtp": False,
            "description": "Email sem verificação SMTP"
        }
    ]
    
    results = []
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n  📧 Teste {i}: {test_case['description']}")
        print(f"     Email: {test_case['email']}")
        print(f"     SMTP: {test_case['check_smtp']}")
        
        try:
            response = requests.post(
                f"{API_BASE_URL}/auth/verify-email-real",
                json={
                    "email": test_case["email"],
                    "check_smtp": test_case["check_smtp"]
                },
                timeout=30  # Timeout maior para verificação SMTP
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"     ✅ Status: {response.status_code}")
                print(f"     ✅ Válido: {data['is_valid']}")
                print(f"     ✅ Disponível: {data['is_available']}")
                print(f"     ✅ Mensagem: {data['message']}")
                if data.get('domain'):
                    print(f"     ✅ Domínio: {data['domain']}")
                if data.get('is_real') is not None:
                    print(f"     ✅ Real: {data['is_real']}")
                    print(f"     ✅ Mensagem Real: {data['real_message']}")
                
                print(f"     ✅ RESULTADO: PASSOU")
                results.append(True)
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

def test_domain_verification():
    """Testa verificação de domínios específicos"""
    print("\n🌐 Testando verificação de domínios...")
    
    domains_to_test = [
        "gmail.com",
        "outlook.com",
        "hotmail.com",
        "yahoo.com",
        "email.com",
        "dominio_inexistente_12345.com"
    ]
    
    results = []
    
    for domain in domains_to_test:
        email = f"teste@{domain}"
        print(f"\n  📧 Testando domínio: {domain}")
        
        try:
            response = requests.post(
                f"{API_BASE_URL}/auth/verify-email",
                json={"email": email},
                timeout=15
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"     ✅ Válido: {data['is_valid']}")
                print(f"     ✅ Mensagem: {data['message']}")
                
                # Para domínios conhecidos, esperamos que sejam válidos
                if domain in ["gmail.com", "outlook.com", "hotmail.com", "yahoo.com", "email.com"]:
                    if data['is_valid']:
                        print(f"     ✅ RESULTADO: PASSOU")
                        results.append(True)
                    else:
                        print(f"     ❌ RESULTADO: FALHOU - Domínio conhecido deveria ser válido")
                        results.append(False)
                else:
                    # Para domínios inexistentes, esperamos que sejam inválidos
                    if not data['is_valid']:
                        print(f"     ✅ RESULTADO: PASSOU")
                        results.append(True)
                    else:
                        print(f"     ❌ RESULTADO: FALHOU - Domínio inexistente deveria ser inválido")
                        results.append(False)
            else:
                print(f"     ❌ Erro HTTP: {response.status_code}")
                results.append(False)
                
        except Exception as e:
            print(f"     ❌ Erro: {e}")
            results.append(False)
    
    return results

def test_user_creation_with_real_verification():
    """Testa criação de usuários com verificação real"""
    print("\n👤 Testando criação de usuários com verificação real...")
    
    # Teste 1: Criar usuário com email válido
    print("\n  🚛 Teste: Criar usuário com email válido")
    try:
        dados_usuario = {
            "nome": "Teste Verificação Real",
            "email": "teste.verificacao.real@gmail.com",
            "cpf": "111.222.333-88",
            "telefone": "(11) 99999-9999",
            "tipoCaminhao": "Truck 3/4",
            "senha": "senha_teste_123",
            "descricao": "Teste de verificação real de email"
        }
        
        response = requests.post(f"{API_BASE_URL}/caminhoneiros/", json=dados_usuario)
        
        if response.status_code == 201:
            print("    ✅ Usuário criado com sucesso")
            print(f"    ✅ ID: {response.json().get('id')}")
        else:
            print(f"    ❌ Erro ao criar usuário: {response.status_code}")
            print(f"    ❌ Resposta: {response.text}")
            return False
            
    except Exception as e:
        print(f"    ❌ Erro: {e}")
        return False
    
    return True

def main():
    """Função principal de teste"""
    print("🧪 TESTE DE VERIFICAÇÃO REAL DE EMAIL")
    print("=" * 50)
    
    testes = [
        ("Verificação Básica", test_basic_email_verification),
        ("Verificação Real", test_real_email_verification),
        ("Verificação de Domínios", test_domain_verification),
        ("Criação de Usuários", test_user_creation_with_real_verification),
    ]
    
    resultados = []
    
    for nome, funcao_teste in testes:
        print(f"\n📋 {nome}")
        print("-" * 30)
        try:
            resultado = funcao_teste()
            if isinstance(resultado, list):
                # Para testes que retornam lista
                passou = sum(resultado)
                total = len(resultado)
                print(f"\n  📊 Resultado: {passou}/{total} testes passaram")
                resultados.append(passou == total)
            else:
                # Para testes que retornam boolean
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
        print("📧 Sistema de verificação real de email funcionando perfeitamente!")
    else:
        print("⚠️  ALGUNS TESTES FALHARAM!")
    
    return passou == total

if __name__ == "__main__":
    main()
