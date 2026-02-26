import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAttendanceQRPage extends StatefulWidget {
  final String labName;
  final String assistant;
  final String incharge;
  final String subject;
  final String period;

  const AdminAttendanceQRPage({
    super.key,
    required this.labName,
    required this.assistant,
    required this.incharge,
    required this.subject,
    required this.period,
  });

  @override
  State<AdminAttendanceQRPage> createState() => _AdminAttendanceQRPageState();
}

class _AdminAttendanceQRPageState extends State<AdminAttendanceQRPage> {
  String? sessionId;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _generateNewQR();
  }

  Future<void> _generateNewQR() async {
    final now = DateTime.now();
    final expires = now.add(const Duration(seconds: 5));

    // 🔴 Deactivate previous active sessions of this lab
    final oldSessions = await FirebaseFirestore.instance
        .collection("qr_sessions")
        .where("labName", isEqualTo: widget.labName)
        .where("isActive", isEqualTo: true)
        .get();

    for (var doc in oldSessions.docs) {
      await doc.reference.update({"isActive": false});
    }

    // 🟢 Create new session
    final doc = await FirebaseFirestore.instance.collection("qr_sessions").add({
      "labName": widget.labName,
      "assistant": widget.assistant,
      "incharge": widget.incharge,
      "subject": widget.subject,
      "period": widget.period,
      "date": "${now.day}-${now.month}-${now.year}",
      "createdAt": Timestamp.fromDate(now),
      "expiresAt": Timestamp.fromDate(expires),
      "isActive": true,
    });

    if (!mounted) return;

    setState(() {
      sessionId = doc.id;
    });

    timer?.cancel();
    timer = Timer(const Duration(seconds: 5), () {
      _generateNewQR();
    });
  }

  @override
  void dispose() async {
    timer?.cancel();

    if (sessionId != null) {
      await FirebaseFirestore.instance
          .collection("qr_sessions")
          .doc(sessionId)
          .update({"isActive": false});
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sessionId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final qrData = jsonEncode({"sessionId": sessionId});

    return Scaffold(
      appBar: AppBar(title: const Text("Dynamic Attendance QR")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(data: qrData, size: 250),

            const SizedBox(height: 20),

            const Text(
              "QR refreshes every 5 seconds",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
