// lib/utils/auth_manager.dart

import 'package:flutter_clinica_medica/domain/models/usuario.dart';

// Classe singleton para gerenciar o usuário logado
class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  Usuario? _currentUser; // O usuário logado atualmente

  Usuario? get currentUser => _currentUser;

  // Define o usuário quando ele faz login
  void login(Usuario user) {
    _currentUser = user;
    print('Usuário ${_currentUser?.username} logado como ${_currentUser?.tipo}');
  }

  // Limpa o usuário quando ele faz logout
  void logout() {
    _currentUser = null;
    print('Usuário deslogado.');
  }

  // Métodos auxiliares para verificar o tipo de usuário
  bool get isAdmin => _currentUser?.tipo == 'admin';
  bool get isMedico => _currentUser?.tipo == 'medico';
  bool get isEnfermeiro => _currentUser?.tipo == 'enfermeiro';
  bool get isRecepcionista => _currentUser?.tipo == 'recepcionista';
  bool get isPaciente => _currentUser?.tipo == 'paciente';
  bool get isLoggedIn => _currentUser != null; // Verifica se há um usuário logado
}