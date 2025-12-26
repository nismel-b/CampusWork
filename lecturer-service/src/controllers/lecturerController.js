const lecturerService = require('../services/lecturerService');
const logger = require('../../../shared/utils/logger');
const { successResponse } = require('../../../shared/utils/responseFormatter');
exports.createProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const profileData = req.body;

    const profile = await lecturerService.createProfile(userId, profileData);

    res.status(201).json(
      successResponse(
        'Lecturer profile created successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.getOwnProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const profile = await lecturerService.getProfileByUserId(userId);

    res.status(200).json(
      successResponse(
        'Profile retrieved successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.getOwnFullProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const fullProfile = await lecturerService.getFullProfile(userId);

    res.status(200).json(
      successResponse(
        'Full profile retrieved successfully',
        { profile: fullProfile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.updateOwnProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const updateData = req.body;

    const profile = await lecturerService.updateProfile(userId, updateData);

    res.status(200).json(
      successResponse(
        'Profile updated successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.addResearchInterest = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { interest } = req.body;

    const profile = await lecturerService.addResearchInterest(userId, interest);

    res.status(200).json(
      successResponse(
        'Research interest added successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.removeResearchInterest = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { interest } = req.params;

    const profile = await lecturerService.removeResearchInterest(userId, decodeURIComponent(interest));

    res.status(200).json(
      successResponse(
        'Research interest removed successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.addPublication = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const publication = req.body;

    const profile = await lecturerService.addPublication(userId, publication);

    res.status(200).json(
      successResponse(
        'Publication added successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.updateAcceptingStudents = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { accepting } = req.body;

    const profile = await lecturerService.updateAcceptingStudents(userId, accepting);

    res.status(200).json(
      successResponse(
        'Accepting students status updated successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.searchLecturers = async (req, res, next) => {
  try {
    const filters = {
      department: req.query.department,
      specialization: req.query.specialization,
      academicRank: req.query.academicRank,
      acceptingStudents: req.query.acceptingStudents === 'true',
      employmentStatus: req.query.employmentStatus,
      researchInterest: req.query.researchInterest
    };

    const pagination = {
      page: req.query.page || 1,
      limit: req.query.limit || 20
    };

    const result = await lecturerService.searchLecturers(filters, pagination);

    res.status(200).json(
      successResponse(
        'Lecturers retrieved successfully',
        result.profiles,
        result.pagination
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.getLecturerProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const profile = await lecturerService.getProfileByUserId(userId);

    res.status(200).json(
      successResponse(
        'Lecturer profile retrieved successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.getLecturerFullProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const fullProfile = await lecturerService.getFullProfile(userId);

    res.status(200).json(
      successResponse(
        'Full lecturer profile retrieved successfully',
        { profile: fullProfile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.updateLecturerProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const updateData = req.body;

    const profile = await lecturerService.updateProfile(userId, updateData);

    res.status(200).json(
      successResponse(
        'Lecturer profile updated successfully',
        { profile }
      )
    );
  } catch (error) {
    next(error);
  }
};
exports.deleteLecturerProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;

    await lecturerService.deleteProfile(userId);

    res.status(200).json(
      successResponse('Lecturer profile deleted successfully')
    );
  } catch (error) {
    next(error);
  }
};
exports.getStatistics = async (req, res, next) => {
  try {
    const statistics = await lecturerService.getStatistics();

    res.status(200).json(
      successResponse(
        'Statistics retrieved successfully',
        { statistics }
      )
    );
  } catch (error) {
    next(error);
  }
};
