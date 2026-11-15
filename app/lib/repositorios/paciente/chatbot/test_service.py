import unittest

from repository import AgendaRepository
from schemas import Etapa
from service import ChatbotService


class ChatbotServiceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.agenda = AgendaRepository()
        self.chatbot = ChatbotService(self.agenda)

    def _conversa_ate_horario(self) -> tuple[str, str]:
        inicio = self.chatbot.criar_conversa()
        self.chatbot.processar_mensagem(inicio.conversa_id, "cardiologia")
        self.chatbot.processar_mensagem(inicio.conversa_id, "ana-lima")
        data = self.agenda.datas_disponiveis("ana-lima")[0].id
        self.chatbot.processar_mensagem(inicio.conversa_id, data)
        return inicio.conversa_id, data

    def _conversa_ate_confirmacao(self) -> str:
        conversa_id, _ = self._conversa_ate_horario()
        resposta = self.chatbot.processar_mensagem(conversa_id, "09:00")
        self.assertEqual(resposta.etapa, Etapa.CONFIRMACAO)
        return conversa_id

    def test_funil_so_reserva_apos_confirmacao_e_nao_duplica(self) -> None:
        conversa_id = self._conversa_ate_confirmacao()

        confirmacao = self.chatbot.processar_mensagem(conversa_id, "sim")
        self.assertEqual(confirmacao.etapa, Etapa.CONCLUIDA)
        self.assertIn("confirmado", confirmacao.mensagem)

        repeticao = self.chatbot.processar_mensagem(conversa_id, "sim")
        self.assertEqual(repeticao.etapa, Etapa.CONCLUIDA)
        self.assertIn("segunda reserva", repeticao.mensagem)

    def test_rejeita_escolha_invalida_e_permite_corrigir(self) -> None:
        inicio = self.chatbot.criar_conversa()
        resposta = self.chatbot.processar_mensagem(
            inicio.conversa_id, "profissional inexistente"
        )
        self.assertEqual(resposta.etapa, Etapa.ESPECIALIDADE)
        self.assertTrue(resposta.opcoes)

        self.chatbot.processar_mensagem(inicio.conversa_id, "cardiologia")
        resposta = self.chatbot.processar_mensagem(
            inicio.conversa_id, "bia-martins"
        )
        self.assertEqual(resposta.etapa, Etapa.PROFISSIONAL)
        self.assertIn("não atende", resposta.mensagem)

        resposta = self.chatbot.processar_mensagem(
            inicio.conversa_id, "mudar especialidade"
        )
        self.assertEqual(resposta.etapa, Etapa.ESPECIALIDADE)

    def test_horario_ocupado_durante_confirmacao_volta_a_oferecer_opcoes(
        self,
    ) -> None:
        primeira = self._conversa_ate_confirmacao()
        segunda = self._conversa_ate_confirmacao()

        self.chatbot.processar_mensagem(primeira, "confirmar")
        resposta = self.chatbot.processar_mensagem(segunda, "confirmar")

        self.assertEqual(resposta.etapa, Etapa.HORARIO)
        self.assertIn("ficou indisponível", resposta.mensagem)
        self.assertNotIn("09:00", [opcao.id for opcao in resposta.opcoes])

    def test_cancelamento_nao_reserva_e_reinicia_o_fluxo(self) -> None:
        conversa_id = self._conversa_ate_confirmacao()
        resposta = self.chatbot.processar_mensagem(conversa_id, "2")

        self.assertEqual(resposta.etapa, Etapa.ESPECIALIDADE)
        self.assertIn("cancelado", resposta.mensagem)

    def test_agenda_numerada_permite_agendar_pediatria(self) -> None:
        inicio = self.chatbot.criar_conversa()
        self.assertEqual(inicio.opcoes[0].descricao, "Pediatria")
        self.assertEqual(inicio.opcoes[1].descricao, "Ginecologia")

        profissionais = self.chatbot.processar_mensagem(
            inicio.conversa_id, "1"
        )
        self.assertEqual(profissionais.etapa, Etapa.PROFISSIONAL)
        self.assertEqual(profissionais.opcoes[1].descricao, "Dr. Pedro Nunes")

        datas = self.chatbot.processar_mensagem(inicio.conversa_id, "2")
        self.assertEqual(datas.etapa, Etapa.DATA_HORARIO)
        horarios = self.chatbot.processar_mensagem(inicio.conversa_id, "1")
        self.assertEqual(horarios.etapa, Etapa.HORARIO)
        confirmacao = self.chatbot.processar_mensagem(
            inicio.conversa_id, "1"
        )
        self.assertEqual(confirmacao.etapa, Etapa.CONFIRMACAO)

        concluida = self.chatbot.processar_mensagem(inicio.conversa_id, "1")
        self.assertEqual(concluida.etapa, Etapa.CONCLUIDA)
        self.assertIn("confirmado", concluida.mensagem)

    def test_numero_fora_da_lista_nao_avanca_o_fluxo(self) -> None:
        inicio = self.chatbot.criar_conversa()

        resposta = self.chatbot.processar_mensagem(inicio.conversa_id, "0")

        self.assertEqual(resposta.etapa, Etapa.ESPECIALIDADE)
        self.assertTrue(resposta.opcoes)

    def test_numero_de_horario_preserva_a_ordem_exibida(self) -> None:
        primeira, _ = self._conversa_ate_horario()
        segunda, _ = self._conversa_ate_horario()
        self.chatbot.processar_mensagem(segunda, "09:00")
        self.chatbot.processar_mensagem(segunda, "1")

        resposta = self.chatbot.processar_mensagem(primeira, "2")

        self.assertEqual(resposta.etapa, Etapa.CONFIRMACAO)
        self.assertIn("10:30", resposta.mensagem)


if __name__ == "__main__":
    unittest.main()
