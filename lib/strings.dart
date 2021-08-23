const SESSION_START = 'session_start';

// https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
String formatDuration(Duration d) => d.toString().split('.').first.padLeft(8, "0");