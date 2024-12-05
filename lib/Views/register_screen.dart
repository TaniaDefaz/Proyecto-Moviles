import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso')),
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
        if (e.code == 'email-already-in-use') {
          message = 'El correo electrónico ya está en uso.';
        } else if (e.code == 'weak-password') {
          message = 'La contraseña es muy débil.';
        } else {
          message = 'Ocurrió un error al registrarse.';
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
                          Icons.account_circle,
                          size: 80,
                          color: Colors.indigo,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Crear una nueva cuenta',
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
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.indigo,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.lock_outline, color: Colors.indigo),
                            labelText: 'Confirmar Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.indigo,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme su contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            '¿Ya tienes cuenta? Iniciar sesión',
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
