import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Models/bmi_model.dart';
import 'package:proyecto/Servicies/firestore_services.dart';

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _bmi;
  String _bmiMessage = '';
  final FirestoreServices _firestoreServices = FirestoreServices();

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      final height =
          double.parse(_heightController.text) / 100; // Convertir a metros

      setState(() {
        _bmi = weight / (height * height);
        _bmiMessage = _getBmiMessage(_bmi!);
      });

      final bmiData = BMIData(
        weight: weight,
        height: height * 100, // Convertir a cm
        bmi: _bmi,
        bmiCategory: _bmiMessage, // Guardar la categoría del IMC
        timestamp: Timestamp.now(),
      );

      final result = await _firestoreServices.addBMIData(bmiData);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos guardados correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar los datos.')),
        );
      }
    }
  }

  void _resetData() {
    setState(() {
      _weightController.clear();
      _heightController.clear();
      _bmi = null;
      _bmiMessage = '';
    });
  }

  String _getBmiMessage(double bmi) {
    if (bmi < 18.5) {
      return 'Bajo peso';
    } else if (bmi < 24.9) {
      return 'Peso normal';
    } else if (bmi < 29.9) {
      return 'Sobrepeso';
    } else {
      return 'Obesidad';
    }
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un valor';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return 'Por favor ingrese un número válido';
    }
    return null;
  }

  Widget _buildBmiTable() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      children: [
        _buildTableRow('Categoría', 'IMC', isHeader: true),
        _buildTableRow('Bajo peso', 'Si tu IMC es menor a 18.5'),
        _buildTableRow('Peso normal', 'Si tu IMC es entre 18.5 y 24.9'),
        _buildTableRow('Sobrepeso', 'Si tu IMC es entre 25.0 y 29.9'),
        _buildTableRow('Obesidad', 'Si tu IMC es mayor a 30.0'),
      ],
    );
  }

  TableRow _buildTableRow(String category, String bmiRange,
      {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? BoxDecoration(
              color: Colors
                  .lightBlueAccent, // Cambia el color de fondo para el encabezado
            )
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader
                  ? Colors.white
                  : Colors.black, // Cambia el color del texto
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            bmiRange,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader
                  ? Colors.white
                  : Colors.black, // Cambia el color del texto
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
      ),
      backgroundColor: Color.fromARGB(255, 67, 129, 244),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Calculadora de IMC',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 63, 81, 181),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ingrese su peso en kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: _validateNumber,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ingrese su altura en cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: _validateNumber,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 66, 81, 180),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Calcular IMC',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_bmi != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ESTE ES SU ÍNDICE DE MASA CORPORAL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _bmi!.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _bmiMessage,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _resetData,
                              child: Text('Agregar Nuevos Datos'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  _buildBmiTable(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
