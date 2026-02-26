import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: Colors.blue),
            const SizedBox(height: 20),

            const Text(
              "A verification email has been sent.\n"
              "Please check your Inbox or Spam folder.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // 🔁 RESEND BUTTON (THIS IS THE CODE YOU ASKED ABOUT)
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser
                    ?.sendEmailVerification();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Verification email resent")),
                );
              },
              child: const Text("Resend verification email"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.reload();
                final user = FirebaseAuth.instance.currentUser;

                if (user != null && user.emailVerified) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email not verified yet")),
                  );
                }
              },
              child: const Text("I have verified"),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
