import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

/// Écran d'onboarding pour expliquer l'application aux nouveaux utilisateurs
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue sur CampusWork',
      description: 'Votre plateforme dédiée à la mise en avant de tous vos projets universitaires',
      image: "welcome",
      icon: Icons.school,
      color: const Color(0xFF4A90E2),
    ),
    OnboardingPage(
      title: 'Ajoutez vos projets',
      description: "Parcourez des milliers de projets en quelques clics et trouvez de l'inspiration pour vos futurs projets",
      image: "projects",
      icon: Icons.folder_open,
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      title: 'Étudiants',
      description: 'Gardez une trace de votre parcours universitaire et enrichissez votre portfolio avec vos différents projets académiques',
      image: "students",
      icon: Icons.groups,
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingPage(
      title: 'Enseignants',
      description: "Notez plus facilement les projets de vos étudiants et suivez leur progression",
      image: "teachers",
      icon: Icons.person_outline,
      color: const Color(0xFFF59E0B),
    ),
    OnboardingPage(
      title: 'Collaboration',
      description: "Collaborez avec d'autres étudiants, partagez vos idées et créez ensemble des projets innovants",
      image: "collaboration",
      icon: Icons.handshake,
      color: const Color(0xFFEF4444),
    ),
    OnboardingPage(
      title: 'Commencez maintenant',
      description: 'Connectez-vous pour commencer votre expérience sur CampusWork',
      image: "start",
      icon: Icons.rocket_launch,
      color: const Color(0xFF06B6D4),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                  ),
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
            ),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Beautiful illustration widget
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.color.withOpacity(0.1),
                  page.color.withOpacity(0.05),
                ],
              ),
            ),
            child: _buildIllustration(page),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D29),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(OnboardingPage page) {
    switch (page.image) {
      case "welcome":
        return _buildWelcomeIllustration(page.color);
      case "projects":
        return _buildProjectsIllustration(page.color);
      case "students":
        return _buildStudentsIllustration(page.color);
      case "teachers":
        return _buildTeachersIllustration(page.color);
      case "collaboration":
        return _buildCollaborationIllustration(page.color);
      case "start":
        return _buildStartIllustration(page.color);
      default:
        return _buildDefaultIllustration(page.color, page.icon);
    }
  }

  Widget _buildWelcomeIllustration(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circles
        Positioned(
          top: 50,
          left: 50,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          right: 40,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Main icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 60,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsIllustration(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Folder icons
        Positioned(
          top: 80,
          left: 60,
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder, color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          top: 100,
          right: 80,
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder, color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 80,
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder, color: Colors.white, size: 30),
          ),
        ),
        // Main folder
        Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.folder_open, color: Colors.white, size: 50),
        ),
      ],
    );
  }

  Widget _buildStudentsIllustration(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Student avatars
        Positioned(
          top: 60,
          left: 40,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.7),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          top: 60,
          right: 40,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.5),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 60,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.6),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          bottom: 60,
          right: 60,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.4),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
        // Main group icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.groups, color: Colors.white, size: 50),
        ),
      ],
    );
  }

  Widget _buildTeachersIllustration(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blackboard
        Positioned(
          top: 40,
          child: Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.brown, width: 8),
            ),
            child: Center(
              child: Text(
                'A + B = C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Teacher
        Positioned(
          bottom: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildCollaborationIllustration(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Connection lines
        CustomPaint(
          size: const Size(200, 200),
          painter: ConnectionLinesPainter(color),
        ),
        // Collaboration nodes
        Positioned(
          top: 80,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white, size: 25),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 60,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white, size: 25),
          ),
        ),
        Positioned(
          bottom: 80,
          right: 60,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white, size: 25),
          ),
        ),
        // Central handshake
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.handshake, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  Widget _buildStartIllustration(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Stars
        Positioned(
          top: 60,
          left: 80,
          child: Icon(Icons.star, color: color.withOpacity(0.6), size: 30),
        ),
        Positioned(
          top: 100,
          right: 60,
          child: Icon(Icons.star, color: color.withOpacity(0.4), size: 25),
        ),
        Positioned(
          bottom: 100,
          left: 60,
          child: Icon(Icons.star, color: color.withOpacity(0.5), size: 28),
        ),
        // Rocket
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.rocket_launch, color: Colors.white, size: 50),
        ),
      ],
    );
  }

  Widget _buildDefaultIllustration(Color color, IconData icon) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 60),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
  });
}

class ConnectionLinesPainter extends CustomPainter {
  final Color color;

  ConnectionLinesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final topPoint = Offset(size.width / 2, size.height * 0.3);
    final bottomLeft = Offset(size.width * 0.3, size.height * 0.7);
    final bottomRight = Offset(size.width * 0.7, size.height * 0.7);

    // Draw connection lines
    canvas.drawLine(center, topPoint, paint);
    canvas.drawLine(center, bottomLeft, paint);
    canvas.drawLine(center, bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

