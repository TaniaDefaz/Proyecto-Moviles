import 'package:cloud_firestore/cloud_firestore.dart';

class BMIData {
  BMIData({
    this.weight,
    this.height,
    this.bmi,
    this.bmiCategory, // Nuevo campo para la categoría de IMC
    this.timestamp,
    this.userId,
  });

  double? weight;
  double? height;
  double? bmi;
  String? bmiCategory; // Nueva propiedad
  Timestamp? timestamp;
  String? userId;

  factory BMIData.fromJson(Map<String, dynamic> json) => BMIData(
        weight: json["weight"],
        height: json["height"],
        bmi: json["bmi"],
        bmiCategory: json["bmiCategory"], // Asignación desde JSON
        timestamp: json["timestamp"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "weight": weight,
        "height": height,
        "bmi": bmi,
        "bmiCategory": bmiCategory, // Conversión a JSON
        "timestamp": timestamp,
        "userId": userId,
      };
}
