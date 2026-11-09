class Atendimento {
  final String id;
  final String nomePaciente;
  final String motivo;
  final DateTime dataHoraEntrada;

  Atendimento({
    required this.id,
    required this.nomePaciente,
    required this.motivo,
    required this.dataHoraEntrada,
  });

  // Função útil para transformar os dados para formato que a base de dados entende
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomePaciente': nomePaciente,
      'motivo': motivo,
      'dataHoraEntrada': dataHoraEntrada.toIso8601String(),
    };
  }
}
