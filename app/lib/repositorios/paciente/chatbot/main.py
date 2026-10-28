"""Entrada da API. Executar nesta pasta: uvicorn main:app --reload."""

from fastapi import FastAPI

app = FastAPI(title="Chatbot da Clínica", version="0.1.0")

# Adicionar as rotas aqui quando os casos de uso forem implementados.
# As rotas devem validar os dados com schemas.py e chamar service.py.
