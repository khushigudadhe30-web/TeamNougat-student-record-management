import 'package:flutter/material.dart';
import 'student_screen.dart';
import 'teacher_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Added the gradient background here!
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 247, 243, 244), // Almost pure white at top
            Color.fromARGB(255, 222, 222, 224), // Light grey/beige at bottom
          ],
        ),
      ),
      child: Scaffold(
        // Must be transparent so the gradient behind it shows through
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header Section
                Text(
                  'Welcome to Student\nRecord Management',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please select your role.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Cards Row
                SizedBox(
                  height: 300, // Taller to fit the image and button perfectly
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _RoleCard(
                          imagePath: 'assets/images/student.png',
                          badgeText: 'LEARNER',
                          badgeColor: const Color(0xFF5DE5A6), // Light green
                          badgeTextColor: const Color(
                            0xFF137A49,
                          ), // Dark green text
                          title: 'Student',
                          description: 'Grades & materials.',
                          buttonText: 'Enter \u2192', // Arrow character
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const StudentScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _RoleCard(
                          imagePath: 'assets/images/teacher.png',
                          badgeText: 'FACULTY',
                          badgeColor: const Color(0xFFF3D28E), // Yellow/Orange
                          badgeTextColor: const Color(0xFF8A5D19), // Brown text
                          title: 'Teacher',
                          description: 'Manage classes.',
                          buttonText: 'Enter \u229E', // Grid icon character
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TeacherDashboardScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String imagePath;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _RoleCard({
    required this.imagePath,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent, // Keeps it pure white
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      clipBehavior: Clip
          .antiAlias, // This ensures the image doesn't bleed out of the rounded corners
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.orange.withValues(alpha: 0.1),
        highlightColor: Colors.orange.withValues(alpha: 0.05),
        // Notice: NO padding here! So the image can touch the top and side edges.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 2. Top Image Area - Touching the edges
            // Expanded allows the image to take up whatever space is left over above the text
            Expanded(
              child: SizedBox(
                width: double.infinity,
                // BoxFit.cover ensures the downloaded image fills the width and height perfectly
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),

            // 3. Bottom Content Area (We put the padding only here now!)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                children: [
                  // Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
