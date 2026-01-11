import 'package:campuswork/services/project_service.dart';
import 'package:campuswork/model/project.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import 'dart:math';

class SimilarityService {
  static final SimilarityService _instance = SimilarityService._internal();
  factory SimilarityService() => _instance;
  SimilarityService._internal();

  // Seuils de similarité
  static const double _highSimilarityThreshold = 0.7;
  static const double _mediumSimilarityThreshold = 0.5;
  static const double _lowSimilarityThreshold = 0.3;

  /// Vérifie la similarité d'un projet avec les projets existants
  Future<List<SimilarProject>> checkProjectSimilarity({
    required String projectName,
    required String description,
    String? courseName,
    List<String> resources = const [],
    List<String> tags = const [],
    String? existingProjectId, // Pour exclure le projet en cours de modification
  }) async {
    try {
      // Récupérer tous les projets existants
      final existingProjects = ProjectService().getAllProjects();
      
      // Exclure le projet en cours de modification s'il existe
      final projectsToCheck = existingProjects
          .where((p) => p.projectId != existingProjectId)
          .toList();

      List<SimilarProject> similarProjects = [];

      for (final project in projectsToCheck) {
        final similarity = _calculateProjectSimilarity(
          projectName: projectName,
          description: description,
          courseName: courseName,
          resources: resources,
          tags: tags,
          existingProject: project,
        );

        if (similarity.score >= _lowSimilarityThreshold) {
          similarProjects.add(similarity);
        }
      }

      // Trier par score de similarité décroissant
      similarProjects.sort((a, b) => b.score.compareTo(a.score));

      return similarProjects.take(10).toList(); // Retourner les 10 plus similaires
    } catch (e) {
      debugPrint('Error checking project similarity: $e');
      return [];
    }
  }

  /// Calcule la similarité entre un nouveau projet et un projet existant
  SimilarProject _calculateProjectSimilarity({
    required String projectName,
    required String description,
    String? courseName,
    List<String> resources = const [],
    List<String> tags = const [],
    required Project existingProject,
  }) {
    List<String> reasons = [];
    List<double> scores = [];

    // 1. Similarité du nom du projet (poids: 30%)
    final nameSimilarity = projectName.similarityTo(existingProject.projectName);
    scores.add(nameSimilarity * 0.3);
    if (nameSimilarity > 0.6) {
      reasons.add('Nom très similaire (${(nameSimilarity * 100).toInt()}%)');
    }

    // 2. Similarité de la description (poids: 40%)
    final descriptionSimilarity = description.similarityTo(existingProject.description);
    scores.add(descriptionSimilarity * 0.4);
    if (descriptionSimilarity > 0.5) {
      reasons.add('Description similaire (${(descriptionSimilarity * 100).toInt()}%)');
    }

    // 3. Même cours (poids: 15%)
    double courseSimilarity = 0.0;
    if (courseName != null && courseName.isNotEmpty && existingProject.courseName.isNotEmpty) {
      courseSimilarity = courseName.similarityTo(existingProject.courseName);
      if (courseSimilarity > 0.8) {
        scores.add(courseSimilarity * 0.15);
        reasons.add('Même cours ou cours similaire');
      }
    }

    // 4. Technologies/Ressources communes (poids: 10%)
    final resourcesSimilarity = _calculateListSimilarity(resources, existingProject.resources);
    scores.add(resourcesSimilarity * 0.1);
    if (resourcesSimilarity > 0.4) {
      final commonResources = _getCommonElements(resources, existingProject.resources);
      if (commonResources.isNotEmpty) {
        reasons.add('Technologies communes: ${commonResources.take(3).join(', ')}');
      }
    }

    // 5. Tags/Catégories similaires (poids: 5%)
    final tagsSimilarity = _calculateCategorySimilarity(tags, existingProject);
    scores.add(tagsSimilarity * 0.05);
    if (tagsSimilarity > 0.5) {
      reasons.add('Catégorie ou domaine similaire');
    }

    // Score final
    final finalScore = scores.fold(0.0, (sum, score) => sum + score);

    // Ajouter des raisons supplémentaires basées sur le score final
    if (finalScore >= _highSimilarityThreshold) {
      reasons.insert(0, '⚠️ ATTENTION: Projet potentiellement identique');
    } else if (finalScore >= _mediumSimilarityThreshold) {
      reasons.insert(0, '⚡ Approche très similaire détectée');
    }

    return SimilarProject(
      project: existingProject,
      score: finalScore,
      reasons: reasons,
    );
  }

