import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/Models/bmi_model.dart';
import 'dart:developer' as developer;

import 'package:proyecto/Models/data_provider.dart';

class FirestoreServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia de FirebaseAuth

  Future<bool> addBMIData(BMIData bmiData) async {
    try {
      final user = _auth.currentUser; // Obtener el usuario actual
      if (user != null) {
        bmiData.userId = user.uid; // Asignar el uid del usuario al modelo
        await db.collection("bmi_data").add(bmiData.toJson());
        developer.log('BMI data saved: ${bmiData.toJson()}'); // Agregar log
        return true;
      }
      developer.log('No user found');
      return false;
    } catch (ex) {
      developer.log('Error saving BMI data: ${ex.toString()}'); // Agregar log
      return false;
    }
  }

  Future<BMIData?> getLastBMIData() async {
    try {
      final user = _auth.currentUser; // Obtener el usuario actual
      if (user == null) {
        developer.log('No user found');
        return null;
      }

      final querySnapshot = await db
          .collection("bmi_data")
          .where("userId", isEqualTo: user.uid) // Filtrar por userId
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        developer.log(
            'BMI data fetched: ${querySnapshot.docs.first.data()}'); // Agregar log
        return BMIData.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        developer.log('No BMI data found');
        return null;
      }
    } catch (ex) {
      developer.log('Error fetching BMI data: ${ex.toString()}'); // Agregar log
      return null;
    }
  }

  Future<double?> getUserHeight() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final querySnapshot = await db
          .collection("bmi_data")
          .where("userId", isEqualTo: user.uid)
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final height = querySnapshot.docs.first.data()["height"];
        return height != null ? height / 100 : null; // Convertir de cm a metros
      }
      return null;
    } catch (ex) {
      developer.log('Error fetching height data: ${ex.toString()}');
      return null;
    }
  }

  Future<void> addDailyData(Map<String, dynamic> dailyData) async {
    try {
      await db.collection("daily_data").add(dailyData);
      developer.log('Daily data saved: $dailyData');
    } catch (ex) {
      developer.log('Error saving daily data: ${ex.toString()}');
    }
  }

  Future<Map<String, dynamic>> getWeeklyData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        developer.log('No user found');
        return {};
      }

      final querySnapshot = await db
          .collection("daily_data")
          .where("userId", isEqualTo: user.uid)
          .orderBy("date")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docs = querySnapshot.docs.map((doc) => doc.data()).toList();

        // Obtenemos el primer y último registro
        final firstRecord = docs.first;
        final lastRecord = docs.last;

        return {
          'weightInitial': firstRecord['weight'] ?? 0.0,
          'weightFinal': lastRecord['weight'] ?? 0.0,
        };
      }
      return {};
    } catch (ex) {
      developer.log('Error fetching data: ${ex.toString()}');
      return {};
    }
  }

  Future<void> saveRoutines() async {
    try {
      developer.log('Saving routines...');
      developer.log('saveRoutines() called');
      // Rutina para "Bajo peso"
      Map<String, dynamic> bajoPesoRoutine = {
        "day1": {
          "exercise":
              "Flexiones de pecho (3x10-12), Press de banca con mancuernas (3x10-12), Remo con mancuerna (3x10-12), Estiramientos",
          "cardio": "Caminar o nadar a baja intensidad (20 minutos)",
        },
        "day2": {
          "exercise":
              "Sentadillas con peso corporal (3x10-12), Peso muerto con barra (3x10-12), Zancadas con mancuernas (3x10-12), Estiramientos",
          "cardio": "N/A",
        },
        "day3": {
          "exercise":
              "Descanso o actividad ligera: Yoga o caminata ligera (30 minutos)",
          "cardio": "N/A",
        },
        "day4": {
          "exercise":
              "Circuito de ejercicios: Flexiones, sentadillas, press de hombros, remo con mancuerna (3x10-12 cada uno), Estiramientos",
          "cardio": "N/A",
        },
        "day5": {
          "exercise":
              "Entrenamiento de core: Plancha (3x30 segundos), abdominales (3x15)",
          "cardio": "Correr o ciclismo (30 minutos)",
        },
      };

      // Rutina para "Peso Normal"
      Map<String, dynamic> pesoNormalRoutine = {
        "day1": {
          "exercise":
              "Press de banca (3x10-12), Flexiones de pecho (3x10-12), Remo con mancuerna (3x10-12)",
          "cardio": "Correr o ciclismo (30 minutos)",
        },
        "day2": {
          "exercise":
              "Entrenamiento HIIT (20 minutos): 30 segundos de alta intensidad (sprints, saltos de tijera), 30 segundos de descanso, Plancha (3x30 segundos), abdominales (3x15)",
          "cardio": "N/A",
        },
        "day3": {
          "exercise":
              "Sentadillas con barra (3x10-12), Zancadas con mancuernas (3x10-12), Peso muerto (3x10-12)",
          "cardio": "N/A",
        },
        "day4": {
          "exercise":
              "Yoga (30 minutos): Estiramientos y posturas de flexibilidad",
          "cardio": "Natación o ciclismo (30 minutos)",
        },
        "day5": {
          "exercise":
              "Flexiones, sentadillas, press de hombros, burpees (3x10-12 cada uno)",
          "cardio": "Enfriamiento: Estiramientos de 10-15 minutos",
        },
      };

      // Rutina para "Sobrepeso"
      Map<String, dynamic> sobrepesoRoutine = {
        "day1": {
          "exercise":
              "Press de hombros (3x10-12), Remo con mancuerna (3x10-12), Flexiones de pared (3x10-12)",
          "cardio": "Caminata rápida o natación (30 minutos)",
        },
        "day2": {
          "exercise":
              "Sentadillas asistidas (3x10-12), Peso muerto con barra (3x10-12), Zancadas con mancuernas (3x10-12), Estiramientos",
          "cardio": "N/A",
        },
        "day3": {
          "exercise": "Abdominales (3x15), plancha (3x30 segundos)",
          "cardio": "Bicicleta o caminata (30 minutos)",
        },
        "day4": {
          "exercise":
              "Circuito de ejercicios: Flexiones, sentadillas, burpees, press de hombros (3x10-12 cada uno), Yoga o estiramientos (30 minutos)",
          "cardio": "N/A",
        },
        "day5": {
          "exercise":
              "Circuito ligero: Sentadillas, remo con mancuerna, zancadas (3x10-12 cada uno)",
          "cardio": "Natación o elíptica (30 minutos)",
        },
      };

      // Rutina para "Obesidad"
      Map<String, dynamic> obesidadRoutine = {
        "day1": {
          "exercise":
              "Flexiones de pared (3x10-12), Remo con banda elástica (3x10-12), Press de hombros sentado (3x10-12)",
          "cardio": "Caminata rápida (30 minutos)",
        },
        "day2": {
          "exercise": "Plancha asistida (3x20 segundos), abdominales (3x10-15)",
          "cardio": "Bicicleta estática o natación (30 minutos)",
        },
        "day3": {
          "exercise":
              "Sentadillas asistidas (3x10-12), Zancadas asistidas (3x10-12), Ejercicios de glúteos con banda (3x10-12)",
          "cardio": "N/A",
        },
        "day4": {
          "exercise":
              "Yoga o estiramientos suaves (30 minutos): Posturas básicas y respiración profunda",
          "cardio": "Caminata o natación (30 minutos)",
        },
        "day5": {
          "exercise":
              "Circuito ligero: Flexiones de pared, sentadillas, press de hombros con banda (3x10-12 cada uno)",
          "cardio": "Estiramiento y relajación (10-15 minutos)",
        },
      };

      // Guardar las rutinas en Firestore
      await db.collection("routines").doc("Bajo peso").set(bajoPesoRoutine);
      developer.log('Bajo peso routine saved');

      await db.collection("routines").doc("Peso normal").set(pesoNormalRoutine);
      developer.log('Peso normal routine saved');

      await db.collection("routines").doc("Sobrepeso").set(sobrepesoRoutine);
      developer.log('Sobrepeso routine saved');

      await db.collection("routines").doc("Obesidad").set(obesidadRoutine);
      developer.log('Obesidad routine saved');
    } catch (ex) {
      developer.log('Error saving routines: ${ex.toString()}');
    }
  }

  Future<Map<String, dynamic>> getRoutineForCategory(String category) async {
    DocumentSnapshot doc = await db.collection("routines").doc(category).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception("Rutina no encontrada para la categoría $category");
    }
  }

  Future<void> saveDiets() async {
    try {
      developer.log('Saving diets...');

      // Dieta para "Bajo peso"
      Map<String, dynamic> bajoPesoDiet = {
        "Lunes": {
          "Desayuno": "Avena con leche entera, frutas, nueces.",
          "Refrigerio": "Yogur griego con miel y frutos secos.",
          "Almuerzo": "Pechuga de pollo, arroz integral, verduras.",
          "Merienda": "Tostadas integrales con mantequilla de maní.",
          "Cena": "Salmón al horno, quinoa, espinacas.",
        },
        "Martes": {
          "Desayuno": "Batido de proteínas con plátano y leche.",
          "Refrigerio": "Barra de granola con frutos secos.",
          "Almuerzo": "Ensalada de atún con aguacate y pan integral.",
          "Merienda": "Batido de frutas con yogur.",
          "Cena": "Pasta integral con pollo y salsa de tomate.",
        },
        "Miércoles": {
          "Desayuno": "Tostadas con aguacate, huevo, y un zumo de naranja.",
          "Refrigerio": "Fruta fresca (manzana o pera) y nueces.",
          "Almuerzo": "Hamburguesa de pavo con batata al horno.",
          "Merienda": "Batido de proteínas.",
          "Cena": "Pollo al curry con arroz y verduras al vapor.",
        },
        "Jueves": {
          "Desayuno": "Smoothie bowl con frutas, avena, y semillas.",
          "Refrigerio": "Frutas con queso cottage.",
          "Almuerzo": "Ensalada de quinoa con pollo y vegetales mixtos.",
          "Merienda": "Galletas integrales con mantequilla de almendra.",
          "Cena": "Filete de ternera con puré de patatas y brócoli.",
        },
        "Viernes": {
          "Desayuno": "Panqueques de avena con miel y frutas.",
          "Refrigerio": "Yogur griego con granola.",
          "Almuerzo": "Pasta con albóndigas de pollo y ensalada.",
          "Merienda": "Barrita de proteínas.",
          "Cena": "Pescado al horno con patatas asadas y espárragos.",
        },
      };

      // Dieta para "Peso Normal"
      Map<String, dynamic> pesoNormalDiet = {
        "Lunes": {
          "Desayuno": "Tostadas integrales con aguacate y huevo poché.",
          "Refrigerio": "Fruta fresca y almendras.",
          "Almuerzo": "Ensalada de quinua con pollo y espinacas.",
          "Merienda": "Batido verde.",
          "Cena": "Filete de pescado al horno con vegetales.",
        },
        "Martes": {
          "Desayuno": "Yogur natural con granola y frutas.",
          "Refrigerio": "Un puñado de nueces y un plátano.",
          "Almuerzo": "Wrap integral de pavo con verduras y hummus.",
          "Merienda": "Smoothie de proteínas.",
          "Cena":
              "Pechuga de pollo a la parrilla con arroz integral y brócoli.",
        },
        "Miércoles": {
          "Desayuno": "Avena con frutas y semillas de chía.",
          "Refrigerio": "Zanahorias y hummus.",
          "Almuerzo": "Salmón a la plancha con ensalada de espinacas.",
          "Merienda": "Batido de frutas con yogur.",
          "Cena": "Tofu salteado con quinoa y verduras.",
        },
        "Jueves": {
          "Desayuno": "Smoothie bowl con frutas, avena, y nueces.",
          "Refrigerio": "Yogur con miel y frutos secos.",
          "Almuerzo": "Ensalada de garbanzos con atún y aguacate.",
          "Merienda": "Barrita de cereales integral.",
          "Cena": "Pasta integral con verduras y pollo al horno.",
        },
        "Viernes": {
          "Desayuno": "Tortilla de claras con espinacas y un zumo de naranja.",
          "Refrigerio": "Manzana con mantequilla de almendra.",
          "Almuerzo": "Ensalada de pollo con aguacate y semillas de girasol.",
          "Merienda": "Un puñado de frutos secos.",
          "Cena": "Pescado al vapor con patatas al horno y espárragos.",
        },
      };

      // Dieta para "Sobrepeso"
      Map<String, dynamic> sobrepesoDiet = {
        "Lunes": {
          "Desayuno": "Batido de proteínas con espinacas y frutas.",
          "Refrigerio": "Zanahorias y hummus.",
          "Almuerzo": "Ensalada de pollo a la parrilla con verduras y quinoa.",
          "Merienda": "Un puñado de frutos secos.",
          "Cena": "Pescado al horno con batata y espárragos.",
        },
        "Martes": {
          "Desayuno": "Avena cocida con bayas y nueces.",
          "Refrigerio": "Frutas frescas y almendras.",
          "Almuerzo": "Ensalada de garbanzos con atún.",
          "Merienda": "Yogur bajo en grasa con semillas de lino.",
          "Cena": "Pollo al curry con arroz integral.",
        },
        "Miércoles": {
          "Desayuno": "Tostadas integrales con aguacate y huevo poché.",
          "Refrigerio": "Manzana con un puñado de nueces.",
          "Almuerzo": "Sopa de vegetales con pechuga de pollo.",
          "Merienda": "Batido de proteínas.",
          "Cena": "Salmón al vapor con quinoa y espinacas.",
        },
        "Jueves": {
          "Desayuno": "Batido verde con espinacas, manzana y pepino.",
          "Refrigerio": "Palitos de apio con hummus.",
          "Almuerzo": "Ensalada de espinacas con nueces y pechuga de pollo.",
          "Merienda": "Yogur griego con semillas de chía.",
          "Cena": "Tofu salteado con arroz integral.",
        },
        "Viernes": {
          "Desayuno": "Tortilla de claras con verduras y un zumo de naranja.",
          "Refrigerio": "Un puñado de frutos secos.",
          "Almuerzo": "Wrap de pavo con ensalada.",
          "Merienda": "Batido de frutas.",
          "Cena": "Filete de pescado al horno con brócoli.",
        },
      };

      // Dieta para "Obesidad"
      Map<String, dynamic> obesidadDiet = {
        "Lunes": {
          "Desayuno": "Avena cocida con frutas y nueces.",
          "Refrigerio": "Palitos de zanahoria con hummus.",
          "Almuerzo": "Sopa de verduras con pechuga de pollo desmenuzada.",
          "Merienda": "Fruta fresca (manzana o pera).",
          "Cena": "Pescado al vapor con brócoli y batata al horno.",
        },
        "Martes": {
          "Desayuno": "Smoothie de espinacas con plátano y semillas de lino.",
          "Refrigerio": "Yogur natural con semillas de chía.",
          "Almuerzo": "Ensalada de quinoa con garbanzos y espinacas.",
          "Merienda": "Frutas frescas (manzana o pera).",
          "Cena": "Pollo a la plancha con espárragos y arroz integral.",
        },
        "Miércoles": {
          "Desayuno": "Tostadas integrales con aguacate y huevo duro.",
          "Refrigerio": "Almendras y una pieza de fruta.",
          "Almuerzo": "Ensalada de espinacas con atún y aguacate.",
          "Merienda": "Yogur bajo en grasa con semillas de lino.",
          "Cena": "Tofu al horno con brócoli y quinoa.",
        },
        "Jueves": {
          "Desayuno": "Avena cocida con bayas y semillas de chía.",
          "Refrigerio": "Un puñado de nueces y una manzana.",
          "Almuerzo": "Wrap de pavo con ensalada de espinacas y aguacate.",
          "Merienda": "Batido de proteínas.",
          "Cena": "Pescado al horno con espárragos y arroz integral.",
        },
        "Viernes": {
          "Desayuno": "Tortilla de claras con verduras y un zumo de naranja.",
          "Refrigerio": "Un puñado de frutos secos.",
          "Almuerzo": "Ensalada de pollo con aguacate y semillas de girasol.",
          "Merienda": "Batido de frutas.",
          "Cena": "Filete de pescado al horno con brócoli.",
        },
      };

      // Guardar los planes de dieta en Firestore
      await db.collection("diet_plans").doc("Bajo peso").set(bajoPesoDiet);
      developer.log('Bajo peso diet plan saved');

      await db.collection("diet_plans").doc("Peso normal").set(pesoNormalDiet);
      developer.log('Peso normal diet plan saved');

      await db.collection("diet_plans").doc("Sobrepeso").set(sobrepesoDiet);
      developer.log('Sobrepeso diet plan saved');

      await db.collection("diet_plans").doc("Obesidad").set(obesidadDiet);
      developer.log('Obesidad diet plan saved');
    } catch (ex) {
      developer.log('Error saving diet plans: ${ex.toString()}');
    }
  }

  Future<Map<String, dynamic>> getDietPlanForCategory(String category) async {
    DocumentSnapshot doc =
        await db.collection("diet_plans").doc(category).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception(
          "Plan de dieta no encontrado para la categoría $category");
    }
  }
}
