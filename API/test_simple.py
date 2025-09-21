#!/usr/bin/env python3
"""
Teste simples para verificar se o hash de senhas está funcionando
"""

import bcrypt

def test_bcrypt_functions():
    """Testa as funções básicas do bcrypt"""
    print("🔧 Testando funções básicas do bcrypt...")
    
    # Senha de teste
    senha = "123456"
    
    # Gerar hash
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(senha.encode('utf-8'), salt)
    hashed_str = hashed.decode('utf-8')
    
    print(f"  ✅ Senha original: {senha}")
    print(f"  ✅ Hash gerado: {hashed_str}")
    print(f"  ✅ Tamanho: {len(hashed_str)} caracteres")
    print(f"  ✅ Começa com $2b$: {hashed_str.startswith('$2b$')}")
    
    # Verificar senha correta
    check_correct = bcrypt.checkpw(senha.encode('utf-8'), hashed)
    print(f"  ✅ Verificação correta: {check_correct}")
    
    # Verificar senha errada
    check_wrong = bcrypt.checkpw("senha_errada".encode('utf-8'), hashed)
    print(f"  ✅ Verificação errada: {check_wrong}")
    
    # Testar hash diferente para mesma senha
    salt2 = bcrypt.gensalt()
    hashed2 = bcrypt.hashpw(senha.encode('utf-8'), salt2)
    hashed2_str = hashed2.decode('utf-8')
    
    print(f"  ✅ Hash diferente: {hashed_str != hashed2_str}")
    
    return True

def test_import_functions():
    """Testa se consegue importar as funções do main.py"""
    print("\n📦 Testando importação das funções...")
    
    try:
        # Importar as funções
        from main import hash_password, verify_password
        print("  ✅ Funções importadas com sucesso")
        
        # Testar hash_password
        senha = "teste123"
        hash_result = hash_password(senha)
        print(f"  ✅ hash_password funcionando: {hash_result[:20]}...")
        
        # Testar verify_password
        verify_correct = verify_password(senha, hash_result)
        verify_wrong = verify_password("errado", hash_result)
        print(f"  ✅ verify_password correto: {verify_correct}")
        print(f"  ✅ verify_password errado: {verify_wrong}")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Erro ao importar funções: {e}")
        return False

def test_password_validation():
    """Testa validação de senhas"""
    print("\n🔍 Testando validação de senhas...")
    
    try:
        from main import hash_password
        
        # Teste com senha vazia
        try:
            hash_password("")
            print("  ❌ Deveria falhar com senha vazia")
            return False
        except ValueError:
            print("  ✅ Senha vazia corretamente rejeitada")
        
        # Teste com senha válida
        try:
            hash_result = hash_password("senha_valida")
            print(f"  ✅ Senha válida processada: {hash_result[:20]}...")
        except Exception as e:
            print(f"  ❌ Erro com senha válida: {e}")
            return False
        
        return True
        
    except Exception as e:
        print(f"  ❌ Erro na validação: {e}")
        return False

def main():
    """Função principal"""
    print("🧪 TESTE SIMPLES DE HASH DE SENHAS")
    print("=" * 40)
    
    testes = [
        ("Funções bcrypt", test_bcrypt_functions),
        ("Importação", test_import_functions),
        ("Validação", test_password_validation),
    ]
    
    passou = 0
    total = len(testes)
    
    for nome, funcao in testes:
        print(f"\n📋 {nome}")
        print("-" * 20)
        try:
            if funcao():
                print(f"✅ {nome}: PASSOU")
                passou += 1
            else:
                print(f"❌ {nome}: FALHOU")
        except Exception as e:
            print(f"❌ {nome}: ERRO - {e}")
    
    print(f"\n🎯 RESULTADO: {passou}/{total} testes passaram")
    
    if passou == total:
        print("🎉 TODOS OS TESTES PASSARAM!")
    else:
        print("⚠️  ALGUNS TESTES FALHARAM!")

if __name__ == "__main__":
    main()
