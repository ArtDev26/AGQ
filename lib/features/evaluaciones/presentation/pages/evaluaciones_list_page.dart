import 'package:flutter/material.dart';

class EvaluacionesListPage extends StatelessWidget {
  const EvaluacionesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluaciones')),
      body: const Center(child: Text('Listado de evaluaciones (pendiente)')),
    );
  }
}
