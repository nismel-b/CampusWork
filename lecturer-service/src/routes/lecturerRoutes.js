/**
 * LECTURER ROUTES
 * Définit toutes les routes pour le Lecturer Service.
 */

const express = require('express');
const router = express.Router();

const lecturerController = require('../controllers/lecturerController');
const {
  verifyToken,
  requireLecturer,
  requireAdmin
} = require('../middleware/authMiddleware');
const {
  validateCreateProfile,
  validateUpdateProfile,
  validateAddResearchInterest,
  validateAddPublication,
  validateUpdateAcceptingStudents,
  validateSearch,
  validateUserId
} = require('../middleware/validationMiddleware');

/**
 * ======================
 * PUBLIC ROUTES
 * ======================
 */

/**
 * SEARCH LECTURERS
 * GET /api/lecturers/search
 * 
 * Recherche publique d'enseignants avec filtres.
 * 
 * Query params:
 *   - department: string
 *   - specialization: string
 *   - academicRank: string
 *   - acceptingStudents: boolean
 *   - employmentStatus: string
 *   - page: number (default: 1)
 *   - limit: number (default: 20)
 */
router.get(
  '/search',
  validateSearch,
  lecturerController.searchLecturers
);

/**
 * GET LECTURER PROFILE
 * GET /api/lecturers/profile/:userId
 * 
 * Récupère le profil public d'un enseignant.
 */
router.get(
  '/profile/:userId',
  validateUserId,
  lecturerController.getLecturerProfile
);

/**
 * GET LECTURER FULL PROFILE
 * GET /api/lecturers/profile/:userId/full
 * 
 * Récupère le profil complet avec infos utilisateur.
 */
router.get(
  '/profile/:userId/full',
  validateUserId,
  lecturerController.getLecturerFullProfile
);

/**
 * ======================
 * PROTECTED ROUTES (LECTURER)
 * ======================
 */

/**
 * CREATE PROFILE
 * POST /api/lecturers/profile
 * 
 * Crée un nouveau profil d'enseignant.
 */
router.post(
  '/profile',
  verifyToken,
  requireLecturer,
  validateCreateProfile,
  lecturerController.createProfile
);

/**
 * GET OWN PROFILE
 * GET /api/lecturers/profile/me
 * 
 * Récupère son propre profil.
 */
router.get(
  '/profile/me',
  verifyToken,
  requireLecturer,
  lecturerController.getOwnProfile
);

/**
 * GET OWN FULL PROFILE
 * GET /api/lecturers/profile/me/full
 * 
 * Récupère son profil complet avec infos utilisateur.
 */
router.get(
  '/profile/me/full',
  verifyToken,
  requireLecturer,
  lecturerController.getOwnFullProfile
);

/**
 * UPDATE OWN PROFILE
 * PUT /api/lecturers/profile/me
 * 
 * Met à jour son propre profil.
 */
router.put(
  '/profile/me',
  verifyToken,
  requireLecturer,
  validateUpdateProfile,
  lecturerController.updateOwnProfile
);

/**
 * ======================
 * RESEARCH INTERESTS
 * ======================
 */

/**
 * ADD RESEARCH INTEREST
 * POST /api/lecturers/profile/me/research-interests
 * 
 * Ajoute un intérêt de recherche.
 */
router.post(
  '/profile/me/research-interests',
  verifyToken,
  requireLecturer,
  validateAddResearchInterest,
  lecturerController.addResearchInterest
);

/**
 * REMOVE RESEARCH INTEREST
 * DELETE /api/lecturers/profile/me/research-interests/:interest
 * 
 * Supprime un intérêt de recherche.
 */
router.delete(
  '/profile/me/research-interests/:interest',
  verifyToken,
  requireLecturer,
  lecturerController.removeResearchInterest
);

/**
 * ======================
 * PUBLICATIONS
 * ======================
 */

/**
 * ADD PUBLICATION
 * POST /api/lecturers/profile/me/publications
 * 
 * Ajoute une publication académique.
 */
router.post(
  '/profile/me/publications',
  verifyToken,
  requireLecturer,
  validateAddPublication,
  lecturerController.addPublication
);

/**
 * ======================
 * ACCEPTING STUDENTS
 * ======================
 */

/**
 * UPDATE ACCEPTING STUDENTS STATUS
 * PATCH /api/lecturers/profile/me/accepting-students
 * 
 * Met à jour le statut d'acceptation de nouveaux étudiants.
 */
router.patch(
  '/profile/me/accepting-students',
  verifyToken,
  requireLecturer,
  validateUpdateAcceptingStudents,
  lecturerController.updateAcceptingStudents
);

/**
 * ======================
 * ADMIN ROUTES
 * ======================
 */

/**
 * UPDATE ANY LECTURER PROFILE
 * PUT /api/lecturers/profile/:userId
 * 
 * Admin peut modifier n'importe quel profil.
 */
router.put(
  '/profile/:userId',
  verifyToken,
  requireAdmin,
  validateUserId,
  validateUpdateProfile,
  lecturerController.updateLecturerProfile
);

/**
 * DELETE LECTURER PROFILE
 * DELETE /api/lecturers/profile/:userId
 * 
 * Admin peut supprimer un profil.
 */
router.delete(
  '/profile/:userId',
  verifyToken,
  requireAdmin,
  validateUserId,
  lecturerController.deleteLecturerProfile
);

/**
 * GET STATISTICS
 * GET /api/lecturers/statistics
 * 
 * Admin peut voir les statistiques globales.
 */
router.get(
  '/statistics',
  verifyToken,
  requireAdmin,
  lecturerController.getStatistics
);

module.exports = router;
