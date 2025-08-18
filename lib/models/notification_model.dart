import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final Timestamp createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      createdAt: data['created_at'] ?? FieldValue.serverTimestamp(),
    );
  }
}
