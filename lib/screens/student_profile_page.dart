import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_home_page.dart';
import 'dart:math';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final deptController = TextEditingController();
  final classController = TextEditingController();
  final sectionController = TextEditingController();

  bool isEditing = false;
  bool loading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    fetchStudentDetails();
  }

  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    deptController.dispose();
    classController.dispose();
    sectionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ✅ SAME BACKEND LOGIC - UNCHANGED
  Future<void> fetchStudentDetails() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection("students").doc(uid).get();

    if (doc.exists) {
      nameController.text = doc["name"] ?? "";
      rollController.text = doc["rollNo"] ?? "";
      deptController.text = doc["department"] ?? "";
      classController.text = doc["class"] ?? "";
      sectionController.text = doc["section"] ?? "";
    }

    setState(() => loading = false);
  }

  // ✅ SAME BACKEND LOGIC - UNCHANGED
  Future<void> verifyPasswordAndEdit() async {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Identity"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = _auth.currentUser!;
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordController.text,
                );

                await user.reauthenticateWithCredential(cred);

                Navigator.pop(context);
                setState(() => isEditing = true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ Wrong password")),
                );
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  // ✅ SAME BACKEND LOGIC - UNCHANGED
  Future<void> saveChanges() async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("students").doc(uid).update({
      "name": nameController.text,
      "rollNo": rollController.text,
      "department": deptController.text,
      "class": classController.text,
      "section": sectionController.text,
    });

    setState(() => isEditing = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Profile updated")));
  }

  // ✅ ENHANCED FIELD WITH PREMIUM DESIGN
  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isEditing)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          if (isEditing)
            BoxShadow(
              color: const Color(0xFF4158D0).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isEditing ? const Color(0xFF4158D0) : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: isEditing ? FontWeight.w600 : FontWeight.normal,
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF4158D0),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: isEditing
                  ? const LinearGradient(
                      colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isEditing ? null : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEditing ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: isEditing ? Colors.white : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isEditing ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4158D0), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  // ✅ ENHANCED LOADING STATE
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0, end: 2 * pi),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4158D0).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "Loading Profile...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ✅ ENHANCED APP BAR WITH GRADIENT
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentHomePage()),
              );
            },
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFFFE55C)],
          ).createShader(bounds),
          child: const Text(
            "Student Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          if (!isEditing)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: verifyPasswordAndEdit,
              ),
            ),
          if (isEditing)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                onPressed: saveChanges,
              ),
            ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ✅ ENHANCED PROFILE HEADER WITH GRADIENT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4158D0).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile avatar with glow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            nameController.text.isNotEmpty
                                ? nameController.text[0].toUpperCase()
                                : "S",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Student name
                      Text(
                        nameController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Roll number chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "Roll No: ${rollController.text}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ EDIT MODE INDICATOR
                if (isEditing)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4158D0).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: const Color(0xFF4158D0),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "You are in edit mode. Make changes and save.",
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ✅ PROFILE FIELDS
                _field(
                  label: "Full Name",
                  controller: nameController,
                  icon: Icons.person_outline_rounded,
                ),

                _field(
                  label: "Roll Number",
                  controller: rollController,
                  icon: Icons.confirmation_number_rounded,
                ),

                _field(
                  label: "Department",
                  controller: deptController,
                  icon: Icons.school_rounded,
                ),

                _field(
                  label: "Class",
                  controller: classController,
                  icon: Icons.class_rounded,
                ),

                _field(
                  label: "Section",
                  controller: sectionController,
                  icon: Icons.group_rounded,
                ),

                const SizedBox(height: 20),

                // ✅ SAVE/CANCEL BUTTONS FOR EDIT MODE
                if (isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => isEditing = false);
                            fetchStudentDetails(); // Reset to original values
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4158D0).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