  /// Calcule la similarité entre deux listes de strings
  double _calculateListSimilarity(List<String> list1, List<String> list2) {
    if (list1.isEmpty && list2.isEmpty) return 0.0;
    if (list1.isEmpty || list2.isEmpty) return 0.0;

    final commonElements = _getCommonElements(list1, list2);
    final totalElements = (list1.length + list2.length) / 2;
    
    return commonElements.length / totalElements;
  }

  /// Trouve les éléments communs entre deux listes (avec similarité de string)
  List<String> _getCommonElements(List<String> list1, List<String> list2) {
    List<String> common = [];
    
    for (final item1 in list1) {
      for (final item2 in list2) {
        if (item1.toLowerCase().similarityTo(item2.toLowerCase()) > 0.7) {
          if (!common.contains(item1)) {
            common.add(item1);
          }
        }
      }
    }
    
    return common;
  }

  /// Calcule la similarité de catégorie/domaine
  double _calculateCategorySimilarity(List<String> tags, Project existingProject) {
    double similarity = 0.0;
    
    // Comparer avec la catégorie du projet existant
    if (existingProject.category != null && existingProject.category!.isNotEmpty) {
      for (final tag in tags) {
        final tagSimilarity = tag.toLowerCase().similarityTo(existingProject.category!.toLowerCase());
        similarity = max(similarity, tagSimilarity);
      }
    }
    
    // Comparer les domaines techniques
    final existingTags = existingProject.resources;
    similarity = max(similarity, _calculateListSimilarity(tags, existingTags));
    
    return similarity;
  }

  /// Analyse le code source pour détecter le plagiat
  double checkCodeSimilarity(String code1, String code2) {
    if (code1.isEmpty || code2.isEmpty) return 0.0;
    
    // Nettoyer le code (supprimer les espaces, commentaires basiques)
    final cleanCode1 = _cleanCode(code1);
    final cleanCode2 = _cleanCode(code2);
    
    return cleanCode1.similarityTo(cleanCode2);
  }

  /// Nettoie le code pour une meilleure comparaison
  String _cleanCode(String code) {
    return code
        .replaceAll(RegExp(r'//.*'), '') // Supprimer les commentaires //
        .replaceAll(RegExp(r'/\*.*?\*/'), '') // Supprimer les commentaires /* */
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliser les espaces
        .toLowerCase()
        .trim();
  }

  /// Analyse détaillée de plagiat pour le code source
  Map<String, dynamic> analyzeCodePlagiarism(String sourceCode, List<Project> existingProjects) {
    List<Map<String, dynamic>> suspiciousMatches = [];
    double maxSimilarity = 0.0;
    
    for (final project in existingProjects) {
      // Ici, on pourrait analyser les fichiers de code du projet
      // Pour l'instant, on simule avec la description
      final similarity = checkCodeSimilarity(sourceCode, project.description);
      
      if (similarity > 0.4) { // Seuil pour code suspect
        suspiciousMatches.add({
          'project': project,
          'similarity': similarity,
          'type': similarity > 0.8 ? 'plagiat_probable' : 'similarite_suspecte',
        });
        
        maxSimilarity = max(maxSimilarity, similarity);
      }
    }
    
    return {
      'max_similarity': maxSimilarity,
      'is_suspicious': maxSimilarity > 0.6,
      'is_plagiarism': maxSimilarity > 0.8,
      'matches': suspiciousMatches,
      'recommendation': _getRecommendation(maxSimilarity),
    };
  }

