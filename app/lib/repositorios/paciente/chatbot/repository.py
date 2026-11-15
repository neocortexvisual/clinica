"""Agenda demonstrativa em memória; não representa dados reais da clínica."""

from dataclasses import dataclass
from datetime import date, timedelta
from threading import RLock
from uuid import uuid4


@dataclass(frozen=True)
class OpcaoAgenda:
    id: str
    descricao: str


@dataclass(frozen=True)
class Profissional:
    id: str
    nome: str
    especialidade_id: str


class HorarioIndisponivel(Exception):
    """O horário foi reservado por outra conversa ou não está mais disponível."""


class AgendaRepository:
    """Fornece especialidades, profissionais e horários fictícios para a demo."""

    _HORARIOS = ("09:00", "10:30", "14:00", "15:30")

    def __init__(self) -> None:
        self._especialidades = (
            OpcaoAgenda("pediatria", "Pediatria"),
            OpcaoAgenda("ginecologia", "Ginecologia"),
            OpcaoAgenda("cardiologia", "Cardiologia"),
            OpcaoAgenda("dermatologia", "Dermatologia"),
            OpcaoAgenda("clinica-geral", "Clínica geral"),
        )
        self._profissionais = (
            Profissional("luiza-rocha", "Dra. Luiza Rocha", "pediatria"),
            Profissional("pedro-nunes", "Dr. Pedro Nunes", "pediatria"),
            Profissional("marina-costa", "Dra. Marina Costa", "ginecologia"),
            Profissional("paula-santos", "Dra. Paula Santos", "ginecologia"),
            Profissional("ana-lima", "Dra. Ana Lima", "cardiologia"),
            Profissional("caio-souza", "Dr. Caio Souza", "cardiologia"),
            Profissional("bia-martins", "Dra. Bia Martins", "dermatologia"),
            Profissional("leo-alves", "Dr. Léo Alves", "dermatologia"),
            Profissional("nina-costa", "Dra. Nina Costa", "clinica-geral"),
        )
        self._reservados: dict[tuple[str, str, str], str] = {}
        self._lock = RLock()

    def listar_especialidades(self) -> list[OpcaoAgenda]:
        return list(self._especialidades)

    def nome_especialidade(self, especialidade_id: str) -> str | None:
        return next(
            (
                especialidade.descricao
                for especialidade in self._especialidades
                if especialidade.id == especialidade_id
            ),
            None,
        )

    def listar_profissionais(self, especialidade_id: str) -> list[OpcaoAgenda]:
        return [
            OpcaoAgenda(profissional.id, profissional.nome)
            for profissional in self._profissionais
            if profissional.especialidade_id == especialidade_id
        ]

    def datas_disponiveis(self, profissional_id: str) -> list[OpcaoAgenda]:
        if not any(p.id == profissional_id for p in self._profissionais):
            return []

        datas: list[OpcaoAgenda] = []
        dia = date.today() + timedelta(days=1)
        limite = date.today() + timedelta(days=90)
        while len(datas) < 5 and dia <= limite:
            if dia.weekday() < 5 and self._tem_horario_disponivel(
                profissional_id, dia.isoformat()
            ):
                datas.append(
                    OpcaoAgenda(
                        dia.isoformat(),
                        dia.strftime("%d/%m/%Y"),
                    )
                )
            dia += timedelta(days=1)
        return datas

    def nome_profissional(self, profissional_id: str) -> str | None:
        return next(
            (
                profissional.nome
                for profissional in self._profissionais
                if profissional.id == profissional_id
            ),
            None,
        )

    def horarios_disponiveis(
        self, profissional_id: str, data_iso: str
    ) -> list[OpcaoAgenda]:
        datas_validas = {
            opcao.id for opcao in self.datas_disponiveis(profissional_id)
        }
        if data_iso not in datas_validas:
            return []
        with self._lock:
            return [
                OpcaoAgenda(horario, horario)
                for horario in self._HORARIOS
                if (profissional_id, data_iso, horario) not in self._reservados
            ]

    def _tem_horario_disponivel(
        self, profissional_id: str, data_iso: str
    ) -> bool:
        with self._lock:
            return any(
                (profissional_id, data_iso, horario) not in self._reservados
                for horario in self._HORARIOS
            )

    def reservar(
        self, profissional_id: str, data_iso: str, horario: str
    ) -> str:
        chave = (profissional_id, data_iso, horario)
        with self._lock:
            if (
                horario not in self._HORARIOS
                or data_iso
                not in {
                    opcao.id
                    for opcao in self.datas_disponiveis(profissional_id)
                }
                or chave in self._reservados
            ):
                raise HorarioIndisponivel
            agendamento_id = str(uuid4())
            self._reservados[chave] = agendamento_id
            return agendamento_id
