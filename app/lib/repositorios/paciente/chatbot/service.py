"""Regras e condução da conversa, sem dependência de HTTP.

Implementar o funil nesta ordem:
1. Selecionar especialidade.
2. Selecionar um profissional da especialidade.
3. Selecionar data e horário disponíveis.
4. Exibir o resumo e solicitar confirmação antes de reservar.

O serviço deverá usar repository.py para acessar a agenda.
"""


class ChatbotService:
    """Base para os casos de uso; o fluxo ainda não foi implementado."""
