class UserModel {
  final String id;
  final String name;
  final String surname;
  final int currentStars;
  final int totalStars;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.currentStars,
    required this.totalStars,
  });

  factory UserModel.fromMap(
      String id, Map<String, dynamic> data, int stars, int total) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      currentStars: stars,
      totalStars: total,
    );
  }
}
