// lib/presentation/home/iteration3_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_clinica_medica/presentation/medicamento/medicamento_list_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/financeiro/financeiro_form_screen.dart';
import 'package:flutter_clinica_medica/presentation/receita/prescricao_list_screen.dart'; // NOVO IMPORT

class Iteration3MenuScreen extends StatelessWidget {
  const Iteration3MenuScreen({super.key});

  static const String routeName = '/iteration3-menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iteração 3: Prescrição e Financeiro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(MedicamentoListScreen.routeName);
              },
              child: const Text('Gerenciar Medicamentos'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(PrescricaoFormScreen.routeName);
              },
              child: const Text('Prescrever Medicamento (Nova Receita)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(PrescricaoListScreen.routeName); // NOVO BOTÃO
              },
              child: const Text('Ver Prescrições Cadastradas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(FinanceiroFormScreen.routeName);
              },
              child: const Text('Registrar Pagamento de Consulta'),
            ),
          ],
        ),
      ),
    );
  }
}