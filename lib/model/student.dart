class Student {
  final String id;
  final String name;
  final String? urlProfile;

  Student({required this.id, required this.name, this.urlProfile});

  @override
  String toString() => 'Student($id, $name)';
}
