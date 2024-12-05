import 'package:flutter/foundation.dart';

class DataProvider extends ChangeNotifier {
  double _height = 0;

  void setHeight(double height) {
    _height = height;
    notifyListeners();
  }

  double get height => _height;

  double calculateBMI(double weight, double height) {
    return weight / (height * height);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Desnutrición';
    if (bmi < 25) return 'Peso Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  // Métodos para calcular el IMC inicial y final de una semana
  String getWeeklyBMICategory(double weight, DateTime date) {
    double bmi = calculateBMI(weight, _height);
    return _getBMICategory(bmi);
  }

  // Métodos para obtener la categoría del IMC basándose en pesos semanales
  String getWeeklyInitialBMICategory(double initialWeight) {
    double bmi = calculateBMI(initialWeight, _height);
    return _getBMICategory(bmi);
  }

  String getWeeklyFinalBMICategory(double finalWeight) {
    double bmi = calculateBMI(finalWeight, _height);
    return _getBMICategory(bmi);
  }
}
