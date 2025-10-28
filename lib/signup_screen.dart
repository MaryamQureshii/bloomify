import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  final _usernameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmpassC = TextEditingController();
  String _errorMessage = '';

  void _signUp() async {
    setState(() { _errorMessage = ''; });

    final email = _emailC.text.trim();
    final password = _passC.text.trim();
    final confirmPassword = _confirmpassC.text.trim();
    final username = _usernameC.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty){
       setState(() {
      _errorMessage = 'Please fill in all fields.';
       }
       );
       return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState((){
        _errorMessage = 'Please enter a valid email address.';
        }
        );
      return;
    }
    if (password.length < 8) {
      setState(() {
      _errorMessage = 'Password must be at least 8 characters long.';
      }
      );
      return;
    }
    if (password != confirmPassword) {
      setState(() {
      _errorMessage = "Oops! Those passwords don't match.";
      }
      );
      return;
    }
    final usersBox = Hive.box('users'); 

    //checking if user exists
    if (usersBox.containsKey(email)) {
      setState(() {
      _errorMessage = 'That email is already registered. Try logging in!'; });
      return;
    }
    await usersBox.put(email, {'username': username, 'password': password});


    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainShell()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmpassC.dispose();
    super.dispose();
  }

  // Building UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 60),
              const SizedBox(height: 10),
              const Text('Bloomify',
              style: TextStyle(
              fontSize: 28,
              fontWeight:
              FontWeight.bold)
              ),

              const SizedBox(height: 10),
              const Text('Create an account', 
              style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87)
              ),
              const SizedBox(height: 5),
              const Text('Start your plant journey!',
              style: TextStyle(
              color: Colors.grey)
              ),
              const SizedBox(height: 30),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: _buildTextField(_usernameC,'Username', Icons.person_outline),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: _buildTextField(_emailC, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              ),
              Container(
                 margin: const EdgeInsets.symmetric(vertical: 10),
                child: _buildTextField(_passC, 'Password', Icons.lock_outline, isPassword: true),
              ),
              Container(
                 margin: const EdgeInsets.symmetric(vertical: 10),
                child: _buildTextField(_confirmpassC, 'Confirm Password', Icons.lock_outline, isPassword: true),
              ),
              const SizedBox(height: 10),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    const TextSpan(text: "Already have an account? "),
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
    );
  }
}

