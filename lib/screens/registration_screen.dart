import 'package:flutter/material.dart';
import 'package:toibook_app/screens/login_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  void _handleRegister() async {
    setState(() => _isLoading = true);

    final success = await AuthService().register(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
      _passwordController.text,
      _cityController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login.")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              // phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "+7 707...",
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter phone number";
                  }

                  final phoneRegExp = RegExp(r'^(\+?7|8)[0-9]{10}$');

                  //remove any spaces or dashes
                  String cleanValue = value.replaceAll(
                    RegExp(r'[\s\-\(\)]'),
                    '',
                  );

                  if (!phoneRegExp.hasMatch(cleanValue)) {
                    return "Use format: +7... or 8...";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),

              const SizedBox(height: 16),

              // email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final emailRegExp = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (value == null || value.isEmpty) return "Enter email";
                  if (!emailRegExp.hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  if (!value.contains(RegExp(r'[A-Za-z]')) ||
                      !value.contains(RegExp(r'[0-9]'))) {
                    return "Must contain at least one letter and one number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // check validators
                    if (_formKey.currentState!.validate()) {
                      _handleRegister();
                    }
                  },
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Register"),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
