import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController genderController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: heightController,
            decoration: const InputDecoration(labelText: 'Altura (cm)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: weightController,
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: 'Edad'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: genderController,
            decoration: const InputDecoration(labelText: 'Sexo'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Calcular IMC'),
            onPressed: () {
              // Implement IMC calculation and navigation to results
            },
          ),
        ],
      ),
    );
  }
}
