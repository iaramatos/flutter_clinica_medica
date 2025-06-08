// lib/models/medicamento.dart

class Medicamento {
  int? idMedicamento;
  String nome;
  String? descricao;
  int? estoqueAtual;

  Medicamento({
    this.idMedicamento,
    required this.nome,
    this.descricao,
    this.estoqueAtual,
  });

  Map<String, dynamic> toMap() {
    return {
      'idMedicamento': idMedicamento,
      'nome': nome,
      'descricao': descricao,
      'estoqueAtual': estoqueAtual,
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      idMedicamento: map['idMedicamento'] as int?,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String?,
      estoqueAtual: map['estoqueAtual'] as int?,
    );
  }

  @override
  String toString() {
    return 'Medicamento(idMedicamento: $idMedicamento, nome: $nome, estoqueAtual: $estoqueAtual)';
  }
}