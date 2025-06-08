// lib/models/profissional.dart

class Profissional {
  int? idProfissional;
  String nome;
  String? especialidade;
  String? registro;
  String? email;
  String? telefone;
  String tipoUsuario; // ENUM('admin', 'medico', 'enfermeiro', 'recepcionista')

  Profissional({
    this.idProfissional,
    required this.nome,
    this.especialidade,
    this.registro,
    this.email,
    this.telefone,
    required this.tipoUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'idProfissional': idProfissional,
      'nome': nome,
      'especialidade': especialidade,
      'registro': registro,
      'email': email,
      'telefone': telefone,
      'tipoUsuario': tipoUsuario,
    };
  }

  factory Profissional.fromMap(Map<String, dynamic> map) {
    return Profissional(
      idProfissional: map['idProfissional'] as int?,
      nome: map['nome'] as String,
      especialidade: map['especialidade'] as String?,
      registro: map['registro'] as String?,
      email: map['email'] as String?,
      telefone: map['telefone'] as String?,
      tipoUsuario: map['tipoUsuario'] as String,
    );
  }

  @override
  String toString() {
    return 'Profissional(idProfissional: $idProfissional, nome: $nome, especialidade: $especialidade, tipoUsuario: $tipoUsuario)';
  }
}