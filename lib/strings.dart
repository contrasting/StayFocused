const SESSION_START = 'sessionStart';

// https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
String formatDuration(Duration d) => d.toString().split('.').first.padLeft(8, "0");

String dateString(DateTime date) => '${date.year}-${date.month}-${date.day}';