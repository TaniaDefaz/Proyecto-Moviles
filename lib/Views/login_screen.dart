import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _authenticate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inicio de sesión exitoso')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              selectedIndex: 1,
              isAuthenticated: true,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No existe un usuario con ese correo.';
        } else if (e.code == 'wrong-password') {
          message = 'Contraseña incorrecta.';
        } else {
          message = 'Error al iniciar sesión.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.lock_open,
                          size: 80,
                          color: Colors.indigo,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.indigo),
                            labelText: 'Correo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su correo';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Por favor, ingrese un correo válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.indigo,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: Text(
                            '¿No tienes cuenta? Registrarse',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
