from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from pymongo import MongoClient
from datetime import datetime

app = FastAPI()

# 🔐 Substitua com seu usuário e senha válidos
MONGO_URI = "mongodb+srv://joaopedropiceli:88911121Erica@truckload.hn4bvsc.mongodb.net/truckload_db?retryWrites=true&w=majority"
client = MongoClient(MONGO_URI)
db = client["truckload_db"]

# Models
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

# Endpoints
@app.post("/caminhoneiros/")
def criar_caminhoneiro(caminhoneiro: Caminhoneiro):
    if db.caminhoneiros.find_one({"email": caminhoneiro.email}):
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    dados = caminhoneiro.dict()
    dados["data_cadastro"] = datetime.utcnow()
    result = db.caminhoneiros.insert_one(dados)
    return {"msg": "Caminhoneiro cadastrado com sucesso", "id": str(result.inserted_id)}

@app.post("/empresas/")
def criar_empresa(empresa: Empresa):
    if db.empresas.find_one({"email": empresa.email}):
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    dados = empresa.dict()
    dados["data_cadastro"] = datetime.utcnow()
    result = db.empresas.insert_one(dados)
    return {"msg": "Empresa cadastrada com sucesso", "id": str(result.inserted_id)}
