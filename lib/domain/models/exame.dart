// lib/models/exame.dart

class Exame {
  int? idExame;
  String? nome;
  String? descricao;

  Exame({
    this.idExame,
    this.nome,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'idExame': idExame,
      'nome': nome,
      'descricao': descricao,
    };
  }

  factory Exame.fromMap(Map<String, dynamic> map) {
    return Exame(
      idExame: map['idExame'] as int?,
      nome: map['nome'] as String?,
      descricao: map['descricao'] as String?,
    );
  }

  @override
  String toString() {
    return 'Exame(idExame: $idExame, nome: $nome)';
  }
}