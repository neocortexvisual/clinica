import unittest

from fastapi.testclient import TestClient

from main import app


class MensagensApiTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_saudacao_e_escolha_pela_api(self):
        inicio = self.client.post("/chatbot/mensagens", json={"texto": "Oi, boa tarde!"})
        self.assertEqual(inicio.status_code, 200)
        self.assertEqual(inicio.json()["etapa"], "especialidade")
        self.assertEqual(len(inicio.json()["opcoes"]), 4)
        escolhido = self.client.post("/chatbot/mensagens", json={"texto": "2"})
        self.assertEqual(escolhido.status_code, 200)
        self.assertEqual(escolhido.json()["atendimento_selecionado"]["id"], "psicologo")

    def test_entrada_invalida_retorna_422(self):
        for corpo in ({"texto": "   "}, {}, {"texto": "x" * 2001}, {"texto": "oi", "extra": 1}):
            with self.subTest(corpo=corpo):
                resposta = self.client.post("/chatbot/mensagens", json=corpo)
                self.assertEqual(resposta.status_code, 422)

    def test_healthcheck(self):
        resposta = self.client.get("/health")
        self.assertEqual(resposta.status_code, 200)
        self.assertEqual(resposta.json(), {"status": "ok"})

    def test_cors_permite_flutter_em_porta_local_variavel(self):
        resposta = self.client.options(
            "/chatbot/mensagens",
            headers={
                "Origin": "http://localhost:54321",
                "Access-Control-Request-Method": "POST",
                "Access-Control-Request-Headers": "content-type",
            },
        )
        self.assertEqual(resposta.status_code, 200)
        self.assertEqual(
            resposta.headers["access-control-allow-origin"], "http://localhost:54321"
        )

    def test_cors_nao_libera_origem_externa(self):
        resposta = self.client.options(
            "/chatbot/mensagens",
            headers={
                "Origin": "https://exemplo.com",
                "Access-Control-Request-Method": "POST",
            },
        )
        self.assertEqual(resposta.status_code, 400)
        self.assertNotIn("access-control-allow-origin", resposta.headers)


if __name__ == "__main__":
    unittest.main()
