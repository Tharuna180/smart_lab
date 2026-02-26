import 'package:flutter/material.dart';

class IssuesListPage extends StatelessWidget {
  const IssuesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reported Issues"), centerTitle: true),
      body: const Center(
        child: Text("Issues List Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
