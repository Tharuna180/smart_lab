import 'package:flutter/material.dart';
import 'dart:math';
import 'signup_page.dart';
import 'package:smart_lab_/screens/admin_login_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Same as SignUpPage background
      body: Stack(
        children: [
          ..._buildFloatingCircles(context),
          ..._buildSparkles(context),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAppBar(context),
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // STUDENT CARD - SignUpPage gradient colors
                    _buildRoleCard(
                      icon: Icons.school_rounded,
                      title: "Student",
                      subtitle: "Access labs, track attendance & raise issues",
                      gradientColors: const [
                        Color(0xFF4158D0), // Blue
                        Color(0xFFC850C0), // Pink
                      ],
                      onTap: () {
                        _navigateWithAnimation(context, const SignUpPage());
                      },
                    ),

                    const SizedBox(height: 20),

                    // ADMIN CARD - SignUpPage gradient colors
                    _buildRoleCard(
                      icon: Icons.shield_rounded,
                      title: "Administrator",
                      subtitle:
                          "Manage labs, oversee attendance & resolve issues",
                      gradientColors: const [
                        Color(0xFF4158D0), // Blue
                        Color(0xFFC850C0), // Pink
                      ],
                      onTap: () {
                        _navigateWithAnimation(context, const AdminLoginPage());
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Floating Circles Background - SignUpPage colors
  List<Widget> _buildFloatingCircles(BuildContext context) {
    return [
      Positioned(
        top: -50,
        right: -30,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 8),
          tween: Tween<double>(begin: 0, end: 2 * pi),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(-20 * sin(value), -10 * cos(value)),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4158D0).withOpacity(0.1), // Blue
                      const Color(0xFF4158D0).withOpacity(0.02),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: -30,
        left: -40,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 10),
          tween: Tween<double>(begin: 0, end: 2 * pi),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(15 * cos(value), -15 * sin(value)),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC850C0).withOpacity(0.08), // Pink
                      const Color(0xFFC850C0).withOpacity(0.01),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 20,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 12),
          tween: Tween<double>(begin: 0, end: 2 * pi),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(-25 * sin(value * 1.5), 20 * cos(value)),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4158D0).withOpacity(0.06), // Blue
                      const Color(0xFFC850C0).withOpacity(0.02), // Pink
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  // Sparkle Effects - SignUpPage colors
  List<Widget> _buildSparkles(BuildContext context) {
    return List.generate(8, (index) {
      return Positioned(
        top: (index * 70.0) % MediaQuery.of(context).size.height,
        left: (index * 50.0) % MediaQuery.of(context).size.width,
        child: TweenAnimationBuilder<double>(
          duration: Duration(seconds: 2 + index),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeInOut,
          builder: (context, double value, child) {
            return Opacity(
              opacity: (0.15 + 0.1 * sin(value * pi)).clamp(0.0, 0.3),
              child: Transform.scale(
                scale: 0.5 + 0.3 * sin(value * pi),
                child: Icon(
                  Icons.star_rounded,
                  color: const Color(0xFF4158D0).withOpacity(0.2), // Blue
                  size: 8 + index.toDouble(),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // Custom App Bar - SignUpPage style
  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF4158D0),
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4158D0),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "2 Roles",
                style: TextStyle(
                  color: Color(0xFF4158D0),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Header - SignUpPage style
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4158D0), Color(0xFFC850C0)], // Blue to Pink
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
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(height: 15),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
            ).createShader(bounds),
            child: const Text(
              "Choose Your Path",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Select your role to get started",
              style: TextStyle(color: Color(0xFF4158D0), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Role Card with pop effect - SignUpPage style
  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return _PopRoleCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      gradientColors: gradientColors,
      onTap: onTap,
    );
  }

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// POP CARD - SignUpPage style
class _PopRoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _PopRoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_PopRoleCard> createState() => _PopRoleCardState();
}

class _PopRoleCardState extends State<_PopRoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Icon with blue to pink gradient (like SignUpPage button)
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4158D0),
                          Color(0xFFC850C0),
                        ], // Blue to Pink
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4158D0).withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 15),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                          ).createShader(bounds),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon with blue to pink gradient (like SignUpPage button)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4158D0),
                          Color(0xFFC850C0),
                        ], // Blue to Pink
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4158D0).withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
