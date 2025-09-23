from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from pymongo import MongoClient, ASCENDING
from pymongo.errors import DuplicateKeyError
from bson import ObjectId
from datetime import datetime
import os

app = FastAPI(title="TruckLoad API")

# CORS (em produção, substitua "*" pelos seus domínios/apps)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MONGO_URI = os.environ.get("MONGODB_URI")
if not MONGO_URI:
    raise RuntimeError("Defina a variável de ambiente MONGODB_URI")

client = MongoClient(MONGO_URI)
db = client["truckload_db"]

def ensure_indexes():
    db.caminhoneiros.create_index([("email", ASCENDING)], unique=True, name="uniq_email_caminhoneiro")
    db.empresas.create_index([("email", ASCENDING)], unique=True, name="uniq_email_empresa")

@app.on_event("startup")
def on_startup():
    ensure_indexes()

class Caminhoneiro(BaseModel):
    nome: str
    email: EmailStr
    cpf: str
    telefone: str
    tipoCaminhao: str

class Empresa(BaseModel):
    nome: str
    email: EmailStr
    cnpj: str
    telefone: str
    endereco: str

def to_public(doc: dict):
    d = dict(doc)
    d["id"] = str(d.pop("_id"))
    return d

@app.get("/health")
def health():
    return {"ok": True, "ts": datetime.utcnow().isoformat()}

@app.post("/caminhoneiros/", status_code=201)
def criar_caminhoneiro(c: Caminhoneiro):
    try:
        dados = c.dict()
        dados["data_cadastro"] = datetime.utcnow()
        r = db.caminhoneiros.insert_one(dados)
        return {"msg": "Cadastrado", "id": str(r.inserted_id)}
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

@app.get("/caminhoneiros/")
def listar_caminhoneiros(limit: int = 50):
    itens = db.caminhoneiros.find().sort("data_cadastro", -1).limit(limit)
    return [to_public(i) for i in itens]

@app.post("/empresas/", status_code=201)
def criar_empresa(e: Empresa):
    try:
        dados = e.dict()
        dados["data_cadastro"] = datetime.utcnow()
        r = db.empresas.insert_one(dados)
        return {"msg": "Cadastrada", "id": str(r.inserted_id)}
    except DuplicateKeyError:
        raise HTTPException(status_code=400, detail="Email já cadastradoo")

@app.get("/empresas/")
def listar_empresas(limit: int = 50):
    itens = db.empresas.find().sort("data_cadastro", -1).limit(limit)
    return [to_public(i) for i in itens]
