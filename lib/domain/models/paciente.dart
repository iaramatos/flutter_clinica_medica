// lib/domain/models/paciente.dart

class Paciente {
  int? idPaciente;
  int? idUsuario; // NOVO: Chave estrangeira para Usuario
  String nome;
  String cpf;
  DateTime? dataNascimento;
  String? telefone;
  String? email;
  String? endereco;
  String? convenio;
  String? alergias;
  String? condicoesPreExistentes;

  Paciente({
    this.idPaciente,
    this.idUsuario, // NOVO: Adicionado ao construtor
    required this.nome,
    required this.cpf,
    this.dataNascimento,
    this.telefone,
    this.email,
    this.endereco,
    this.convenio,
    this.alergias,
    this.condicoesPreExistentes,
  });

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'idUsuario': idUsuario, // NOVO: Adicionado ao toMap
      'nome': nome,
      'cpf': cpf,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'convenio': convenio,
      'alergias': alergias,
      'condicoesPreExistentes': condicoesPreExistentes,
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      idPaciente: map['idPaciente'] as int?,
      idUsuario: map['idUsuario'] as int?, // NOVO: Adicionado ao fromMap
      nome: map['nome'] as String,
      cpf: map['cpf'] as String,
      dataNascimento: map['dataNascimento'] != null
          ? DateTime.parse(map['dataNascimento'] as String)
          : null,
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      endereco: map['endereco'] as String?,
      convenio: map['convenio'] as String?,
      alergias: map['alergias'] as String?,
      condicoesPreExistentes: map['condicoesPreExistentes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Paciente(idPaciente: $idPaciente, nome: $nome, cpf: $cpf, idUsuario: $idUsuario)';
  }
}