"""Entrada da API. Executar nesta pasta: uvicorn main:app --reload."""

import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from repository import AgendaRepository
from schemas import MensagemRequest, MensagemResponse
from service import ChatbotService

app = FastAPI(title="Chatbot da Clínica", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        origin.strip()
        for origin in os.getenv(
            "CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000"
        ).split(",")
        if origin.strip()
    ],
    # O Flutter web pode escolher uma porta local diferente a cada execução.
    allow_origin_regex=os.getenv(
        "CORS_ORIGIN_REGEX", r"http://(localhost|127\.0\.0\.1)(:\d+)?"
    ) or None,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)
chatbot = ChatbotService(AgendaRepository())


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/chatbot/mensagens", response_model=MensagemResponse)
def enviar_mensagem(mensagem: MensagemRequest):
    return chatbot.responder(mensagem.texto)
