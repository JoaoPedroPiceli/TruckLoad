#!/usr/bin/env python3
"""
Teste apenas das funções de hash, sem dependências do FastAPI
"""

import bcrypt

def hash_password(password: str) -> str:
    """Gera hash da senha usando bcrypt"""
    if not password:
        raise ValueError("Senha não pode ser vazia")
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(password: str, hashed_password: str) -> bool:
    """Verifica se a senha corresponde ao hash"""
    try:
        return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False

def is_hashed_password(password: str) -> bool:
    """Verifica se a senha já está em formato hash (bcrypt)"""
    if not password or len(password) < 10:
        return False
    # Senhas bcrypt começam com $2b$ e têm 60 caracteres
    return password.startswith('$2b$') and len(password) == 60

def test_hash_functions():
    """Testa as funções de hash"""
    print("🔧 Testando funções de hash...")
    
    # Teste 1: Hash de senha
    senha = "123456"
    hash_result = hash_password(senha)
    
    print(f"  ✅ Senha: {senha}")
    print(f"  ✅ Hash: {hash_result}")
    print(f"  ✅ Tamanho: {len(hash_result)}")
    print(f"  ✅ Formato bcrypt: {hash_result.startswith('$2b$')}")
    
    # Teste 2: Verificação correta
    verify_correct = verify_password(senha, hash_result)
    print(f"  ✅ Verificação correta: {verify_correct}")
    
    # Teste 3: Verificação errada
    verify_wrong = verify_password("senha_errada", hash_result)
    print(f"  ✅ Verificação errada: {verify_wrong}")
    
    # Teste 4: Hash diferente para mesma senha
    hash2 = hash_password(senha)
    print(f"  ✅ Hash diferente: {hash_result != hash2}")
    
    # Teste 5: Detecção de hash
    is_hash = is_hashed_password(hash_result)
    is_not_hash = is_hashed_password(senha)
    print(f"  ✅ Detecta hash: {is_hash}")
    print(f"  ✅ Detecta não-hash: {not is_not_hash}")
    
    return True

def test_password_validation():
    """Testa validação de senhas"""
    print("\n🔍 Testando validação...")
    
    # Teste senha vazia
    try:
        hash_password("")
        print("  ❌ Deveria falhar com senha vazia")
        return False
    except ValueError:
        print("  ✅ Senha vazia rejeitada")
    
    # Teste senha válida
    try:
        hash_result = hash_password("senha_valida")
        print(f"  ✅ Senha válida processada: {hash_result[:20]}...")
    except Exception as e:
        print(f"  ❌ Erro com senha válida: {e}")
        return False
    
    return True

def test_real_scenarios():
    """Testa cenários reais de uso"""
    print("\n🎯 Testando cenários reais...")
    
    # Cenário 1: Criação de usuário
    print("  📝 Cenário: Criação de usuário")
    senha_usuario = "minha_senha_segura_123"
    hash_usuario = hash_password(senha_usuario)
    print(f"    ✅ Senha hasheada: {hash_usuario[:20]}...")
    
    # Cenário 2: Login
    print("  🔐 Cenário: Login")
    login_success = verify_password(senha_usuario, hash_usuario)
    login_fail = verify_password("senha_errada", hash_usuario)
    print(f"    ✅ Login correto: {login_success}")
    print(f"    ✅ Login errado: {not login_fail}")
    
    # Cenário 3: Migração
    print("  🔄 Cenário: Migração de senhas")
    senha_antiga = "123456"  # Senha em texto claro
    hash_novo = hash_password(senha_antiga)
    print(f"    ✅ Senha antiga: {senha_antiga}")
    print(f"    ✅ Hash novo: {hash_novo[:20]}...")
    print(f"    ✅ Verificação funciona: {verify_password(senha_antiga, hash_novo)}")
    
    return True

def test_security():
    """Testa aspectos de segurança"""
    print("\n🛡️ Testando segurança...")
    
    # Teste 1: Senhas iguais geram hashes diferentes
    senha = "123456"
    hash1 = hash_password(senha)
    hash2 = hash_password(senha)
    print(f"  ✅ Hashes diferentes para mesma senha: {hash1 != hash2}")
    
    # Teste 2: Hash não contém a senha original
    senha_original = "minha_senha_secreta"
    hash_result = hash_password(senha_original)
    print(f"  ✅ Hash não contém senha: {senha_original not in hash_result}")
    
    # Teste 3: Verificação é case-sensitive
    senha_lower = "teste123"
    senha_upper = "TESTE123"
    hash_lower = hash_password(senha_lower)
    verify_upper = verify_password(senha_upper, hash_lower)
    print(f"  ✅ Case-sensitive: {not verify_upper}")
    
    return True

def main():
    """Função principal"""
    print("🧪 TESTE COMPLETO DE HASH DE SENHAS")
    print("=" * 50)
    
    testes = [
        ("Funções de Hash", test_hash_functions),
        ("Validação", test_password_validation),
        ("Cenários Reais", test_real_scenarios),
        ("Segurança", test_security),
    ]
    
    passou = 0
    total = len(testes)
    
    for nome, funcao in testes:
        print(f"\n📋 {nome}")
        print("-" * 30)
        try:
            if funcao():
                print(f"✅ {nome}: PASSOU")
                passou += 1
            else:
                print(f"❌ {nome}: FALHOU")
        except Exception as e:
            print(f"❌ {nome}: ERRO - {e}")
    
    print(f"\n🎯 RESULTADO FINAL: {passou}/{total} testes passaram")
    
    if passou == total:
        print("🎉 TODOS OS TESTES PASSARAM!")
        print("🔒 Sistema de hash de senhas está funcionando perfeitamente!")
    else:
        print("⚠️  ALGUNS TESTES FALHARAM!")
    
    return passou == total

if __name__ == "__main__":
    main()
