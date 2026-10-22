import 'course.dart';
import 'student.dart';

class CourseResult {
  final int id;
  final Student student;
  final Course course;
  final int score;

  CourseResult({
    required this.id,
    required this.student,
    required this.course,
    required this.score,
  });

  @override
  String toString() => 'CourseResult($id, ${student.id}, ${course.id}, $score)';
}
