class Lesson {
  String id;
  String title;
  String duration;
  // DateTime createAt;
  // String moduleId;
  // Map<String, dynamic> resource;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    // required this.createAt,
    // required this.moduleId,
    // required this.resource,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      duration: json['duration'],
      // createAt: DateTime.parse(json['createAt']),
      // moduleId: json['moduleId'],
      // resource: json['resource'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
    };
  }
}
