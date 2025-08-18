# =============================================================================
# TruckLoad API v1.5.0
# =============================================================================
# Changelog:
# - v1.5.0: Cargas de exemplo automáticas para empresas, sistema completo de gestão
# - v1.4.0: Sistema de autenticação melhorado, senhas padrão para usuários existentes
# - v1.3.0: Cargas empresariais, busca de cargas disponíveis, perfil agregado
# - v1.2.0: CRUD completo para caminhoneiros e empresas
# - v1.1.0: Endpoints básicos e conexão MongoDB
# - v1.0.0: Estrutura inicial
# =============================================================================
# API/main.py
from fastapi import FastAPI, HTTPException, Path, Body, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Literal, List
from datetime import datetime, timedelta
from bson import ObjectId
from pymongo import MongoClient, ASCENDING, DESCENDING
from pymongo.errors import DuplicateKeyError
import os

# =============================================================================
# App & CORS
# =============================================================================
app = FastAPI(title="TruckLoad API", version="1.3.0")

# Em produção, restrinja os domínios em allow_origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =============================================================================
# MongoDB
# =============================================================================
MONGO_URI = os.getenv("MONGODB_URI")
if not MONGO_URI:
    raise RuntimeError("Defina a variável de ambiente MONGODB_URI no Render.")

client = MongoClient(MONGO_URI)
db = client["truckload_db"]

def ensure_indexes():
    db.caminhoneiros.create_index(
        [("email", ASCENDING)], unique=True, name="uniq_email_caminhoneiro"
    )
    db.empresas.create_index(
        [("email", ASCENDING)], unique=True, name="uniq_email_empresa"
    )
    db.avaliacoes.create_index(
        [("caminhoneiroId", ASCENDING), ("created_at", DESCENDING)],
        name="idx_av_caminhoneiro_data"
    )
    db.cargas.create_index(
        [("caminhoneiroId", ASCENDING), ("status", ASCENDING)],
        name="idx_cg_caminhoneiro_status"
    )
    db.cargas_empresa.create_index(
        [("empresaId", ASCENDING), ("status", ASCENDING)],
        name="idx_cg_empresa_status"
    )

@app.on_event("startup")
def on_startup():
    ensure_indexes()
    # Criar dados de exemplo se não existirem
    criar_dados_exemplo()

# =============================================================================
# Utils
# =============================================================================
def is_valid_objectid(s: str) -> bool:
    try:
        ObjectId(s)
        return True
    except Exception:
        return False

def to_objid(s: str) -> ObjectId:
    if not is_valid_objectid(s):
        raise HTTPException(status_code=400, detail="ID inválido")
    return ObjectId(s)

def to_public(doc: dict) -> dict:
    """Remove campos sensíveis e converte _id -> id antes de devolver."""
    d = dict(doc)
    d["id"] = str(d.pop("_id"))
    # Remova a linha abaixo se por algum motivo quiser devolver a senha (não recomendado)
    d.pop("senha", None)
    return d

