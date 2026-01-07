import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BienvenueScreen extends StatelessWidget {
  const BienvenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 60.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Campus Work
              Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.lightBlueAccent,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        '',
                        width: 500,
                        height: 500,

                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "CAMPUS WORK",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 2,
                      fontFamily: 'Wizzard',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // Texte de bienvenue
              const Text(
                "Bienvenue sur Campus Work\n votre bibliothèque de projet universitaire",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightBlueAccent,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 80),

              // Bouton principal
              ElevatedButton(
                onPressed: () async {
                  // Check if onboarding is completed
                  final prefs = await SharedPreferences.getInstance();
                  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

                  if (!onboardingCompleted) {
                    if(context.mounted){
                      Navigator.pushNamed(context, '/onboarding');
                    }
                  } else {
                    if (context.mounted){
                      Navigator.pushNamed(context, '/connect');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blueAccent,
                ),
                child: const Text(
                  "Se connecter",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton secondaire
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/connect');
                },
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // Indicateurs de page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      //  ),
      // ),
      // ),
    );
  }
}