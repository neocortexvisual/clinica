"""Abertura do atendimento e escolha inicial, sem dependência de HTTP ou IA."""

import re
import unicodedata

from repository import AgendaRepository


class ChatbotService:
    def __init__(self, repository: AgendaRepository):
        self.repository = repository

    def responder(self, texto: str) -> dict:
        mensagem = self._normalizar(texto)
        atendimentos = self.repository.listar_atendimentos()
        escolhas = self._identificar_escolhas(mensagem, atendimentos)
        saudacao = self._saudacao(mensagem)

        if len(escolhas) == 1:
            escolhido = escolhas[0]
            prefixo = f"{saudacao} " if saudacao else ""
            return {
                "etapa": "atendimento_selecionado",
                "mensagem": f"{prefixo}Você escolheu atendimento com {escolhido['descricao']}.",
                "opcoes": [],
                "atendimento_selecionado": escolhido,
            }

        if len(escolhas) > 1:
            abertura = "Você mencionou mais de um atendimento. Escolha apenas uma opção."
        elif saudacao:
            abertura = (
                f"{saudacao} Sou o assistente virtual da Clínica Vida & Saúde "
                "e posso ajudar você a agendar uma consulta.\n\n"
                "Qual atendimento você procura?"
            )
        else:
            abertura = (
                "Não consegui identificar sua escolha. "
                "Qual atendimento você procura? Escolha pelo número ou pelo nome."
            )

        menu = "\n".join(
            f"{numero}. {opcao['descricao']}"
            for numero, opcao in enumerate(atendimentos, start=1)
        )
        return {
            "etapa": "especialidade",
            "mensagem": f"{abertura}\n\n{menu}",
            "opcoes": atendimentos,
            "atendimento_selecionado": None,
        }

    @staticmethod
    def _normalizar(texto: str) -> str:
        sem_acentos = "".join(
            caractere
            for caractere in unicodedata.normalize("NFD", texto.casefold())
            if not unicodedata.combining(caractere)
        )
        return " ".join(re.findall(r"[a-z0-9]+", sem_acentos))

    @staticmethod
    def _saudacao(mensagem: str) -> str | None:
        for periodo in ("bom dia", "boa tarde", "boa noite"):
            if f" {periodo} " in f" {mensagem} ":
                return f"Olá, {periodo}!"
        if {"oi", "ola"}.intersection(mensagem.split()):
            return "Olá!"
        return None

    @staticmethod
    def _identificar_escolhas(
        mensagem: str, atendimentos: list[dict[str, str]]
    ) -> list[dict[str, str]]:
        numero = re.fullmatch(r"(?:opcao )?([1-4])", mensagem)
        if numero:
            return [atendimentos[int(numero[1]) - 1]]

        # Inclui a grafia recebida no requisito e nomes comuns das especialidades.
        aliases = {
            "oftamologista": "oftalmologista",
            "oftalmologia": "oftalmologista",
            "psicologa": "psicologo",
            "psicologia": "psicologo",
            "dermatologia": "dermatologista",
            "ortopedia": "ortopedista",
        }
        palavras = {aliases.get(palavra, palavra) for palavra in mensagem.split()}
        return [opcao for opcao in atendimentos if opcao["id"] in palavras]