# =============================================================================
# Dados de Exemplo
# =============================================================================
def criar_dados_exemplo():
    """Cria dados de exemplo se as coleções estiverem vazias"""
    
    print("Verificando e atualizando dados de exemplo...")
    
    # Atualizar caminhoneiros existentes com senhas padrão
    caminhoneiros_sem_senha = db.caminhoneiros.find({"senha": {"$exists": False}})
    for caminhoneiro in caminhoneiros_sem_senha:
        db.caminhoneiros.update_one(
            {"_id": caminhoneiro["_id"]},
            {"$set": {"senha": "123456"}}
        )
        print(f"Senha adicionada para caminhoneiro: {caminhoneiro.get('email', 'N/A')}")
    
    # Atualizar empresas existentes com senhas padrão
    empresas_sem_senha = db.empresas.find({"senha": {"$exists": False}})
    for empresa in empresas_sem_senha:
        db.empresas.update_one(
            {"_id": empresa["_id"]},
            {"$set": {"senha": "123456"}}
        )
        print(f"Senha adicionada para empresa: {empresa.get('email', 'N/A')}")
    
    # Verificar se já existem dados de exemplo
    if db.caminhoneiros.count_documents({}) > 0 and db.empresas.count_documents({}) > 0:
        print("Dados existem, apenas senhas foram atualizadas.")
        
        # Criar cargas de exemplo para empresas existentes
        criar_cargas_exemplo_empresas()
        return
    
    print("Criando dados de exemplo...")
    
    # Caminhoneiros de exemplo
    caminhoneiros_exemplo = [
        {
            "nome": "João Silva",
            "email": "joao.silva@email.com",
            "cpf": "123.456.789-00",
            "telefone": "(11) 99999-9999",
            "tipoCaminhao": "Truck 3/4",
            "senha": "123456",
            "descricao": "Motorista experiente com 10 anos de estrada",
            "fotoUrl": None,
            "data_cadastro": datetime.utcnow()
        },
        {
            "nome": "Maria Santos",
            "email": "maria.santos@email.com",
            "cpf": "987.654.321-00",
            "telefone": "(21) 88888-8888",
            "tipoCaminhao": "Carreta",
            "senha": "123456",
            "descricao": "Especialista em cargas refrigeradas",
            "fotoUrl": None,
            "data_cadastro": datetime.utcnow()
        }
    ]
    
    # Empresas de exemplo
    empresas_exemplo = [
        {
            "nome": "Transportes ABC Ltda",
            "email": "contato@abc.com",
            "cnpj": "12.345.678/0001-90",
            "telefone": "(11) 3333-3333",
            "endereco": "Rua das Flores, 123 - São Paulo/SP",
            "senha": "123456",
            "descricao": "Empresa especializada em transporte de cargas gerais",
            "fotoUrl": None,
            "data_cadastro": datetime.utcnow()
        },
        {
            "nome": "Logística XYZ",
            "email": "contato@xyz.com",
            "cnpj": "98.765.432/0001-10",
            "telefone": "(21) 4444-4444",
            "endereco": "Av. Principal, 456 - Rio de Janeiro/RJ",
            "senha": "123456",
            "descricao": "Soluções logísticas integradas",
            "fotoUrl": None,
            "data_cadastro": datetime.utcnow()
        }
    ]
    
    # Inserir caminhoneiros
    for caminhoneiro in caminhoneiros_exemplo:
        try:
            db.caminhoneiros.insert_one(caminhoneiro)
        except DuplicateKeyError:
            pass
    
    # Inserir empresas
    for empresa in empresas_exemplo:
        try:
            db.empresas.insert_one(empresa)
        except DuplicateKeyError:
            pass
    
    print("Dados de exemplo criados com sucesso!")
    
    # Criar cargas de exemplo para as empresas
    criar_cargas_exemplo_empresas()

