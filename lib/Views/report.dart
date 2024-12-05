import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Models/data_provider.dart';
import 'package:proyecto/Servicies/firestore_services.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  double weightInitial = 0;
  double weightFinal = 0;
  String initialBMICategory = '';
  String finalBMICategory = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateWeeklyReport();
  }

  Future<void> _generateWeeklyReport() async {
    final data = await _firestoreServices.getWeeklyData();

    if (data.isNotEmpty) {
      weightInitial = data['weightInitial'] ?? 0.0;
      weightFinal = data['weightFinal'] ?? 0.0;

      double? userHeight = await _firestoreServices.getUserHeight();

      if (userHeight != null) {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        dataProvider.setHeight(userHeight);
        initialBMICategory =
            dataProvider.getWeeklyInitialBMICategory(weightInitial);
        finalBMICategory = dataProvider.getWeeklyFinalBMICategory(weightFinal);
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double weightChange = weightInitial - weightFinal;
    bool lostWeight = weightChange > 0;
    bool changedCategory = initialBMICategory != finalBMICategory;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte Semanal'),
        backgroundColor: Colors.lightBlue[100],
      ),
      backgroundColor: Color.fromARGB(255, 224, 240, 255), // Azul muy claro
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.lightBlue[300]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitleSection('Resumen de Peso', Icons.monitor_weight),
                  _buildInfoCard(
                    title: 'Peso Inicial',
                    value: '${weightInitial.toStringAsFixed(2)} kg',
                    icon: Icons.fitness_center,
                  ),
                  _buildInfoCard(
                    title: 'Peso Final',
                    value: '${weightFinal.toStringAsFixed(2)} kg',
                    icon: Icons.fitness_center,
                  ),
                  _buildInfoCard(
                    title: 'Cambio de Peso',
                    value: '${weightChange.toStringAsFixed(2)} kg',
                    icon:
                        lostWeight ? Icons.arrow_downward : Icons.arrow_upward,
                    valueColor:
                        lostWeight ? Colors.green[700] : Colors.red[700],
                  ),
                  SizedBox(height: 20),
                  _buildTitleSection('Categoría IMC', Icons.category),
                  _buildBMICategoryCard(
                    initialCategory: initialBMICategory,
                    finalCategory: finalBMICategory,
                  ),
                  SizedBox(height: 20),
                  _buildTitleSection('Resultados', Icons.assessment),
                  _buildResultCard(
                    title: '¿Perdió Peso?',
                    result: lostWeight ? "Sí" : "No",
                    resultColor:
                        lostWeight ? Colors.green[700]! : Colors.red[700]!,
                  ),
                  _buildResultCard(
                    title: '¿Bajó de Categoría IMC?',
                    result: changedCategory ? "Sí" : "No",
                    resultColor:
                        changedCategory ? Colors.green[700]! : Colors.red[700]!,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTitleSection(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.lightBlue[300], size: 28),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.lightBlue[300]),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.lightBlue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMICategoryCard({
    required String initialCategory,
    required String finalCategory,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightGreen[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categoría IMC',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.lightGreen[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Inicial: $initialCategory',
            style: TextStyle(
              fontSize: 16,
              color: Colors.lightGreen[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Final: $finalCategory',
            style: TextStyle(
              fontSize: 16,
              color: Colors.lightGreen[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String result,
    required Color resultColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            result,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
        ],
      ),
    );
  }
}
