import 'package:flutter/material.dart';

class PacienteDashboardScreen extends StatelessWidget {
  const PacienteDashboardScreen({super.key});

  static const String routeName = '/paciente-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Área do Paciente")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Minhas Consultas"),
            onTap: () {
              Navigator.pushNamed(context, '/consulta-list');
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Resultados de Exames"),
            onTap: () {
              Navigator.pushNamed(context, '/exame-list');
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text("Procedimentos Realizados"),
            onTap: () {
              Navigator.pushNamed(context, '/procedimento-list');
            },
          ),
        ],
      ),
    );
  }
}
