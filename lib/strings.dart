const SESSION_START = 'sessionStart';
@deprecated
const WHITELISTED = 'whitelisted';
const BLACKLISTED = 'blacklisted';
const HOSTS_START = '### STAY FOCUSED START ###';
const HOSTS_END = '### STAY FOCUSED END ###';

// https://stackoverflow.com/questions/54775097/formatting-a-duration-like-hhmmss
String formatDuration(Duration d) => d.toString().split('.').first.padLeft(8, "0");

String dateString(DateTime date) => '${date.year}-${date.month}-${date.day}';

DateTime stringToDate(String dateStr) {
  final parts = dateStr.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

String formatDurationNoSecs(Duration d) {
  final str = d.toString().split('.').first;
  return str.substring(0, str.length - 3);
}