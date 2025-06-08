// lib/models/sala.dart

class Sala {
  int? idSala;
  String? nome;
  String? tipo;
  int? capacidade;

  Sala({
    this.idSala,
    this.nome,
    this.tipo,
    this.capacidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'idSala': idSala,
      'nome': nome,
      'tipo': tipo,
      'capacidade': capacidade,
    };
  }

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      idSala: map['idSala'] as int?,
      nome: map['nome'] as String?,
      tipo: map['tipo'] as String?,
      capacidade: map['capacidade'] as int?,
    );
  }

  @override
  String toString() {
    return 'Sala(idSala: $idSala, nome: $nome, tipo: $tipo, capacidade: $capacidade)';
  }
}