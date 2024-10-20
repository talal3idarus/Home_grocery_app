import 'package:flutter/material.dart';
import 'package:home_grocery/Screens/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/Auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Auth auth = Auth();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loader = false;
  String? errorMessage = '';
  
  Future<void> login() async {
    errorMessage = '';
    setState(() {
      loader = true;
    });

    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navigate to HomePage on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorMessage = 'Wrong password provided for that user.';
        });
      } else {
        setState(() {
          errorMessage = 'Invalid credentials.';
        });
      }
    } catch (e) {
      // Handle other exceptions
      setState(() {
        errorMessage = 'Invalid credentials.';
      });
    }

    setState(() {
      loader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(fontSize: 40)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: loader ? null : login,
                child: loader
                    ? CircularProgressIndicator()
                    : Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
