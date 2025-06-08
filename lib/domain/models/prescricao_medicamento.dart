// lib/models/prescricao_medicamento.dart

class PrescricaoMedicamento {
  int? idPrescricao;
  int? idReceita;
  int? idMedicamento;
  String? dosagem;
  String? via;
  String? frequencia;

  PrescricaoMedicamento({
    this.idPrescricao,
    this.idReceita,
    this.idMedicamento,
    this.dosagem,
    this.via,
    this.frequencia,
  });

  Map<String, dynamic> toMap() {
    return {
      'idPrescricao': idPrescricao,
      'idReceita': idReceita,
      'idMedicamento': idMedicamento,
      'dosagem': dosagem,
      'via': via,
      'frequencia': frequencia,
    };
  }

  factory PrescricaoMedicamento.fromMap(Map<String, dynamic> map) {
    return PrescricaoMedicamento(
      idPrescricao: map['idPrescricao'] as int?,
      idReceita: map['idReceita'] as int?,
      idMedicamento: map['idMedicamento'] as int?,
      dosagem: map['dosagem'] as String?,
      via: map['via'] as String?,
      frequencia: map['frequencia'] as String?,
    );
  }

  @override
  String toString() {
    return 'PrescricaoMedicamento(idPrescricao: $idPrescricao, idReceita: $idReceita, idMedicamento: $idMedicamento)';
  }
}