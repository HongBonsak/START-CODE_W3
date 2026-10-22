class Course {
  final String id;
  final String name;

  // Enrollment is stored in the course: list of enrolled student IDs (FR1)
  final List<String> studentIds = [];

  Course({required this.id, required this.name});

  @override
  String toString() => 'Course($id, $name)';
}
