// lib/domain/models/paciente.dart

class Paciente {
  int? idPaciente; // AUTO_INCREMENT no SQL, então pode ser nulo na criação
  String nome;
  String cpf;
  DateTime? dataNascimento; // DATE no SQL
  String? telefone;
  String? email;
  String? endereco;
  String? convenio;
  String? alergias;                     // NOVO: Adicionado aqui
  String? condicoesPreExistentes;       // NOVO: Adicionado aqui

  Paciente({
    this.idPaciente,
    required this.nome,
    required this.cpf,
    this.dataNascimento,
    this.telefone,
    this.email,
    this.endereco,
    this.convenio,
    this.alergias,                     // NOVO: Adicionado ao construtor
    this.condicoesPreExistentes,       // NOVO: Adicionado ao construtor
  });

  // Método para converter um Paciente em um Map (para inserção no banco)
  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'nome': nome,
      'cpf': cpf,
      'dataNascimento': dataNascimento?.toIso8601String(), // Converte DateTime para String para o banco
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'convenio': convenio,
      'alergias': alergias,                     // NOVO: Adicionado ao toMap
      'condicoesPreExistentes': condicoesPreExistentes, // NOVO: Adicionado ao toMap
    };
  }

  // Método para criar um Paciente a partir de um Map (lido do banco)
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
      alergias: map['alergias'] as String?,                     // NOVO: Adicionado ao fromMap
      condicoesPreExistentes: map['condicoesPreExistentes'] as String?, // NOVO: Adicionado ao fromMap
    );
  }

  @override
  String toString() {
    return 'Paciente(idPaciente: $idPaciente, nome: $nome, cpf: $cpf, dataNascimento: $dataNascimento, telefone: $telefone, email: $email, endereco: $endereco, convenio: $convenio, alergias: $alergias, condicoesPreExistentes: $condicoesPreExistentes)';
  }
}