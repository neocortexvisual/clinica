"""API demonstrativa. Executar nesta pasta: uvicorn main:app --reload."""

import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from repository import AgendaRepository
from schemas import MensagemRequest, MensagemResponse
from service import ChatbotService, ConversaNaoEncontrada

app = FastAPI(
    title="Chatbot demonstrativo da Clínica",
    version="0.2.0",
    description=(
        "Fluxo de agendamento com dados fictícios e estado em memória. "
        "Não utilizar para reservas reais."
    ),
)
origens_permitidas = [
    origem.strip()
    for origem in os.getenv("CLINICA_CORS_ORIGINS", "").split(",")
    if origem.strip()
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origens_permitidas,
    allow_origin_regex=(
        None
        if origens_permitidas
        else r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$"
    ),
    allow_methods=["POST"],
    allow_headers=["Content-Type"],
)
chatbot = ChatbotService(AgendaRepository())


@app.post("/conversas", response_model=MensagemResponse, status_code=201)
def criar_conversa() -> MensagemResponse:
    return chatbot.criar_conversa()


@app.post(
    "/conversas/{conversa_id}/mensagens",
    response_model=MensagemResponse,
)
def enviar_mensagem(
    conversa_id: str, request: MensagemRequest
) -> MensagemResponse:
    try:
        return chatbot.processar_mensagem(conversa_id, request.texto)
    except ConversaNaoEncontrada as exc:
        raise HTTPException(
            status_code=404, detail="Conversa não encontrada."
        ) from exc