def criar_cargas_exemplo_empresas():
    """Cria cargas de exemplo para as empresas existentes"""
    
    print("Criando cargas de exemplo para empresas...")
    
    # Limpar cargas existentes para evitar duplicação
    db.cargas_empresa.delete_many({})
    
    # Obter empresas existentes
    empresas = list(db.empresas.find({}))
    if not empresas:
        print("Nenhuma empresa encontrada para criar cargas.")
        return
    
    # Criar cargas para cada empresa
    for empresa in empresas:
        empresa_id = empresa["_id"]
        empresa_email = empresa.get("email", "N/A")
        
        print(f"Criando cargas para empresa: {empresa_email}")
        
        # Cargas baseadas no email da empresa
        if "piceli@gmail.com" in empresa_email.lower():
            cargas = [
                {
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
        elif "piceli.piceli@gmail.com" in empresa_email.lower():
            cargas = [
                {
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
                    "empresaId": empresa_id,
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
        else:
            # Cargas genéricas para outras empresas
            cargas = [
                {
                    "empresaId": empresa_id,
                    "titulo": "Carga Geral",
                    "descricao": "Transporte de carga geral para empresa.",
                    "tipoCarga": "Geral",
                    "origem": "São Paulo, SP",
                    "destino": "Rio de Janeiro, RJ",
                    "peso": 1000.0,
                    "preco": 2000.00,
                    "data": datetime.now() + timedelta(days=3),
                    "status": "disponivel",
                    "regras": "Transporte padrão",
                    "created_at": datetime.utcnow()
                }
            ]
        
        # Inserir cargas da empresa
        try:
            resultado = db.cargas_empresa.insert_many(cargas)
            print(f"  ✅ {len(resultado.inserted_ids)} cargas criadas para {empresa_email}")
        except Exception as e:
            print(f"  ❌ Erro ao criar cargas para {empresa_email}: {e}")
    
    # Mostrar estatísticas finais
    total_cargas = db.cargas_empresa.count_documents({})
    total_disponiveis = db.cargas_empresa.count_documents({"status": "disponivel"})
    total_em_transito = db.cargas_empresa.count_documents({"status": "em_transito"})
    total_concluidas = db.cargas_empresa.count_documents({"status": "concluida"})
    
    print(f"\n📊 Estatísticas das Cargas Criadas:")
    print(f"   - Total de cargas: {total_cargas}")
    print(f"   - Status 'disponivel': {total_disponiveis}")
    print(f"   - Status 'em_transito': {total_em_transito}")
    print(f"   - Status 'concluida': {total_concluidas}")
    print("✅ Cargas de exemplo criadas com sucesso!")

# =============================================================================
# Schemas
# =============================================================================
class CaminhoneiroCreate(BaseModel):
    nome: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    cpf: str = Field(..., min_length=3, max_length=32)
    telefone: str = Field(..., min_length=3, max_length=32)
    tipoCaminhao: str = Field(..., min_length=2, max_length=64)
    senha: str = Field(..., min_length=1, max_length=128)
    descricao: Optional[str] = Field(None, max_length=2000)
    fotoUrl: Optional[str] = None

class CaminhoneiroUpdate(BaseModel):
    nome: Optional[str] = Field(None, min_length=2, max_length=120)
    email: Optional[EmailStr] = None
    cpf: Optional[str] = Field(None, min_length=3, max_length=32)
    telefone: Optional[str] = Field(None, min_length=3, max_length=32)
    tipoCaminhao: Optional[str] = Field(None, min_length=2, max_length=64)
    senha: Optional[str] = Field(None, min_length=1, max_length=128)
    descricao: Optional[str] = Field(None, max_length=2000)
    fotoUrl: Optional[str] = None

class EmpresaCreate(BaseModel):
    nome: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    cnpj: str = Field(..., min_length=3, max_length=32)
    telefone: str = Field(..., min_length=3, max_length=32)
    endereco: str = Field(..., min_length=3, max_length=255)
    senha: str = Field(..., min_length=1, max_length=128)
    descricao: Optional[str] = Field(None, max_length=2000)
    fotoUrl: Optional[str] = None

class EmpresaUpdate(BaseModel):
    nome: Optional[str] = Field(None, min_length=2, max_length=120)
    email: Optional[EmailStr] = None
    cnpj: Optional[str] = Field(None, min_length=3, max_length=32)
    telefone: Optional[str] = Field(None, min_length=3, max_length=32)
    endereco: Optional[str] = Field(None, min_length=3, max_length=255)
    senha: Optional[str] = Field(None, min_length=1, max_length=128)
    descricao: Optional[str] = Field(None, max_length=2000)
    fotoUrl: Optional[str] = None

class LoginPayload(BaseModel):
    email: EmailStr
    senha: str = Field(..., min_length=1)
    tipo: Literal["caminhoneiro", "empresa"]

# --- Avaliações (empresa -> caminhoneiro) ---
class AvaliacaoCreate(BaseModel):
    caminhoneiroId: str = Field(..., description="ObjectId do caminhoneiro")
    empresaId: Optional[str] = Field(None, description="ObjectId da empresa")
    nota: float = Field(..., ge=0, le=5)
    comentario: Optional[str] = Field(None, max_length=2000)

# --- Cargas (para métricas de cancelamento) ---
class CargaCreate(BaseModel):
    caminhoneiroId: str
    empresaId: Optional[str] = None
    status: Literal[
        "pendente",
        "aceita",
        "concluida",
        "cancelada_pelo_motorista",
        "cancelada_pela_empresa",
    ] = "pendente"
    titulo: Optional[str] = None

class CargaUpdate(BaseModel):
    status: Optional[
        Literal[
            "pendente",
            "aceita",
            "concluida",
            "cancelada_pelo_motorista",
            "cancelada_pela_empresa",
        ]
    ] = None
    titulo: Optional[str] = None

# --- Cargas Empresariais ---
class CargaEmpresaCreate(BaseModel):
    empresaId: str
    titulo: str = Field(..., min_length=3, max_length=200)
    descricao: str = Field(..., min_length=10, max_length=2000)
    tipoCarga: str = Field(..., min_length=2, max_length=100)
    origem: str = Field(..., min_length=2, max_length=200)
    destino: str = Field(..., min_length=2, max_length=200)
    peso: float = Field(..., gt=0)
    preco: float = Field(..., gt=0)
    data: datetime
    status: Literal["disponivel", "em_transito", "concluida", "cancelada"] = "disponivel"

class CargaEmpresaUpdate(BaseModel):
    titulo: Optional[str] = Field(None, min_length=3, max_length=200)
    descricao: Optional[str] = Field(None, min_length=10, max_length=2000)
    tipoCarga: Optional[str] = Field(None, min_length=2, max_length=100)
    origem: Optional[str] = Field(None, min_length=2, max_length=200)
    destino: Optional[str] = Field(None, min_length=2, max_length=200)
    peso: Optional[float] = Field(None, gt=0)
    preco: Optional[float] = Field(None, gt=0)
    data: Optional[datetime] = None
    status: Optional[Literal["disponivel", "em_transito", "concluida", "cancelada"]] = None

# =============================================================================
# Health
# =============================================================================
@app.get("/health")
def health():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

# =============================================================================
# Auth (senha em texto claro — somente para testes!)
# =============================================================================
@app.post("/auth/login")
def login(payload: LoginPayload = Body(...)):
    coll = db.caminhoneiros if payload.tipo == "caminhoneiro" else db.empresas
    user = coll.find_one({"email": payload.email})
    if not user or user.get("senha") != payload.senha:
        raise HTTPException(status_code=401, detail="Credenciais inválidas")
    return {"msg": "ok", "tipo": payload.tipo, "user": to_public(user)}

@app.post("/auth/reset-password")
def reset_password(payload: dict = Body(...)):
    """Endpoint para redefinir senha de usuários existentes (apenas para testes)"""
    email = payload.get("email")
    tipo = payload.get("tipo")
    nova_senha = payload.get("nova_senha", "123456")
    
    if not email or not tipo:
        raise HTTPException(status_code=400, detail="Email e tipo são obrigatórios")
    
    coll = db.caminhoneiros if tipo == "caminhoneiro" else db.empresas
    result = coll.update_one(
        {"email": email},
        {"$set": {"senha": nova_senha}}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")
    
    return {"msg": "Senha redefinida com sucesso", "email": email, "tipo": tipo}

# =============================================================================
# Caminhoneiros
# =============================================================================
@app.post("/caminhoneiros/", status_code=201)
def criar_caminhoneiro(payload: CaminhoneiroCreate = Body(...)):
    try:
        dados = payload.dict()
        dados["data_cadastro"] = datetime.utcnow()
        r = db.caminhoneiros.insert_one(dados)
        return {"msg": "Cadastrado", "id": str(r.inserted_id)}
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

@app.get("/caminhoneiros/")
def listar_caminhoneiros(limit: int = 50, skip: int = 0):
    cur = db.caminhoneiros.find().sort("data_cadastro", -1).skip(skip).limit(limit)
    return [to_public(doc) for doc in cur]

@app.get("/caminhoneiros/{id}")
def obter_caminhoneiro(id: str = Path(..., description="ObjectId do caminhoneiro")):
    doc = db.caminhoneiros.find_one({"_id": to_objid(id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Caminhoneiro não encontrado")
    return to_public(doc)

@app.patch("/caminhoneiros/{id}")
def atualizar_caminhoneiro(id: str, payload: CaminhoneiroUpdate = Body(...)):
    update = {k: v for k, v in payload.dict(exclude_unset=True).items()}
    if not update:
        raise HTTPException(status_code=400, detail="Nenhum campo para atualizar")
    try:
        res = db.caminhoneiros.update_one({"_id": to_objid(id)}, {"$set": update})
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    if res.matched_count == 0:
        raise HTTPException(status_code=404, detail="Caminhoneiro não encontrado")
    return to_public(db.caminhoneiros.find_one({"_id": to_objid(id)}))

@app.delete("/caminhoneiros/{id}", status_code=204)
def remover_caminhoneiro(id: str):
    res = db.caminhoneiros.delete_one({"_id": to_objid(id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Caminhoneiro não encontrado")
    return

# =============================================================================
# Empresas
# =============================================================================
@app.post("/empresas/", status_code=201)
def criar_empresa(payload: EmpresaCreate = Body(...)):
    try:
        dados = payload.dict()
        dados["data_cadastro"] = datetime.utcnow()
        r = db.empresas.insert_one(dados)
        return {"msg": "Cadastrada", "id": str(r.inserted_id)}
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

@app.get("/empresas/")
def listar_empresas(limit: int = 50, skip: int = 0):
    cur = db.empresas.find().sort("data_cadastro", -1).skip(skip).limit(limit)
    return [to_public(doc) for doc in cur]

@app.get("/empresas/{id}")
def obter_empresa(id: str = Path(..., description="ObjectId da empresa")):
    doc = db.empresas.find_one({"_id": to_objid(id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")
    return to_public(doc)

@app.patch("/empresas/{id}")
def atualizar_empresa(id: str, payload: EmpresaUpdate = Body(...)):
    update = {k: v for k, v in payload.dict(exclude_unset=True).items()}
    if not update:
        raise HTTPException(status_code=400, detail="Nenhum campo para atualizar")
    try:
        res = db.empresas.update_one({"_id": to_objid(id)}, {"$set": update})
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrada")
    if res.matched_count == 0:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")
    return to_public(db.empresas.find_one({"_id": to_objid(id)}))

@app.delete("/empresas/{id}", status_code=204)
def remover_empresa(id: str):
    res = db.empresas.delete_one({"_id": to_objid(id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")
    return

# =============================================================================
# Avaliações (empresa -> caminhoneiro)
# =============================================================================
@app.post("/avaliacoes/", status_code=201)
def criar_avaliacao(payload: AvaliacaoCreate = Body(...)):
    data = payload.dict()
    data["caminhoneiroId"] = to_objid(data["caminhoneiroId"])
    if data.get("empresaId"):
        data["empresaId"] = to_objid(data["empresaId"])
    data["created_at"] = datetime.utcnow()
    r = db.avaliacoes.insert_one(data)
    return {"msg": "Avaliação registrada", "id": str(r.inserted_id)}

@app.get("/avaliacoes/")
def listar_avaliacoes(
    caminhoneiroId: Optional[str] = Query(None),
    limit: int = 100,
    skip: int = 0,
):
    q = {}
    if caminhoneiroId:
        q["caminhoneiroId"] = to_objid(caminhoneiroId)
    cur = db.avaliacoes.find(q).sort("created_at", -1).skip(skip).limit(limit)
    out: List[dict] = []
    for a in cur:
        a["id"] = str(a.pop("_id"))
        a["caminhoneiroId"] = str(a["caminhoneiroId"])
        if a.get("empresaId"):
            a["empresaId"] = str(a["empresaId"])
        out.append(a)
    return out

# =============================================================================
# Cargas (para métricas de cancelamento)
# =============================================================================
@app.post("/cargas/", status_code=201)
def criar_carga(payload: CargaCreate = Body(...)):
    data = payload.dict()
    data["caminhoneiroId"] = to_objid(data["caminhoneiroId"])
    if data.get("empresaId"):
        data["empresaId"] = to_objid(data["empresaId"])
    data["created_at"] = datetime.utcnow()
    r = db.cargas.insert_one(data)
    return {"msg": "Carga criada", "id": str(r.inserted_id)}

@app.get("/cargas/")
def listar_cargas(
    caminhoneiroId: Optional[str] = Query(None),
    limit: int = 200,
    skip: int = 0,
):
    q = {}
    if caminhoneiroId:
        q["caminhoneiroId"] = to_objid(caminhoneiroId)
    cur = db.cargas.find(q).sort("created_at", -1).skip(skip).limit(limit)
    out: List[dict] = []
    for c in cur:
        c["id"] = str(c.pop("_id"))
        c["caminhoneiroId"] = str(c["caminhoneiroId"])
        if c.get("empresaId"):
            c["empresaId"] = str(c["empresaId"])
        out.append(c)
    return out

@app.patch("/cargas/{id}")
def atualizar_carga(id: str, payload: CargaUpdate = Body(...)):
    update = {k: v for k, v in payload.dict(exclude_unset=True).items()}
    if not update:
        raise HTTPException(status_code=400, detail="Nenhum campo para atualizar")
    res = db.cargas.update_one({"_id": to_objid(id)}, {"$set": update})
    if res.matched_count == 0:
        raise HTTPException(status_code=404, detail="Carga não encontrada")
    c = db.cargas.find_one({"_id": to_objid(id)})
    c["id"] = str(c.pop("_id"))
    c["caminhoneiroId"] = str(c["caminhoneiroId"])
    if c.get("empresaId"):
        c["empresaId"] = str(c["empresaId"])
    return c

# =============================================================================
# Cargas Empresariais
# =============================================================================
@app.post("/cargas-empresa/", status_code=201)
def criar_carga_empresa(payload: CargaEmpresaCreate = Body(...)):
    data = payload.dict()
    data["empresaId"] = to_objid(data["empresaId"])
    data["created_at"] = datetime.utcnow()
    r = db.cargas_empresa.insert_one(data)
    return {"msg": "Carga empresarial criada", "id": str(r.inserted_id)}

@app.get("/cargas-empresa/")
def listar_cargas_empresa(
    empresaId: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    limit: int = 200,
    skip: int = 0,
):
    q = {}
    if empresaId:
        q["empresaId"] = to_objid(empresaId)
    if status:
        q["status"] = status
    
    cur = db.cargas_empresa.find(q).sort("created_at", -1).skip(skip).limit(limit)
    out: List[dict] = []
    for c in cur:
        c["id"] = str(c.pop("_id"))
        c["empresaId"] = str(c["empresaId"])
        out.append(c)
    return out

@app.get("/cargas-empresa/{id}")
def obter_carga_empresa(id: str = Path(..., description="ObjectId da carga empresarial")):
    doc = db.cargas_empresa.find_one({"_id": to_objid(id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Carga empresarial não encontrada")
    doc["id"] = str(doc.pop("_id"))
    doc["empresaId"] = str(doc["empresaId"])
    return doc

@app.patch("/cargas-empresa/{id}")
def atualizar_carga_empresa(id: str, payload: CargaEmpresaUpdate = Body(...)):
    update = {k: v for k, v in payload.dict(exclude_unset=True).items()}
    if not update:
        raise HTTPException(status_code=400, detail="Nenhum campo para atualizar")
    res = db.cargas_empresa.update_one({"_id": to_objid(id)}, {"$set": update})
    if res.matched_count == 0:
        raise HTTPException(status_code=404, detail="Carga empresarial não encontrada")
    c = db.cargas_empresa.find_one({"_id": to_objid(id)})
    c["id"] = str(c.pop("_id"))
    c["empresaId"] = str(c["empresaId"])
    return c

@app.delete("/cargas-empresa/{id}", status_code=204)
def deletar_carga_empresa(id: str):
    res = db.cargas_empresa.delete_one({"_id": to_objid(id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Carga empresarial não encontrada")
    return

# =============================================================================
# Busca de Cargas Disponíveis
# =============================================================================
@app.get("/cargas/disponiveis")
def buscar_cargas_disponiveis(
    origem: Optional[str] = Query(None),
    destino: Optional[str] = Query(None),
    tipoCarga: Optional[str] = Query(None),
    pesoMin: Optional[float] = Query(None),
    pesoMax: Optional[float] = Query(None),
    precoMin: Optional[float] = Query(None),
    precoMax: Optional[float] = Query(None),
    limit: int = 50,
    skip: int = 0,
):
    """Busca cargas disponíveis com filtros opcionais"""
    q = {"status": "disponivel"}
    
    # Se não há filtros, retorna todas as cargas disponíveis
    if not any([origem, destino, tipoCarga, pesoMin, pesoMax, precoMin, precoMax]):
        cur = db.cargas_empresa.find(q).sort("created_at", -1).skip(skip).limit(limit)
        out: List[dict] = []
        for c in cur:
            c["id"] = str(c.pop("_id"))
            c["empresaId"] = str(c["empresaId"])
            out.append(c)
        return out
    
    # Se há filtros, usa lógica mais flexível
    # Construir filtros individuais
    filtros = []
    
    if origem:
        filtros.append({"origem": {"$regex": origem, "$options": "i"}})
    if destino:
        filtros.append({"destino": {"$regex": destino, "$options": "i"}})
    if tipoCarga:
        filtros.append({"tipoCarga": {"$regex": tipoCarga, "$options": "i"}})
    
    # Filtros de peso e preço são aplicados como AND (restrições)
    if pesoMin is not None or pesoMax is not None:
        peso_filter = {}
        if pesoMin is not None:
            peso_filter["$gte"] = pesoMin
        if pesoMax is not None:
            peso_filter["$lte"] = pesoMax
        q["peso"] = peso_filter
    
    if precoMin is not None or precoMax is not None:
        preco_filter = {}
        if precoMin is not None:
            preco_filter["$gte"] = precoMin
        if precoMax is not None:
            preco_filter["$lte"] = precoMax
        q["preco"] = preco_filter
    
    # Se há filtros de texto, usa OR para ser mais flexível
    if filtros:
        q["$or"] = filtros
    
    cur = db.cargas_empresa.find(q).sort("created_at", -1).skip(skip).limit(limit)
    out: List[dict] = []
    for c in cur:
        c["id"] = str(c.pop("_id"))
        c["empresaId"] = str(c["empresaId"])
        out.append(c)
    return out

# =============================================================================
# Perfil agregado do caminhoneiro
# =============================================================================
@app.get("/perfil/caminhoneiro/{id}")
def perfil_caminhoneiro(id: str = Path(..., description="ObjectId do caminhoneiro")):
    _id = to_objid(id)
    user = db.caminhoneiros.find_one({"_id": _id})
    if not user:
        raise HTTPException(status_code=404, detail="Caminhoneiro não encontrado")

    # --- avaliações ---
    notas: List[float] = []
    for a in db.avaliacoes.find({"caminhoneiroId": _id}, {"nota": 1}):
        try:
            notas.append(float(a.get("nota", 0)))
        except Exception:
            pass
    media = round(sum(notas) / len(notas), 2) if notas else 0.0
    qtd = len(notas)

    # --- cargas para taxa de cancelamento ---
    aceitas = 0
    canceladas_motorista = 0
    for c in db.cargas.find({"caminhoneiroId": _id}, {"status": 1}):
        s = (c.get("status") or "").lower()
        if s in {"aceita", "concluida", "cancelada_pelo_motorista"}:
            aceitas += 1
        if s == "cancelada_pelo_motorista":
            canceladas_motorista += 1
    taxa_cancel = (canceladas_motorista / aceitas) if aceitas > 0 else 0.0

    perfil = to_public(user)
    perfil.update(
        {
            "avaliacao_media": media,
            "avaliacao_qtd": qtd,
            "taxa_cancelamento": round(taxa_cancel, 4),
        }
    )
    return perfil

# =============================================================================
# Perfil agregado da empresa
# =============================================================================
@app.get("/perfil/empresa/{id}")
def perfil_empresa(id: str = Path(..., description="ObjectId da empresa")):
    _id = to_objid(id)
    user = db.empresas.find_one({"_id": _id})
    if not user:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")

    # --- cargas para métricas ---
    total_cargas = db.cargas_empresa.count_documents({"empresaId": _id})
    cargas_concluidas = db.cargas_empresa.count_documents({
        "empresaId": _id, 
        "status": "concluida"
    })
    taxa_conclusao = (cargas_concluidas / total_cargas) if total_cargas > 0 else 0.0

    # --- avaliações da empresa (se houver) ---
    # Por enquanto, vamos simular uma avaliação média
    avaliacao_media = 4.5  # TODO: Implementar sistema de avaliação para empresas

    perfil = to_public(user)
    perfil.update(
        {
            "avaliacao_media": avaliacao_media,
            "total_cargas": total_cargas,
            "cargas_concluidas": cargas_concluidas,
            "taxa_conclusao": round(taxa_conclusao, 4),
        }
    )
    return perfil
