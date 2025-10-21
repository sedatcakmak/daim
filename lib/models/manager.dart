import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/app_loader.dart';
import 'package:daim/models/information.dart';
import 'package:flutter/foundation.dart';

class Manager {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> createUser(
    String name,
    String surname,
    String phone,
    String city,
  ) async {
    try {
      QuerySnapshot<Map<String, dynamic>> userDoc = await firestore
          .collection('users')
          .where('phone', isEqualTo: Information.phone)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        debugPrint("Bu kullanıcı zaten kayıtlı!");
        return;
      }

      await firestore.collection('users').doc().set({
        'name': name,
        'city': city,
        'surname': surname,
        'phone': phone,
        'user_id': AppLoader.generateRandomId(),
        'register': Timestamp.now(),
        'total_balance': 0.0,
        'current_balance': 0.0,
        'badges': [],
      });
    } catch (e) {
      return;
    }
  }

  static Map<String, dynamic> getMembership(int total) {
    if (total >= 50) {
      return {"name": "Elmas Üye", "required": 0};
    } else if (total >= 25) {
      return {"name": "Altın Üye", "required": 50};
    } else {
      return {"name": "Gümüş Üye", "required": 25};
    }
  }

  static Future<bool> isReviewed({
    required String restaurantId,
    required String orderId,
  }) async {
    QuerySnapshot existingReview = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .where('order_id', isEqualTo: orderId)
        .get();

    if (existingReview.docs.isNotEmpty) {
      debugPrint("Bu sipariş için zaten bir değerlendirme yapılmış.");
      return true;
    }

    return false;
  }

  static Future<bool> addReview({
    required String restaurantId,
    required String comment,
    required int rating,
    required String orderId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('reviews')
          .add({
            'comment': comment,
            'rating': rating,
            'order_id': orderId,
            'date': FieldValue.serverTimestamp(),
          });

      Information.restaurants
          .where((element) => element.id == restaurantId)
          .first
          .reviews
          .add(rating);

      debugPrint("Yorum başarıyla eklendi.");
      return true;
    } catch (e) {
      debugPrint("Yorum eklenirken hata oluştu: $e");
      return false;
    }
  }
}
