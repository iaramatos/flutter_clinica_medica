// lib/domain/models/usuario.dart

class Usuario {
  int? idUsuario;
  String username;
  String passwordHash; // Armazena o hash da senha
  String salt;         // Armazena o salt
  String? email;
  String tipo;         // 'admin', 'medico', 'enfermeiro', 'recepcionista', 'paciente'

  Usuario({
    this.idUsuario,
    required this.username,
    required this.passwordHash,
    required this.salt,
    this.email,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'username': username,
      'passwordHash': passwordHash,
      'salt': salt,
      'email': email,
      'tipo': tipo,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'] as int?,
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
      salt: map['salt'] as String,
      email: map['email'] as String?,
      tipo: map['tipo'] as String,
    );
  }

  @override
  String toString() {
    return 'Usuario(idUsuario: $idUsuario, username: $username, tipo: $tipo)';
  }
}