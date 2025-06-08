// lib/domain/models/paciente.dart

class Paciente {
  int? idPaciente;
  String nome;
  String cpf;
  DateTime? dataNascimento;
  String? telefone;
  String? email;
  String? endereco;
  String? convenio;
  String? alergias;                     // NOVO
  String? condicoesPreExistentes;       // NOVO

  Paciente({
    this.idPaciente,
    required this.nome,
    required this.cpf,
    this.dataNascimento,
    this.telefone,
    this.email,
    this.endereco,
    this.convenio,
    this.alergias,                     // NOVO
    this.condicoesPreExistentes,       // NOVO
  });

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'nome': nome,
      'cpf': cpf,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'convenio': convenio,
      'alergias': alergias,                     // NOVO
      'condicoesPreExistentes': condicoesPreExistentes, // NOVO
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      idPaciente: map['idPaciente'] as int?,
      nome: map['nome'] as String,
      cpf: map['cpf'] as String,
      dataNascimento: map['dataNascimento'] != null
          ? DateTime.parse(map['dataNascimento'] as String)
          : null,
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      endereco: map['endereco'] as String?,
      convenio: map['convenio'] as String?,
      alergias: map['alergias'] as String?,                     // NOVO
      condicoesPreExistentes: map['condicoesPreExistentes'] as String?, // NOVO
    );
  }

  @override
  String toString() {
    return 'Paciente(idPaciente: $idPaciente, nome: $nome, cpf: $cpf)';
  }
}