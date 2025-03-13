/// Parses a time string (HH:mm:ss) into a DateTime object (Today at that time)
DateTime parseTime(String? timeString) {
  if (timeString == null) return DateTime.now();

  try {
    List<String> parts = timeString.split(":"); // Split into [HH, MM, SS]
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    int second = int.parse(parts[2]);

    DateTime datetime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hour, minute, second);

    return datetime;
  } catch (e) {
    print("Error parsing time string: $e");
    return DateTime.now();
  }
}

/// Converts a DateTime to a time string (HH:mm:ss)
String? formatTime(DateTime? time) {
  if (time == null) return null;

  // Format it as "HH:mm:ss"
  return time.toIso8601String().substring(11, 19);
}
