"""Regras do funil demonstrativo de agendamento."""

from dataclasses import dataclass, field
from threading import RLock
from uuid import uuid4

from repository import AgendaRepository, HorarioIndisponivel, OpcaoAgenda
from schemas import Etapa, MensagemResponse, OpcaoResponse


class ConversaNaoEncontrada(Exception):
    """A conversa solicitada não existe neste processo."""


@dataclass
class EstadoConversa:
    etapa: Etapa = Etapa.ESPECIALIDADE
    especialidade_id: str | None = None
    profissional_id: str | None = None
    data_iso: str | None = None
    horario: str | None = None
    agendamento_id: str | None = None
    opcoes_exibidas: list[str] = field(default_factory=list)


class ChatbotService:
    """Conduz escolhas válidas e só reserva após confirmação explícita."""

    def __init__(self, agenda: AgendaRepository) -> None:
        self._agenda = agenda
        self._conversas: dict[str, EstadoConversa] = {}
        self._lock = RLock()

    def criar_conversa(self) -> MensagemResponse:
        with self._lock:
            conversa_id = str(uuid4())
            estado = EstadoConversa()
            self._conversas[conversa_id] = estado
            return self._resposta(
                conversa_id,
                estado,
                "Olá! Vou ajudar você a agendar uma consulta. "
                "Qual especialidade procura? (Dados demonstrativos.)",
                self._agenda.listar_especialidades(),
            )

    def processar_mensagem(
        self, conversa_id: str, texto: str
    ) -> MensagemResponse:
        with self._lock:
            estado = self._conversas.get(conversa_id)
            if estado is None:
                raise ConversaNaoEncontrada

            if estado.etapa == Etapa.CONCLUIDA:
                return self._resposta(
                    conversa_id,
                    estado,
                    "Este agendamento já foi confirmado. "
                    "Não criei uma segunda reserva.",
                )
            comando = self._processar_correcao(conversa_id, estado, texto)
            if comando is not None:
                return comando
            if estado.etapa == Etapa.ESPECIALIDADE:
                return self._selecionar_especialidade(
                    conversa_id, estado, texto
                )
            if estado.etapa == Etapa.PROFISSIONAL:
                return self._selecionar_profissional(
                    conversa_id, estado, texto
                )
            if estado.etapa == Etapa.DATA_HORARIO:
                return self._selecionar_data(conversa_id, estado, texto)
            if estado.etapa == Etapa.HORARIO:
                return self._selecionar_horario(conversa_id, estado, texto)
            return self._confirmar(conversa_id, estado, texto)

    def _selecionar_especialidade(
        self, conversa_id: str, estado: EstadoConversa, texto: str
    ) -> MensagemResponse:
        opcao = self._encontrar_opcao(
            texto,
            self._agenda.listar_especialidades(),
            estado.opcoes_exibidas,
        )
        if opcao is None:
            return self._resposta(
                conversa_id,
                estado,
                "Não encontrei essa especialidade. Escolha uma das opções:",
                self._agenda.listar_especialidades(),
            )
        estado.especialidade_id = opcao.id
        estado.etapa = Etapa.PROFISSIONAL
        profissionais = self._agenda.listar_profissionais(opcao.id)
        return self._resposta(
            conversa_id,
            estado,
            f"Ótimo, vamos procurar atendimento em {opcao.descricao}. "
            "Escolha um profissional:",
            profissionais,
        )

    def _selecionar_profissional(
        self, conversa_id: str, estado: EstadoConversa, texto: str
    ) -> MensagemResponse:
        profissionais = self._agenda.listar_profissionais(
            estado.especialidade_id or ""
        )
        opcao = self._encontrar_opcao(
            texto, profissionais, estado.opcoes_exibidas
        )
        if opcao is None:
            return self._resposta(
                conversa_id,
                estado,
                "Esse profissional não atende a especialidade selecionada. "
                "Escolha uma das opções:",
                profissionais,
            )
        estado.profissional_id = opcao.id
        estado.etapa = Etapa.DATA_HORARIO
        datas = self._agenda.datas_disponiveis(opcao.id)
        return self._resposta(
            conversa_id,
            estado,
            f"Você escolheu {opcao.descricao}. Selecione uma data disponível:",
            datas,
        )

    def _selecionar_data(
        self, conversa_id: str, estado: EstadoConversa, texto: str
    ) -> MensagemResponse:
        datas = self._agenda.datas_disponiveis(
            estado.profissional_id or ""
        )
        opcao = self._encontrar_opcao(texto, datas, estado.opcoes_exibidas)
        if opcao is None:
            return self._resposta(
                conversa_id,
                estado,
                "Essa data não está disponível. Selecione uma das opções:",
                datas,
            )
        estado.data_iso = opcao.id
        estado.etapa = Etapa.HORARIO
        horarios = self._agenda.horarios_disponiveis(
            estado.profissional_id or "", opcao.id
        )
        return self._resposta(
            conversa_id,
            estado,
            f"Há estes horários em {opcao.descricao}. Qual prefere?",
            horarios,
        )

    def _selecionar_horario(
        self, conversa_id: str, estado: EstadoConversa, texto: str
    ) -> MensagemResponse:
        horarios = self._horarios(estado)
        opcao = self._encontrar_opcao(texto, horarios, estado.opcoes_exibidas)
        if opcao is None:
            return self._resposta(
                conversa_id,
                estado,
                "Esse horário não está disponível. Escolha uma das opções:",
                horarios,
            )
        estado.horario = opcao.id
        estado.etapa = Etapa.CONFIRMACAO
        profissional = self._nome_profissional(
            estado.profissional_id or ""
        )
        data = self._formatar_data(estado.data_iso or "")
        return self._resposta(
            conversa_id,
            estado,
            f"Resumo: {self._agenda.nome_especialidade(estado.especialidade_id or '')}; "
            f"{profissional}; "
            f"{data} às {opcao.descricao}. Confirma o agendamento?",
            [
                OpcaoAgenda("confirmar", "Sim, confirmar"),
                OpcaoAgenda("cancelar", "Não, cancelar"),
            ],
        )

    def _confirmar(
        self, conversa_id: str, estado: EstadoConversa, texto: str
    ) -> MensagemResponse:
        resposta = texto.strip().casefold()
        if resposta.isdecimal():
            indice = int(resposta) - 1
            resposta = (
                estado.opcoes_exibidas[indice].casefold()
                if 0 <= indice < len(estado.opcoes_exibidas)
                else ""
            )
        if resposta in {"cancelar", "não", "nao", "não, cancelar", "nao, cancelar"}:
            self._limpar(estado)
            return self._resposta(
                conversa_id,
                estado,
                "Agendamento cancelado. Se quiser, escolha uma especialidade "
                "para começar novamente.",
                self._agenda.listar_especialidades(),
            )
        if resposta not in {"confirmar", "sim", "sim, confirmar", "confirmo"}:
            return self._resposta(
                conversa_id,
                estado,
                "Para continuar, confirme ou cancele o agendamento:",
                [
                    OpcaoAgenda("confirmar", "Sim, confirmar"),
                    OpcaoAgenda("cancelar", "Não, cancelar"),
                ],
            )

        try:
            agendamento_id = self._agenda.reservar(
                estado.profissional_id or "",
                estado.data_iso or "",
                estado.horario or "",
            )
        except HorarioIndisponivel:
            estado.horario = None
            estado.etapa = Etapa.HORARIO
            return self._resposta(
                conversa_id,
                estado,
                "Esse horário ficou indisponível. "
                "Escolha outro horário:",
                self._horarios(estado),
            )

        estado.agendamento_id = agendamento_id
        estado.etapa = Etapa.CONCLUIDA
        return self._resposta(
            conversa_id,
            estado,
            f"Agendamento demonstrativo confirmado para "
            f"{self._formatar_data(estado.data_iso or '')} às "
            f"{estado.horario}. Código: {agendamento_id}.",
        )

    def _processar_correcao(
        self, conversa_id: str, estado: EstadoConversa, texto: str
    ) -> MensagemResponse | None:
        comando = texto.strip().casefold()
        if comando in {"mudar especialidade", "alterar especialidade"}:
            self._limpar(estado)
            return self._resposta(
                conversa_id,
                estado,
                "Sem problema. Escolha a especialidade:",
                self._agenda.listar_especialidades(),
            )
        if comando in {"mudar profissional", "alterar profissional"}:
            if estado.especialidade_id is None:
                return None
            estado.profissional_id = None
            estado.data_iso = None
            estado.horario = None
            estado.etapa = Etapa.PROFISSIONAL
            return self._resposta(
                conversa_id,
                estado,
                "Escolha outro profissional:",
                self._agenda.listar_profissionais(estado.especialidade_id),
            )
        if comando in {"mudar data", "alterar data"}:
            if estado.profissional_id is None:
                return None
            estado.data_iso = None
            estado.horario = None
            estado.etapa = Etapa.DATA_HORARIO
            return self._resposta(
                conversa_id,
                estado,
                "Escolha outra data disponível:",
                self._agenda.datas_disponiveis(estado.profissional_id),
            )
        if comando in {
            "mudar horário",
            "mudar horario",
            "alterar horário",
            "alterar horario",
        }:
            if estado.data_iso is None:
                return None
            estado.horario = None
            estado.etapa = Etapa.HORARIO
            return self._resposta(
                conversa_id,
                estado,
                "Escolha outro horário:",
                self._horarios(estado),
            )
        return None

    def _horarios(self, estado: EstadoConversa) -> list[OpcaoAgenda]:
        if estado.profissional_id is None or estado.data_iso is None:
            return []
        return self._agenda.horarios_disponiveis(
            estado.profissional_id, estado.data_iso
        )

    def _nome_profissional(self, profissional_id: str) -> str:
        return (
            self._agenda.nome_profissional(profissional_id)
            or profissional_id
        )

    @staticmethod
    def _encontrar_opcao(
        texto: str,
        opcoes: list[OpcaoAgenda],
        opcoes_exibidas: list[str],
    ) -> OpcaoAgenda | None:
        valor = texto.strip().casefold()
        if valor.isdecimal():
            indice = int(valor) - 1
            if 0 <= indice < len(opcoes_exibidas):
                id_exibido = opcoes_exibidas[indice]
                return next(
                    (opcao for opcao in opcoes if opcao.id == id_exibido),
                    None,
                )
            return None
        return next(
            (
                opcao
                for opcao in opcoes
                if valor in {opcao.id.casefold(), opcao.descricao.casefold()}
            ),
            None,
        )

    @staticmethod
    def _formatar_data(data_iso: str) -> str:
        ano, mes, dia = data_iso.split("-")
        return f"{dia}/{mes}/{ano}"

    @staticmethod
    def _limpar(estado: EstadoConversa) -> None:
        estado.etapa = Etapa.ESPECIALIDADE
        estado.especialidade_id = None
        estado.profissional_id = None
        estado.data_iso = None
        estado.horario = None
        estado.agendamento_id = None
        estado.opcoes_exibidas = []

    def _resposta(
        self,
        conversa_id: str,
        estado: EstadoConversa,
        mensagem: str,
        opcoes: list[OpcaoAgenda] | None = None,
    ) -> MensagemResponse:
        opcoes = opcoes or []
        estado.opcoes_exibidas = [opcao.id for opcao in opcoes]
        return MensagemResponse(
            conversa_id=conversa_id,
            etapa=estado.etapa,
            mensagem=mensagem,
            opcoes=[
                OpcaoResponse(id=opcao.id, descricao=opcao.descricao)
                for opcao in opcoes
            ],
        )
