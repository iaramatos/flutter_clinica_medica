// lib/presentation/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/domain/models/usuario.dart';
import 'package:flutter_clinica_medica/domain/repositories/usuario_repository.dart';
import 'package:flutter_clinica_medica/utils/password_util.dart'; // Importe o utilitário de senha

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedTipoUsuario = 'paciente'; // Padrão para registro

  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem!')),
        );
        return;
      }

      final salt = PasswordUtil.generateSalt();
      final hashedPassword = PasswordUtil.hashPassword(_passwordController.text, salt);

      final newUser = Usuario(
        username: _usernameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        passwordHash: hashedPassword,
        salt: salt,
        tipo: _selectedTipoUsuario!,
      );

      try {
        await _usuarioRepository.insertUsuario(newUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário registrado com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a tela de login
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar usuário: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Novo Usuário'),
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
                    return 'Por favor, insira um nome de usuário';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Opcional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter no mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirme a Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme a senha';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTipoUsuario,
                decoration: const InputDecoration(labelText: 'Tipo de Usuário'),
                items: const [
                  DropdownMenuItem(value: 'paciente', child: Text('Paciente')), // Paciente agora pode se registrar
                  DropdownMenuItem(value: 'medico', child: Text('Médico')),
                  DropdownMenuItem(value: 'enfermeiro', child: Text('Enfermeiro')),
                  DropdownMenuItem(value: 'recepcionista', child: Text('Recepcionista')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTipoUsuario = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione o tipo de usuário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}