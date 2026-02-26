import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TempAdminSignupPage extends StatefulWidget {
  const TempAdminSignupPage({super.key});

  @override
  State<TempAdminSignupPage> createState() => _TempAdminSignupPageState();
}

class _TempAdminSignupPageState extends State<TempAdminSignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signUpAdmin() async {
    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ Admin account created. Verify email before login!",
          ),
        ),
      );

      Navigator.pop(context); // go back after signup
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Temporary Admin Sign Up"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Create Admin Account (One Time)",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Admin Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: signUpAdmin,
                      child: const Text("Create Admin Account"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
