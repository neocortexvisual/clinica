"""Modelos Pydantic para a entrada e a saída da API."""

from enum import StrEnum

from pydantic import BaseModel, ConfigDict, Field


class Etapa(StrEnum):
    ESPECIALIDADE = "especialidade"
    PROFISSIONAL = "profissional"
    DATA_HORARIO = "data_horario"
    CONFIRMACAO = "confirmacao"


class MensagemRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")

    texto: str = Field(min_length=1, max_length=2000)


class OpcaoResponse(BaseModel):
    id: str
    descricao: str


class MensagemResponse(BaseModel):
    etapa: Etapa
    mensagem: str
    opcoes: list[OpcaoResponse] = Field(default_factory=list)
