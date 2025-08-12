from fastapi import FastAPI, HTTPException, Path, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from bson import ObjectId
from pymongo import MongoClient, ASCENDING
from pymongo.errors import DuplicateKeyError
import os

# =============================================================================
# App & CORS
# =============================================================================
app = FastAPI(title="TruckLoad API", version="1.0.0")

# Em produção: troque "*" pelos seus domínios/apps (ex.: ["https://app.truckload.com.br"])
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
    db.caminhoneiros.create_index([("email", ASCENDING)], unique=True, name="uniq_email_caminhoneiro")
    db.empresas.create_index([("email", ASCENDING)], unique=True, name="uniq_email_empresa")

@app.on_event("startup")
def on_startup():
    ensure_indexes()

# =============================================================================
# Utils
# =============================================================================
def is_valid_objectid(s: str) -> bool:
    try:
        ObjectId(s)
        return True
    except Exception:
        return False

def to_public(doc: dict) -> dict:
    d = dict(doc)
    d["id"] = str(d.pop("_id"))
    return d

# =============================================================================
# Schemas
# =============================================================================
class CaminhoneiroCreate(BaseModel):
    nome: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    cpf: str = Field(..., min_length=3, max_length=32)
    telefone: str = Field(..., min_length=3, max_length=32)
    tipoCaminhao: str = Field(..., min_length=2, max_length=64)

class CaminhoneiroUpdate(BaseModel):
    nome: Optional[str] = Field(None, min_length=2, max_length=120)
    email: Optional[EmailStr] = None
    cpf: Optional[str] = Field(None, min_length=3, max_length=32)
    telefone: Optional[str] = Field(None, min_length=3, max_length=32)
    tipoCaminhao: Optional[str] = Field(None, min_length=2, max_length=64)

class EmpresaCreate(BaseModel):
    nome: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    cnpj: str = Field(..., min_length=3, max_length=32)
    telefone: str = Field(..., min_length=3, max_length=32)
    endereco: str = Field(..., min_length=3, max_length=255)

class EmpresaUpdate(BaseModel):
    nome: Optional[str] = Field(None, min_length=2, max_length=120)
    email: Optional[EmailStr] = None
    cnpj: Optional[str] = Field(None, min_length=3, max_length=32)
    telefone: Optional[str] = Field(None, min_length=3, max_length=32)
    endereco: Optional[str] = Field(None, min_length=3, max_length=255)

# =============================================================================
# Healthcheck
# =============================================================================
@app.get("/health")
def health():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

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
    if not is_valid_objectid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    doc = db.caminhoneiros.find_one({"_id": ObjectId(id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Caminhoneiro não encontrado")
    return to_public(doc)

@app.patch("/caminhoneiros/{id}")
def atualizar_caminhoneiro(id: str, payload: CaminhoneiroUpdate = Body(...)):
    if not is_valid_objectid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    update = {k: v for k, v in payload.dict(exclude_unset=True).items()}
    if not update:
        raise HTTPException(status_code=400, detail="Nenhum campo para atualizar")
    try:
        res = db.caminhoneiros.update_one({"_id": ObjectId(id)}, {"$set": update})
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    if res.matched_count == 0:
        raise HTTPException(status_code=404, detail="Caminhoneiro não encontrado")
    doc = db.caminhoneiros.find_one({"_id": ObjectId(id)})
    return to_public(doc)

@app.delete("/caminhoneiros/{id}", status_code=204)
def remover_caminhoneiro(id: str):
    if not is_valid_objectid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    res = db.caminhoneiros.delete_one({"_id": ObjectId(id)})
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
    if not is_valid_objectid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    doc = db.empresas.find_one({"_id": ObjectId(id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")
    return to_public(doc)

@app.patch("/empresas/{id}")
def atualizar_empresa(id: str, payload: EmpresaUpdate = Body(...)):
    if not is_valid_objectid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    update = {k: v for k, v in payload.dict(exclude_unset=True).items()}
    if not update:
        raise HTTPException(status_code=400, detail="Nenhum campo para atualizar")
    try:
        res = db.empresas.update_one({"_id": ObjectId(id)}, {"$set": update})
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    if res.matched_count == 0:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")
    doc = db.empresas.find_one({"_id": ObjectId(id)})
    return to_public(doc)

@app.delete("/empresas/{id}", status_code=204)
def remover_empresa(id: str):
    if not is_valid_objectid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    res = db.empresas.delete_one({"_id": ObjectId(id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Empresa não encontrada")
    return
