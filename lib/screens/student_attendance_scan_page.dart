import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'student_home_page.dart';

class StudentAttendanceScanPage extends StatefulWidget {
  const StudentAttendanceScanPage({super.key});

  @override
  State<StudentAttendanceScanPage> createState() =>
      _StudentAttendanceScanPageState();
}

class _StudentAttendanceScanPageState extends State<StudentAttendanceScanPage> {
  bool scanned = false;
  bool _isProcessing = false;

  Future<void> _onQRScanned(String qrValue) async {
    if (_isProcessing || scanned) return;

    setState(() {
      _isProcessing = true;
      scanned = true;
    });

    try {
      final qrData = jsonDecode(qrValue);
      final String sessionId = qrData["sessionId"];

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage("❌ User not logged in", isError: true);
        setState(() {
          _isProcessing = false;
          scanned = false;
        });
        return;
      }

      final uid = user.uid;

      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4158D0)),
                ),
                SizedBox(height: 16),
                Text(
                  "Processing...",
                  style: TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
                ),
              ],
            ),
          ),
        ),
      );

      // 🔐 1️⃣ VALIDATE QR SESSION
      final sessionDoc = await FirebaseFirestore.instance
          .collection("qr_sessions")
          .doc(sessionId)
          .get();

      if (!mounted) {
        setState(() {
          _isProcessing = false;
          scanned = false;
        });
        return;
      }

      Navigator.pop(context); // Close loading dialog

      if (!sessionDoc.exists) {
        _showMessage("❌ Invalid QR Code", isError: true);
        setState(() {
          _isProcessing = false;
          scanned = false;
        });
        return;
      }

      final session = sessionDoc.data()!;

      final bool isActive = session["isActive"] ?? false;
      final DateTime expiresAt = (session["expiresAt"] as Timestamp).toDate();

      if (!isActive) {
        _showMessage("❌ Session has ended", isError: true);
        setState(() {
          _isProcessing = false;
          scanned = false;
        });
        return;
      }

      if (DateTime.now().isAfter(expiresAt)) {
        _showMessage("❌ QR Code Expired", isError: true);
        setState(() {
          _isProcessing = false;
          scanned = false;
        });
        return;
      }

      // 👤 2️⃣ GET STUDENT FROM STUDENTS COLLECTION
      final studentDoc = await FirebaseFirestore.instance
          .collection("students")
          .doc(uid)
          .get();

      if (!studentDoc.exists) {
        _showMessage("❌ Student profile not found", isError: true);
        setState(() {
          _isProcessing = false;
          scanned = false;
        });
        return;
      }

      final student = studentDoc.data()!;

      // 🚫 3️⃣ PREVENT DOUBLE SCAN
      final alreadyMarked = await FirebaseFirestore.instance
          .collection("attendance")
          .where("sessionId", isEqualTo: sessionId)
          .where("studentId", isEqualTo: uid)
          .get();

      if (alreadyMarked.docs.isNotEmpty) {
        _showMessage("⚠ Attendance already marked", isWarning: true);

        // Navigate to home after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomePage()),
              (route) => false,
            );
          }
        });
        return;
      }

      // ✅ 4️⃣ SAVE ATTENDANCE
      await FirebaseFirestore.instance.collection("attendance").add({
        "sessionId": sessionId,
        "labName": session["labName"],
        "assistant": session["assistant"],
        "incharge": session["incharge"],
        "subject": session["subject"],
        "period": session["period"],
        "date": session["date"],
        "studentId": uid,
        "studentName": student["name"],
        "rollNo": student["rollNo"],
        "email": student["email"],
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 60,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Success!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Attendance marked for ${session["subject"]}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentHomePage(),
                      ),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 40),
                  ),
                  child: const Text(
                    "Go to Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog if open
      Navigator.pop(context);

      _showMessage("❌ QR scan failed", isError: true);
      setState(() {
        _isProcessing = false;
        scanned = false;
      });
    }
  }

  void _showMessage(
    String msg, {
    bool isError = false,
    bool isWarning = false,
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = Colors.red;
      icon = Icons.error_outline_rounded;
    } else if (isWarning) {
      backgroundColor = Colors.orange;
      icon = Icons.warning_amber_rounded;
    } else {
      backgroundColor = Colors.green;
      icon = Icons.check_circle_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Scan Attendance QR",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4158D0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomePage()),
              (route) => false,
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Scanner Info Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4158D0).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ready to Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Position the QR code within the frame",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scanner
              Container(
                height: 350,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Scanner
                      MobileScanner(
                        onDetect: (capture) {
                          if (_isProcessing || scanned) return;
                          final code = capture.barcodes.first.rawValue;
                          if (code != null) {
                            _onQRScanned(code);
                          }
                        },
                      ),

                      // Scanner Overlay with static frame
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF4158D0),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.transparent,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_rounded,
                                color: Colors.white54,
                                size: 80,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Processing overlay
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Instructions Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4158D0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Color(0xFF4158D0),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Instructions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _InstructionItem(
                      icon: Icons.qr_code_rounded,
                      text: "Scan the QR code displayed in your lab",
                    ),
                    const SizedBox(height: 8),
                    const _InstructionItem(
                      icon: Icons.access_time_rounded,
                      text: "QR codes refresh every 5 seconds for security",
                    ),
                    const SizedBox(height: 8),
                    const _InstructionItem(
                      icon: Icons.check_circle_rounded,
                      text: "You'll be marked present for the current period",
                    ),
                  ],
                ),
              ),

              // Extra bottom padding to ensure no overflow
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4158D0)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