  String _getRecommendation(double similarity) {
    if (similarity > 0.8) {
      return '🚨 ATTENTION: Plagiat probable détecté. Révision nécessaire.';
    } else if (similarity > 0.6) {
      return '⚠️ Similarité suspecte. Vérifiez l\'originalité de votre code.';
    } else if (similarity > 0.4) {
      return '💡 Quelques similarités détectées. Assurez-vous de citer vos sources.';
    } else {
      return '✅ Code semble original.';
    }
  }

  /// Génère des suggestions pour améliorer l'originalité
  List<String> suggestImprovements(List<SimilarProject> similarProjects) {
    List<String> suggestions = [];
    
    if (similarProjects.isEmpty) {
      return ['🎉 Votre projet semble unique ! Continuez sur cette voie.'];
    }

    final highSimilarity = similarProjects.where((p) => p.score >= _highSimilarityThreshold).toList();
    final mediumSimilarity = similarProjects.where((p) => p.score >= _mediumSimilarityThreshold && p.score < _highSimilarityThreshold).toList();

    if (highSimilarity.isNotEmpty) {
      suggestions.addAll([
        '🔄 Changez significativement votre approche ou votre angle d\'attaque',
        '💻 Utilisez des technologies différentes ou plus récentes',
        '✨ Ajoutez des fonctionnalités innovantes qui vous différencient',
        '🎯 Modifiez le domaine d\'application ou le public cible',
        '🏗️ Repensez l\'architecture de votre solution',
      ]);
    } else if (mediumSimilarity.isNotEmpty) {
      suggestions.addAll([
        '⭐ Ajoutez des fonctionnalités uniques à votre projet',
        '🔍 Explorez des aspects non couverts par les projets similaires',
        '🛠️ Utilisez une approche technique différente',
        '🎪 Ciblez un cas d\'usage plus spécifique',
        '📊 Intégrez des métriques ou analyses avancées',
      ]);
    }

    // Suggestions basées sur les raisons de similarité
    final allReasons = similarProjects.expand((p) => p.reasons).toList();
    
    if (allReasons.any((r) => r.contains('Nom très similaire'))) {
      suggestions.add('📝 Choisissez un nom plus distinctif pour votre projet');
    }
    
    if (allReasons.any((r) => r.contains('Description similaire'))) {
      suggestions.add('📖 Réécrivez votre description en mettant l\'accent sur vos innovations');
    }
    
    if (allReasons.any((r) => r.contains('Technologies communes'))) {
      suggestions.add('🚀 Intégrez des technologies émergentes ou moins communes');
    }

    // Suggestions générales
    suggestions.addAll([
      '📚 Documentez clairement vos contributions originales',
      '⚖️ Ajoutez une analyse comparative avec les solutions existantes',
      '📈 Implémentez des métriques ou des KPIs spécifiques à votre approche',
      '🎨 Créez une interface utilisateur unique et innovante',
      '🔐 Ajoutez des aspects de sécurité ou de performance avancés',
    ]);

    return suggestions.take(6).toList(); // Limiter à 6 suggestions
  }

  /// Fonction utilitaire pour tester la similarité (pour debug)
  void testSimilarity(String text1, String text2) {
    final similarity = text1.similarityTo(text2);
    debugPrint('Similarité entre "$text1" et "$text2": ${(similarity * 100).toStringAsFixed(2)}%');
  }
}

class SimilarProject {
  final Project project;
  final double score;
  final List<String> reasons;

  SimilarProject({
    required this.project,
    required this.score,
    required this.reasons,
  });

  String get scorePercentage => '${(score * 100).toInt()}%';
  
  String get similarityLevel {
    if (score >= 0.7) return 'Très similaire';
    if (score >= 0.5) return 'Similaire';
    if (score >= 0.3) return 'Partiellement similaire';
    return 'Peu similaire';
  }
  
  Color get severityColor {
    if (score >= 0.7) return const Color(0xFFD32F2F); // Rouge
    if (score >= 0.5) return const Color(0xFFFF9800); // Orange
    if (score >= 0.3) return const Color(0xFFFFC107); // Jaune
    return const Color(0xFF4CAF50); // Vert
  }
}