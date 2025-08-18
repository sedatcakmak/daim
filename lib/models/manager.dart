import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/app_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Manager {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String> createUser(
      String name, String surname, String phone, String city) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        print("Bu kullanıcı zaten kayıtlı!");
        return "Bu telefon numarası zaten kayıtlı!";
      }

      await firestore.collection('users').doc(userId).set({
        'name': name,
        'city': city,
        'surname': surname,
        'phone': phone,
        'user_id': AppLoader.generateRandomId(),
        'register': Timestamp.now(),
        'total_balance': 0.0,
        'current_balance': 0.0,
      });

      return FirebaseAuth.instance.currentUser!.uid;
    } catch (e) {
      return "❌ Kullanıcı oluşturulurken hata oluştu: $e";
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

  static Future<String> addActivity(String type, int amount) async {
    try {
      Map<String, dynamic> activityData = {
        'type': type,
        'amount': amount,
        'created_at': Timestamp.now(),
      };

      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('activities')
          .add(activityData);

      return "✅ Aktivite başarıyla eklendi!";
    } catch (e) {
      return "❌ Aktivite eklenirken hata oluştu: $e";
    }
  }

  static Future<String> addNotification(
      String description, String title, String image) async {
    try {
      Map<String, dynamic> notificationData = {
        'description': description,
        'title': title,
        'imageUrl': image,
        'date': Timestamp.now(),
      };

      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .add(notificationData);

      return "✅ Bildirim başarıyla eklendi!";
    } catch (e) {
      return "❌ Bildirim eklenirken hata oluştu: $e";
    }
  }

  static Future<String> addStar(String restaurantId, int amount) async {
    try {
      CollectionReference starsRef = firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('stars');
      QuerySnapshot existingStars =
          await starsRef.where('restaurant_id', isEqualTo: restaurantId).get();

      if (existingStars.docs.isNotEmpty) {
        String starDocId = existingStars.docs.first.id;
        await starsRef.doc(starDocId).update({
          'amount': FieldValue.increment(amount),
        });

        return "✅ Mevcut restorana yıldız eklendi!";
      } else {
        await starsRef.add({
          'restaurant_id': restaurantId,
          'amount': amount,
        });

        return "✅ Yeni restoran için yıldız oluşturuldu!";
      }
    } catch (e) {
      return "❌ Yıldız eklenirken hata oluştu: $e";
    }
  }
}
