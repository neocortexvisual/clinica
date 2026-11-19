"""Acesso aos dados da agenda, separado das regras da conversa.

Responsabilidades a implementar após definir a fonte de dados:
- Consultar especialidades e profissionais.
- Consultar a disponibilidade por profissional e data.
- Registrar o agendamento, impedindo reserva duplicada do horário.

Usar a mesma agenda das frentes de recepção e profissional de saúde.
"""


class AgendaRepository:
    """Catálogo inicial. A consulta de horários e a reserva serão implementadas depois."""

    def listar_atendimentos(self) -> list[dict[str, str]]:
        return [
            {"id": "oftalmologista", "descricao": "Oftalmologista"},
            {"id": "psicologo", "descricao": "Psicólogo"},
            {"id": "dermatologista", "descricao": "Dermatologista"},
            {"id": "ortopedista", "descricao": "Ortopedista"},
        ]
