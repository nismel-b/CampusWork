import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  // Navigation
  @override
  String get home => 'Home';
  @override
  String get dashboard => 'Dashboard';
  @override
  String get projects => 'Projects';
  @override
  String get groups => 'Groups';
  @override
  String get profile => 'Profile';
  @override
  String get settings => 'Settings';
  @override
  String get notifications => 'Notifications';

  // Authentication
  @override
  String get login => 'Login';
  @override
  String get register => 'Register';
  @override
  String get logout => 'Logout';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get firstName => 'First Name';
  @override
  String get lastName => 'Last Name';
  @override
  String get username => 'Username';
  @override
  String get phoneNumber => 'Phone Number';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get createAccount => 'Create Account';
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  // Common actions
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Add';
  @override
  String get remove => 'Remove';
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
  @override
  String get refresh => 'Refresh';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get warning => 'Warning';
  @override
  String get info => 'Information';

  // Projects
  @override
  String get createProject => 'Create Project';
  @override
  String get projectName => 'Project Name';
  @override
  String get projectDescription => 'Project Description';
  @override
  String get courseName => 'Course Name';
  @override
  String get category => 'Category';
  @override
  String get resources => 'Resources';
  @override
  String get prerequisites => 'Prerequisites';
  @override
  String get collaborators => 'Collaborators';
  @override
  String get status => 'Status';
  @override
  String get grade => 'Grade';
  @override
  String get comments => 'Comments';
  @override
  String get likes => 'Likes';
  @override
  String get myProjects => 'My Projects';
  @override
  String get allProjects => 'All Projects';
  @override
  String get projectDetails => 'Project Details';
  @override
  String get addToGroup => 'Add to Group';
  @override
  String get removeFromGroup => 'Remove from Group';

  // Groups
  @override
  String get createGroup => 'Create Group';
  @override
  String get groupName => 'Group Name';
  @override
  String get groupDescription => 'Group Description';
  @override
  String get groupType => 'Group Type';
  @override
  String get members => 'Members';
  @override
  String get maxMembers => 'Max Members';
  @override
  String get joinGroup => 'Join Group';
  @override
  String get leaveGroup => 'Leave Group';
  @override
  String get groupProject => 'Project Group';
  @override
  String get groupStudy => 'Study Group';
  @override
  String get groupCollaboration => 'Collaboration Group';
  @override
  String get openGroup => 'Open Group';
  @override
  String get closedGroup => 'Closed Group';
  @override
  String get evaluationCriteria => 'Evaluation Criteria';

  // Comments
  @override
  String get addComment => 'Add Comment';
  @override
  String get reply => 'Reply';
  @override
  String get writeComment => 'Write your comment...';
  @override
  String get writeReply => 'Write your reply...';
  @override
  String get noComments => 'No comments';
  @override
  String get commentAdded => 'Comment added';
  @override
  String get replyAdded => 'Reply added';

  // Stories & Surveys
  @override
  String get createStory => 'Create Story';
  @override
  String get createSurvey => 'Create Survey';
  @override
  String get storyTitle => 'Story Title';
  @override
  String get surveyQuestion => 'Survey Question';
  @override
  String get options => 'Options';
  @override
  String get vote => 'Vote';
  @override
  String get results => 'Results';
  @override
  String get expires => 'Expires';

  // Settings
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get lightMode => 'Light Mode';
  @override
  String get systemMode => 'System Mode';
  @override
  String get accountSettings => 'Account Settings';
  @override
  String get privacySettings => 'Privacy Settings';
  @override
  String get deleteAccount => 'Delete Account';

  // Messages
  @override
  String get welcomeMessage => 'Welcome to CampusWork!';
  @override
  String get noProjectsFound => 'No projects found';
  @override
  String get noGroupsFound => 'No groups found';
  @override
  String get noCommentsFound => 'No comments found';
  @override
  String get projectCreatedSuccessfully => 'Project created successfully';
  @override
  String get groupCreatedSuccessfully => 'Group created successfully';
  @override
  String get commentAddedSuccessfully => 'Comment added successfully';
  @override
  String get errorOccurred => 'An error occurred';
  @override
  String get confirmDelete => 'Confirm deletion';
  @override
  String get itemDeleted => 'Item deleted';

  // Validation
  @override
  String get fieldRequired => 'This field is required';
  @override
  String get emailInvalid => 'Invalid email';
  @override
  String get passwordTooShort => 'Password too short';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get nameTooShort => 'Name too short';

  // Time
  @override
  String get now => 'Now';
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get daysAgo => '{} days ago';
  @override
  String get hoursAgo => '{} hours ago';
  @override
  String get minutesAgo => '{} minutes ago';
  @override
  String get secondsAgo => '{} seconds ago';

  // File types
  @override
  String get document => 'Document';
  @override
  String get video => 'Video';
  @override
  String get image => 'Image';
  @override
  String get link => 'Link';
  @override
  String get code => 'Code';
  @override
  String get presentation => 'Presentation';
  @override
  String get other => 'Other';

  // User roles
  @override
  String get student => 'Student';
  @override
  String get lecturer => 'Lecturer';
  @override
  String get admin => 'Administrator';

  // Project states
  @override
  String get inProgress => 'In Progress';
  @override
  String get completed => 'Completed';
  @override
  String get graded => 'Graded';
}