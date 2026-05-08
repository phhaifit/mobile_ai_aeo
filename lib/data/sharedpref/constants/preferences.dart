class Preferences {
  Preferences._();

  static const String is_logged_in = "isLoggedIn";
  static const String auth_token = "authToken";
  static const String current_project_id = "currentProjectId";
  static const String is_dark_mode = "is_dark_mode";
  static const String current_language = "current_language";

  /// JSON array of `{id,title,updatedAtMs}` for Assistant drawer recent chats.
  static const String assistant_recent_sessions = "assistantRecentSessions";
}