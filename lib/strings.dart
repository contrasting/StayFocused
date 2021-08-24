const SESSION_START = 'sessionStart';
const WHITELISTED = 'whitelisted';

// https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
String formatDuration(Duration d) => d.toString().split('.').first.padLeft(8, "0");

String dateString(DateTime date) => '${date.year}-${date.month}-${date.day}';

DateTime stringToDate(String dateStr) {
  final parts = dateStr.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}