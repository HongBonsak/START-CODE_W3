import '../model/course.dart';
import '../model/course_result.dart';
import '../model/student.dart';

class LmsSystem {
  static const int minScore = 0;
  static const int maxScore = 100;

  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];
  int _nextResultId = 1;

  // ---------------------------------------------------------------
  // STUDENTS
  // ---------------------------------------------------------------

  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $studentId already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }

  // FR5 - business operation, not just a delete
  void removeStudent({required String studentId}) {
    // ! Student must exist
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    // 1- Remove student from the students list
    students.removeWhere((s) => s.id == studentId);

    // 2- Remove student from every course
    for (Course course in courses) {
      course.studentIds.remove(studentId);
    }

    // 3- Remove all results of this student
    results.removeWhere((r) => r.student.id == studentId);
  }

  // ---------------------------------------------------------------
  // TASK 1 - COURSES
  // ---------------------------------------------------------------

  // FR1
  void addCourse({required String courseId, required String courseName}) {
    // ! Course shall not exist already
    Course? course = _findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $courseId already exists');
    }

    courses.add(Course(id: courseId, name: courseName));
  }

  // POLICY: results of the course are removed too (cascade).
  // Enrollments disappear with the course (stored inside it).
  // Students are NOT removed.
  void removeCourse({required String courseId}) {
    // ! Course must exist
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    results.removeWhere((r) => r.course.id == courseId);
    courses.removeWhere((c) => c.id == courseId);
  }

  // ---------------------------------------------------------------
  // TASK 2 - ENROLL
  // ---------------------------------------------------------------

  // FR2
  void enrollStudent({required String studentId, required String courseId}) {
    // ! Student must exist
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    // ! Course must exist
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    // ! Student must not be enrolled already
    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId already enrolled in $courseId');
    }

    course.studentIds.add(studentId);
  }

  // ---------------------------------------------------------------
  // TASK 3 - DISCARD STUDENT FROM COURSE
  // ---------------------------------------------------------------

  // POLICY: results of this student in this course are removed too.
  // Student and course themselves stay.
  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    // ! Student must exist
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    // ! Course must exist
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    // ! Student must be enrolled
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }

    course.studentIds.remove(studentId);
    results.removeWhere(
      (r) => r.student.id == studentId && r.course.id == courseId,
    );
  }

  // ---------------------------------------------------------------
  // TASK 4 - ADD RESULT
  // ---------------------------------------------------------------

  // FR4
  // RULES: student exists, course exists, student enrolled,
  //        score between 0 and 100,
  //        ONE result per (student, course).
  // Returns the created result (id is generated).
  CourseResult addResult({
    required String studentId,
    required String courseId,
    required int score,
  }) {
    // ! Student must exist
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    // ! Course must exist
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    // ! Student must be enrolled
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }

    // ! Score must be valid
    if (score < minScore || score > maxScore) {
      throw Exception('Score must be between $minScore and $maxScore');
    }

    // ! No second result for the same student and course
    bool duplicate = results.any(
      (r) => r.student.id == studentId && r.course.id == courseId,
    );
    if (duplicate) {
      throw Exception('Result already exists for $studentId in $courseId');
    }

    CourseResult result = CourseResult(
      id: _nextResultId++,
      student: student,
      course: course,
      score: score,
    );
    results.add(result);
    return result;
  }

  // ---------------------------------------------------------------
  // TASK 5 - REMOVE RESULT
  // ---------------------------------------------------------------

  // Student and course objects are NOT affected.
  void removeResult({required int resultId}) {
    // ! Result must exist
    CourseResult? result = _findResultOrNull(resultId);
    if (result == null) {
      throw Exception('Result $resultId not found');
    }

    results.removeWhere((r) => r.id == resultId);
  }

  // ---------------------------------------------------------------
  // QUERIES (used by tests, no internal list access needed)
  // ---------------------------------------------------------------

  bool studentExists(String studentId) => _findStudentOrNull(studentId) != null;

  bool courseExists(String courseId) => _findCourseOrNull(courseId) != null;

  bool isEnrolled({required String studentId, required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    return course != null && course.studentIds.contains(studentId);
  }

  List<CourseResult> resultsOfStudent(String studentId) =>
      results.where((r) => r.student.id == studentId).toList();

  List<CourseResult> resultsOfCourse(String courseId) =>
      results.where((r) => r.course.id == courseId).toList();

  bool resultExists(int resultId) => _findResultOrNull(resultId) != null;

  // ---------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------

  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null; // not found
  }

  CourseResult? _findResultOrNull(int resultId) {
    for (CourseResult r in results) {
      if (r.id == resultId) {
        return r;
      }
    }
    return null; // not found
  }
}
