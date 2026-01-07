import 'package:flutter/material.dart';
import 'navigation/app_route.dart';
import 'theme/theme.dart';
import 'auth/auth_service.dart';
import 'services/project-services.dart';
import 'services/comment-service.dart';
import 'services/like-services.dart';
import 'services/notification-services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusWorkApp());
}

class CampusWorkApp extends StatefulWidget {
  const CampusWorkApp({super.key});

  @override
  State<CampusWorkApp> createState() => _MyAppState();
}

class _MyAppState extends State<CampusWorkApp> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await AuthService().init();
      await ProjectService().init();
      await CommentService().init();
      await LikeService().init();
      await NotificationService().init();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Chargement...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur d\'initialisation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isInitialized = false;
                        _errorMessage = null;
                      });
                      _initializeServices();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Projet Académique',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
