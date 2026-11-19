import unittest

from repository import AgendaRepository
from service import ChatbotService


class AberturaAtendimentoTests(unittest.TestCase):
    def setUp(self):
        self.service = ChatbotService(AgendaRepository())

    def test_saudacoes_apresentam_servico_e_as_quatro_opcoes(self):
        for texto, cumprimento in [
            ("OI", "Olá!"),
            ("Olá!", "Olá!"),
            ("Oi, bom dia!", "Olá, bom dia!"),
            ("OLÁ, BOA TARDE!!!", "Olá, boa tarde!"),
            ("boa noite", "Olá, boa noite!"),
        ]:
            with self.subTest(texto=texto):
                resposta = self.service.responder(texto)
                self.assertTrue(resposta["mensagem"].startswith(cumprimento))
                self.assertIn("posso ajudar você a agendar", resposta["mensagem"])
                self.assertEqual(resposta["etapa"], "especialidade")
                self.assertEqual(
                    [opcao["id"] for opcao in resposta["opcoes"]],
                    ["oftalmologista", "psicologo", "dermatologista", "ortopedista"],
                )
                self.assertIsNone(resposta["atendimento_selecionado"])

    def test_escolha_por_numero_nome_ou_id(self):
        for texto, esperado in [
            ("1", "oftalmologista"),
            ("2", "psicologo"),
            ("3", "dermatologista"),
            ("4", "ortopedista"),
            ("Psicólogo", "psicologo"),
            ("psicologo", "psicologo"),
            ("Quero uma consulta com DERMATOLOGISTA.", "dermatologista"),
            ("opção 2", "psicologo"),
            ("Oftamologista", "oftalmologista"),
        ]:
            with self.subTest(texto=texto):
                resposta = self.service.responder(texto)
                self.assertEqual(resposta["etapa"], "atendimento_selecionado")
                self.assertEqual(resposta["atendimento_selecionado"]["id"], esperado)
                self.assertEqual(resposta["opcoes"], [])

    def test_saudacao_com_escolha_aproveita_a_informacao(self):
        resposta = self.service.responder("Olá, boa noite! Quero ortopedista.")
        self.assertTrue(resposta["mensagem"].startswith("Olá, boa noite!"))
        self.assertEqual(resposta["atendimento_selecionado"]["id"], "ortopedista")

    def test_resposta_desconhecida_mantem_escolha_e_reapresenta_menu(self):
        for texto in ("5", "cardiologista", "não entendi", "tenho 2 exames"):
            with self.subTest(texto=texto):
                resposta = self.service.responder(texto)
                self.assertEqual(resposta["etapa"], "especialidade")
                self.assertEqual(len(resposta["opcoes"]), 4)
                self.assertIsNone(resposta["atendimento_selecionado"])

    def test_multiplos_atendimentos_pedem_esclarecimento(self):
        resposta = self.service.responder("psicólogo ou dermatologista")
        self.assertIn("Escolha apenas uma", resposta["mensagem"])
        self.assertEqual(resposta["etapa"], "especialidade")
        self.assertIsNone(resposta["atendimento_selecionado"])


if __name__ == "__main__":
    unittest.main()
