class Folder {
  String id;
  String name;
  String userId;
  List<String> courses;

  Folder({
    required this.id,
    required this.name,
    required this.userId,
    required this.courses,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String,
      courses: (json['courses'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'courses': courses,
    };
  }
}
