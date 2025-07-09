// lib/presentation/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/usuario.dart';
import 'package:flutter_clinica_medica/domain/repositories/usuario_repository.dart';
import 'package:flutter_clinica_medica/utils/password_util.dart';
import 'package:flutter_clinica_medica/presentation/home/main_dashboard_screen.dart';
import 'package:flutter_clinica_medica/presentation/paciente/paciente_dashboard_screen.dart'; // NOVO IMPORT
import 'package:flutter_clinica_medica/presentation/auth/register_screen.dart';
import 'package:flutter_clinica_medica/utils/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final AuthManager _authManager = AuthManager();

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        final user = await _usuarioRepository.getUsuarioByUsername(username);

        if (user != null && PasswordUtil.verifyPassword(password, user.passwordHash, user.salt)) {
          // Login bem-sucedido
          _authManager.login(user);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bem-vindo, ${user.username}!')),
          );

          // Redireciona de acordo com o tipo de usuário
          if (user.tipo.toLowerCase() == 'paciente') {
            Navigator.of(context).pushReplacementNamed(PacienteDashboardScreen.routeName);
          } else {
            Navigator.of(context).pushReplacementNamed(MainDashboardScreen.routeName);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nome de usuário ou senha inválidos.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tentar login: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Clínica Médica'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nome de Usuário'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome de usuário';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Entrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RegisterScreen.routeName);
                },
                child: const Text('Não tem uma conta? Registre-se!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
