import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/activity_model.dart';
import 'package:daim/models/campaign_model.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/menu_item_model.dart';
import 'package:daim/models/notification_model.dart';
import 'package:daim/models/order_item_model.dart';
import 'package:daim/models/order_model.dart';
import 'package:daim/models/pending_order_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/models/star_model.dart';
import 'package:daim/models/user_model.dart';
import 'package:daim/pages/employee_order_page.dart';
import 'package:daim/pages/employee_user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppLoader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> loadEmployeeData(String? userId) async {
    if (userId == null) {
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> employeeSnapshot =
          await _firestore.collection('employees').doc(userId).get();

      if (employeeSnapshot.exists) {
        final data = employeeSnapshot.data();
        if (data != null) {
          Information.name = data['name'] ?? '';
          Information.surname = data['surname'] ?? '';
          Information.phone = data['phone'] ?? '';

          RestaurantModel? restaurant =
              await _loadRestaurantById(data['restaurant_id'] ?? '');

          Information.restaurant = restaurant;
        }
      } else {
        print("❗ Çalışan bulunamadı (userId: $userId)");
      }
    } catch (e) {
      print("🔥 Çalışan Hata: $e");
    }
  }

  static Future<RestaurantModel?> _loadRestaurantById(
      String restaurantId) async {
    print("bilgi: restaurant yükleniyor ($restaurantId)");

    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('restaurants').doc(restaurantId).get();

      if (doc.exists) {
        var data = doc.data()!;
        RestaurantModel restaurantModel = RestaurantModel.fromMap(
          doc.id,
          data,
          await _loadMenu(doc.id),
          await _loadReviews(doc.id),
        );
        print("bilgi: restaurant doğrulandı (${restaurantModel.name})");
        return restaurantModel;
      } else {
        print("❗ Uyarı: $restaurantId için restoran bulunamadı.");
        return null;
      }
    } catch (e) {
      print("HATA BULUNDU: RESTORANT $e");
      return null;
    }
  }

  static Future<void> addCurrentStars(String userId, int amount) async {
    final walletQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (walletQuery.docs.isEmpty) {
      throw Exception("Kullanıcı bulunamadı");
    }

    final userDoc = walletQuery.docs.first.reference;

    final walletDoc = await userDoc
        .collection('wallets')
        .where('restaurant_id', isEqualTo: Information.restaurant!.id)
        .limit(1)
        .get();

    if (walletDoc.docs.isEmpty) {
      throw Exception("Wallet bulunamadı");
    }

    await addActivity(
        userId: walletQuery.docs.first.id,
        amount: amount,
        message:
            "${Information.restaurant!.name} için $amount yıldız kazandın!",
        type: "earned_stars");

    final walletRef = walletDoc.docs.first.reference;

    await walletRef.update({
      'current_amount': FieldValue.increment(amount),
      'total_amount': FieldValue.increment(amount),
    });
  }

  static Future<void> removeStarsByDocId(String docId, int amount) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(docId);

    final userSnap = await userDocRef.get();
    if (!userSnap.exists) throw Exception("❌ Kullanıcı bulunamadı (docId)");

    await _updateWalletAndActivity(userDocRef, amount);
  }

  static Future<void> removeStarsByUserId(String userId, int amount) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty)
      throw Exception("❌ Kullanıcı bulunamadı (user_id)");

    final userDocRef = userQuery.docs.first.reference;

    await _updateWalletAndActivity(userDocRef, amount);
  }

  static Future<void> _updateWalletAndActivity(
      DocumentReference userDocRef, int amount) async {
    final walletQuery = await userDocRef
        .collection('wallets')
        .where('restaurant_id', isEqualTo: Information.restaurant!.id)
        .limit(1)
        .get();

    if (walletQuery.docs.isEmpty) throw Exception("❌ Wallet bulunamadı");

    final walletRef = walletQuery.docs.first.reference;

    await addActivity(
      userId: userDocRef.id,
      amount: amount,
      message: "${Information.restaurant!.name} için $amount yıldız harcadın!",
      type: "spent_stars",
    );

    await walletRef.update({'current_amount': FieldValue.increment(-amount)});
    print("✅ $amount yıldız başarıyla harcandı");
  }

  static Future<void> checkQR(BuildContext context, String code) async {
    UserModel? user = await getUserById(code);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeUserPage(user: user),
        ),
      );

      return;
    }

    PendingOrderModel? order = await getPendingOrderById(code);
    if (order != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeOrderPage(order: order),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Kod bulunamadı!")));
  }

  static Future<UserModel?> getUserById(String id) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: id)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDocRef = userQuery.docs.first.reference;

      final walletsQuery = await userDocRef
          .collection('wallets')
          .where('restaurant_id', isEqualTo: Information.restaurant!.id)
          .limit(1)
          .get();

      if (walletsQuery.docs.isNotEmpty) {
        Map<String, dynamic> data = walletsQuery.docs.first.data();

        print("✅ Wallet bulundu: ${walletsQuery.docs.first.data()}");
        return UserModel.fromMap(id, userQuery.docs.first.data(),
            data['current_amount'] ?? 0, data['total_amount'] ?? 0);
      } else {
        print("⚠️ Wallet bulunamadı");
      }
    } else {
      print("❌ Kullanıcı bulunamadı");
    }

    return null;
  }

  static Future<PendingOrderModel?> getPendingOrderById(String docId) async {
    try {
      var query = await FirebaseFirestore.instance
          .collection("pending")
          .where("order_id", isEqualTo: docId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      var orderDoc = query.docs.first;
      var itemsSnapshot = await orderDoc.reference.collection("items").get();
      PendingOrderModel order = PendingOrderModel.fromMap(
          orderDoc.id,
          orderDoc.data(),
          itemsSnapshot.docs
              .map((doc) => OrderItemModel.fromMap(doc.data()))
              .toList());

      if (order.restaurantId.isEmpty ||
          order.restaurantId != Information.restaurant!.id) {
        return null;
      }

      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(order.userId)
          .get();

      if (userDoc.exists) {
        order.name = userDoc.data()?['name'];
        order.surname = userDoc.data()?['surname'];
      }

      return order;
    } catch (e) {
      print("❌ Sipariş getirilirken hata oluştu: $e");
      return null;
    }
  }

  static Future<void> loadAllData(String? userId) async {
    if (userId == null) return;
    final futures = [
      _loadRestaurants(),
      _loadCampaigns(),
      _loadUserData(),
      _loadOrders(),
      _loadActivities(),
      _loadStars(userId),
      _loadNotifications(userId),
    ];

    await Future.wait(futures);
  }

  static Future<void> _loadUserData() async {
    print("bilgi: user data");

    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      Information.id = FirebaseAuth.instance.currentUser!.uid;
      Information.name = data['name'] ?? '';
      Information.surname = data['surname'] ?? '';
      Information.city = data['city'] ?? '';
      Information.phone = data['phone'] ?? '';
      Information.userId = data['user_id'] ?? '';

      Information.birthday =
          data['birthday'] != null ? data['birthday'] as Timestamp : null;

      Information.register = data['register'] != null
          ? data['register'] as Timestamp
          : Timestamp.now();

      print("bilgi: user data doğrulandı");
    }
  }

  static Future<void> movePendingToOrders(PendingOrderModel order) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final pendingRef = firestore.collection('pending').doc(order.id);
      final pendingSnapshot = await pendingRef.get();

      if (!pendingSnapshot.exists) {
        print("❌ Pending sipariş bulunamadı");
        return;
      }

      final pendingData = pendingSnapshot.data();
      final ordersRef = firestore.collection('orders').doc(order.id);

      await ordersRef.set(pendingData!);

      print("✅ Sipariş verisi orders koleksiyonuna taşındı");

      final itemsSnapshot = await pendingRef.collection('items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        await ordersRef.collection('items').doc(itemDoc.id).set(itemDoc.data());
      }

      print("✅ Alt koleksiyon (items) taşındı");

      await pendingRef.delete();
      print("🗑️ Pending sipariş silindi");

      await addActivity(
          userId: order.userId,
          amount: order.price,
          message: "${Information.restaurant!.name} için sipariş oluşturdun!",
          type: "order");
    } catch (e) {
      print("❌ Hata: $e");
    }
  }

  static Future<void> _loadOrders() async {
    print("bilgi: orders");

    try {
      QuerySnapshot orderDocs = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (orderDocs.docs.isEmpty) {
        Information.orders = [];
        print("bilgi: orders doğrulandı (0 sipariş)");
        return;
      }

      List<OrderModel> orders = [];

      for (var doc in orderDocs.docs) {
        var data = doc.data() as Map<String, dynamic>;

        QuerySnapshot itemsSnapshot = await _firestore
            .collection('orders')
            .doc(doc.id)
            .collection('items')
            .get();

        OrderModel orderModel = OrderModel.fromMap(
            doc.id,
            data,
            itemsSnapshot.docs.map((itemDoc) {
              var itemData = itemDoc.data() as Map<String, dynamic>;
              return OrderItemModel.fromMap(itemData);
            }).toList());

        orders.add(orderModel);
      }

      Information.orders = orders;
      print("bilgi: orders doğrulandı (${Information.orders.length} sipariş)");
    } catch (e) {
      print("❌ Orders yüklenirken hata oluştu: $e");
    }
  }

  static Future<void> _loadRestaurants() async {
    print("bilgi: restaurants");

    try {
      QuerySnapshot restaurantDocs =
          await _firestore.collection('restaurants').get();

      Information.restaurants = await Future.wait(
        restaurantDocs.docs.map((doc) async {
          var data = doc.data() as Map<String, dynamic>;

          RestaurantModel restaurantModel = RestaurantModel.fromMap(doc.id,
              data, await _loadMenu(doc.id), await _loadReviews(doc.id));

          return restaurantModel;
        }),
      );

      print(
          "bilgi: restaurants doğrulandı (${Information.restaurants.length} restoran)");
    } catch (e) {
      print("HATA BULUNDU: RESTORANT $e");
    }
  }

  static Future<List<int>> _loadReviews(String restaurantId) async {
    try {
      QuerySnapshot menuDocs = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('reviews')
          .get();

      return menuDocs.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return (data['rating'] as num?)?.toInt() ?? 0; // Güvenli cast işlemi
      }).toList();
    } catch (e) {
      print("❌ Menüyü yüklerken hata oluştu ($restaurantId): $e");
      return [];
    }
  }

  static Future<List<MenuItemModel>> _loadMenu(String restaurantId) async {
    try {
      QuerySnapshot menuDocs = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .get();

      return menuDocs.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return MenuItemModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print("❌ Menüyü yüklerken hata oluştu ($restaurantId): $e");
      return [];
    }
  }

  static Future<void> _loadStars(String userId) async {
    print("ℹ️ Wallets yükleniyor...");

    try {
      QuerySnapshot walletsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .get();

      print("📌 Wallets belgesi alındı (${walletsSnapshot.docs.length} tane)");

      if (walletsSnapshot.docs.isEmpty) {
        print("⚠️ Kullanıcının hiç yıldız kaydı yok.");
      }

      List<StarModel> wallets = walletsSnapshot.docs.map((doc) {
        var data = doc.data();
        print("🔍 Veri: $data");

        return StarModel.fromMap(data as Map<String, dynamic>, doc.id);
      }).toList();

      Information.wallets = wallets;
      print(
          "✅ Wallets başarıyla yüklendi (${Information.wallets.length} adet).");
    } catch (e) {
      print("❌ Stars yüklenirken hata oluştu: $e");
    }
  }

  static Future<void> addActivity({
    required String userId,
    required int amount,
    required String message,
    required String type,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .add({
        'amount': amount,
        'created_at': FieldValue.serverTimestamp(),
        'message': message,
        'type': type,
      });

      print("✅ Activity başarıyla eklendi.");
    } catch (e) {
      print("❌ Activity eklenirken hata oluştu: $e");
    }
  }

  static Future<void> _loadActivities() async {
    print("bilgi: activities");

    try {
      QuerySnapshot activitiesSnapshot = await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('activities')
          .get();

      List<ActivityModel> activities = activitiesSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return ActivityModel.fromMap(data, doc.id);
      }).toList();

      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      Information.activities = activities;

      print(
          "bilgi: activities doğrulandı (${Information.activities.length} aktivite)");
    } catch (e) {
      print("❌ Activities yüklenirken hata oluştu: $e");
    }
  }

  /// **Kampanyaları Firestore'dan yükler**
  static Future<void> _loadCampaigns() async {
    print("bilgi: campaigns");
    try {
      QuerySnapshot snapshot = await _firestore.collection('campaigns').get();

      Information.campaigns = snapshot.docs
          .map((doc) => CampaignModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      print("bilgi: campaigns doğrulandı");
    } catch (e) {
      print("bilgi: campaigns doğrulanmadı");
    }
  }

  static Future<void> _loadNotifications(String userId) async {
    print("bilgi: notifications");

    try {
      QuerySnapshot generalNotificationsSnapshot =
          await _firestore.collection('notifications').get();

      QuerySnapshot userNotificationsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      List<NotificationModel> generalNotifications =
          generalNotificationsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return NotificationModel.fromMap(data, doc.id);
      }).toList();

      List<NotificationModel> userNotifications =
          userNotificationsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return NotificationModel.fromMap(data, doc.id);
      }).toList();

      // 🔹 Eğer bildirimler `null` ise, boş liste ata
      Information.notifications = [
        ...generalNotifications,
        ...userNotifications
      ];

      print(
          "bilgi: notifications doğrulandı (${Information.notifications.length} bildirim)");
    } catch (e) {
      print("❌ Notifications yüklenirken hata oluştu: $e");
    }
  }

  static String generateRandomId() {
    Random random = Random();
    return (10000000 + random.nextInt(90000000)).toString();
  }

  static Future<bool> deletePendingOrder() async {
    try {
      QuerySnapshot pendingQuery = await _firestore
          .collection('pending')
          .where('user_id', isEqualTo: Information.id)
          .get();

      if (pendingQuery.docs.isNotEmpty) {
        String existingOrderId = pendingQuery.docs.first.id;
        await _firestore.collection('pending').doc(existingOrderId).delete();
        print("❌ Eski pending siparişi silindi! Order ID: $existingOrderId");

        return true;
      }

      return false;
    } catch (e) {
      print("❌ Pending Order silinirken hata oluştu: $e");
      return false;
    }
  }

  static Future<String> createPendingOrder(OrderModel order) async {
    try {
      await deletePendingOrder();

      String orderId = generateRandomId();

      DocumentReference orderRef = await _firestore.collection('pending').add({
        'order_id': orderId,
        'restaurant_id': order.restaurantId,
        'user_id': Information.id,
        'price': order.price,
        'created_at': FieldValue.serverTimestamp(),
      });

      for (OrderItemModel item in order.items) {
        await orderRef.collection('items').add({
          'id': item.id,
          'unit_price': item.unitPrice,
          'amount': item.amount,
          'user_id': Information.id,
        });
      }

      print("✅ Pending Order Oluşturuldu! Order ID: $orderId");
      return orderId;
    } catch (e) {
      print("❌ Pending Order oluşturulurken hata oluştu: $e");
      return "";
    }
  }
}
