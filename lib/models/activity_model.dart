import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String type;
  final int amount;
  final Timestamp createdAt;
  final String message;

  ActivityModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.message,
    required this.createdAt,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> data, String id) {
    return ActivityModel(
      id: id,
      message: data['message'] ?? 'bilinmeyen aktivite',
      type: data['type'] ?? '',
      amount: data['amount'] ?? 0,
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }
}
