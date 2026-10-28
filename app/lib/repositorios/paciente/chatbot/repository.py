"""Acesso aos dados da agenda, separado das regras da conversa.

Responsabilidades a implementar após definir a fonte de dados:
- Consultar especialidades e profissionais.
- Consultar a disponibilidade por profissional e data.
- Registrar o agendamento, impedindo reserva duplicada do horário.

Usar a mesma agenda das frentes de recepção e profissional de saúde.
"""


class AgendaRepository:
    """Base para acesso à agenda; sem conexão ou armazenamento definidos."""
