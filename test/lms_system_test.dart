import 'package:test/test.dart';

import '../lib/service/lms_system.dart';

void main() {
  late LmsSystem lms;

  setUp(() {
    lms = LmsSystem();
    lms.addStudent(studentId: 'S01', studentName: 'Sok');
    lms.addStudent(studentId: 'S02', studentName: 'Dara');
    lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
    lms.addCourse(courseId: 'C02', courseName: 'Databases');
  });

  // -----------------------------------------------------------------
  group('Students', () {
    test('creates and removes a student', () {
      lms.addStudent(studentId: 'S3', studentName: 'ronan');
      expect(lms.students.last.name, 'ronan');

      lms.removeStudent(studentId: 'S3');
      expect(lms.studentExists('S3'), isFalse);
    });

    test('rejects duplicate student', () {
      expect(
        () => lms.addStudent(studentId: 'S01', studentName: 'X'),
        throwsException,
      );
      expect(lms.students.length, 2);
    });

    test('rejects removing unknown student', () {
      expect(() => lms.removeStudent(studentId: 'S99'), throwsException);
    });
  });

  // -----------------------------------------------------------------
  group('Task 1 - add and remove courses', () {
    test('add and remove a course', () {
      lms.addCourse(courseId: 'C03', courseName: 'Networks');
      expect(lms.courseExists('C03'), isTrue);

      lms.removeCourse(courseId: 'C03');
      expect(lms.courseExists('C03'), isFalse);
    });

    test('reject duplicate course id', () {
      expect(
        () => lms.addCourse(courseId: 'C01', courseName: 'Other'),
        throwsException,
      );
      expect(lms.courses.length, 2);
    });

    test('reject removal of nonexistent course', () {
      expect(() => lms.removeCourse(courseId: 'NOPE'), throwsException);
    });

    test('removing a course removes its results, keeps students', () {
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);

      lms.removeCourse(courseId: 'C01');

      expect(lms.results, isEmpty);
      expect(lms.studentExists('S01'), isTrue);
    });
  });

  // -----------------------------------------------------------------
  group('Task 2 - enroll a student', () {
    test('enroll existing student in existing course', () {
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C01'), isTrue);
    });

    test('student in several courses, course with several students', () {
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');

      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C02'), isTrue);
      expect(lms.courses.first.studentIds.length, 2);
    });

    test('reject unknown student', () {
      expect(
        () => lms.enrollStudent(studentId: 'S99', courseId: 'C01'),
        throwsException,
      );
    });

    test('reject unknown course', () {
      expect(
        () => lms.enrollStudent(studentId: 'S01', courseId: 'C99'),
        throwsException,
      );
    });

    test('reject duplicate enrollment', () {
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      expect(
        () => lms.enrollStudent(studentId: 'S01', courseId: 'C01'),
        throwsException,
      );
      expect(lms.courses.first.studentIds.length, 1);
    });
  });

  // -----------------------------------------------------------------
  group('Task 3 - discard student from course', () {
    setUp(() {
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      lms.addResult(studentId: 'S01', courseId: 'C02', score: 70);
    });

    test('remove an existing enrollment', () {
      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C01'), isFalse);
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C02'), isTrue);
    });

    test('reject nonexistent enrollment', () {
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S02', courseId: 'C01'),
        throwsException,
      );
    });

    test('reject unknown student or course', () {
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S99', courseId: 'C01'),
        throwsException,
      );
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C99'),
        throwsException,
      );
    });

    test('student and course still exist afterwards', () {
      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');
      expect(lms.studentExists('S01'), isTrue);
      expect(lms.courseExists('C01'), isTrue);
    });

    test('policy: results of that course removed, other course kept', () {
      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');
      expect(lms.resultsOfCourse('C01'), isEmpty);
      expect(lms.resultsOfCourse('C02').length, 1);
    });

    test('removeStudent with enrollments in multiple courses', () {
      lms.removeStudent(studentId: 'S01');
      expect(lms.studentExists('S01'), isFalse);
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C01'), isFalse);
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C02'), isFalse);
      expect(lms.resultsOfStudent('S01'), isEmpty);
    });
  });

  // -----------------------------------------------------------------
  group('FR5 - remove student (full scenario)', () {
    test('removed student has no trace, other student unchanged', () {
      // 1. two students (setUp)  2. course (setUp)  3. enroll both
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      // 5. results for both
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      lms.addResult(studentId: 'S02', courseId: 'C01', score: 90);

      // 6. remove one student
      lms.removeStudent(studentId: 'S01');

      // removed student
      expect(lms.studentExists('S01'), isFalse);
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C01'), isFalse);
      expect(lms.resultsOfStudent('S01'), isEmpty);

      // other student unchanged
      expect(lms.studentExists('S02'), isTrue);
      expect(lms.isEnrolled(studentId: 'S02', courseId: 'C01'), isTrue);
      expect(lms.resultsOfStudent('S02').length, 1);
      expect(lms.resultsOfStudent('S02').first.score, 90);
    });
  });

  // -----------------------------------------------------------------
  group('Task 4 - add a result', () {
    setUp(() => lms.enrollStudent(studentId: 'S01', courseId: 'C01'));

    test('add a valid result', () {
      final r = lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      expect(lms.resultExists(r.id), isTrue);
      expect(r.score, 85);
    });

    test('reject nonexistent student or course', () {
      expect(
        () => lms.addResult(studentId: 'S99', courseId: 'C01', score: 85),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C99', score: 85),
        throwsException,
      );
    });

    test('reject student not enrolled', () {
      expect(
        () => lms.addResult(studentId: 'S02', courseId: 'C01', score: 85),
        throwsException,
      );
    });

    test('reject invalid score', () {
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: -1),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: 101),
        throwsException,
      );
      expect(lms.results, isEmpty);
    });

    test('accept boundary scores 0 and 100', () {
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 0);
      lms.addResult(studentId: 'S01', courseId: 'C02', score: 100);
      expect(lms.results.length, 2);
    });

    test('policy: reject second result for same student and course', () {
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: 90),
        throwsException,
      );
      expect(lms.results.length, 1);
    });
  });

  // -----------------------------------------------------------------
  group('Task 5 - remove a result', () {
    test('remove existing result, everything else unchanged', () {
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');
      final r1 = lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      final r2 = lms.addResult(studentId: 'S02', courseId: 'C01', score: 90);

      lms.removeResult(resultId: r1.id);

      expect(lms.resultExists(r1.id), isFalse);
      expect(lms.resultExists(r2.id), isTrue);
      expect(lms.studentExists('S01'), isTrue);
      expect(lms.courseExists('C01'), isTrue);
      expect(lms.isEnrolled(studentId: 'S01', courseId: 'C01'), isTrue);
    });

    test('reject nonexistent result', () {
      expect(() => lms.removeResult(resultId: 999), throwsException);
    });
  });
}
