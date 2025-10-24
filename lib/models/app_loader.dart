import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/managers/deeplink_manager.dart';
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
import 'package:daim/pages/employee_order_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLoader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> loadEmployeeData(String? phone) async {
    if (phone == null) {
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> employeeQuery = await _firestore
          .collection('employees')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (employeeQuery.docs.isEmpty) {
        return;
      }

      final employeeSnapshot = employeeQuery.docs.first;

      final data = employeeSnapshot.data();
      Information.name = data['name'] ?? '';
      Information.surname = data['surname'] ?? '';
      Information.phone = data['phone'] ?? '';

      RestaurantModel? restaurant = await _loadRestaurantById(
        data['restaurant_id'] ?? '',
      );

      Information.restaurant = restaurant;
    } catch (e) {
      debugPrint("🔥 Çalışan Hata: $e");
    }
  }

  static Future<RestaurantModel?> _loadRestaurantById(
    String restaurantId,
  ) async {
    debugPrint("bilgi: restaurant yükleniyor ($restaurantId)");

    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (doc.exists) {
        var data = doc.data()!;
        RestaurantModel restaurantModel = RestaurantModel.fromMap(
          doc.id,
          data,
          await _loadMenu(doc.id),
          await _loadReviews(doc.id),
        );
        debugPrint("bilgi: restaurant doğrulandı (${restaurantModel.name})");
        return restaurantModel;
      } else {
        debugPrint("❗ Uyarı: $restaurantId için restoran bulunamadı.");
        return null;
      }
    } catch (e) {
      debugPrint("HATA BULUNDU: RESTORANT $e");
      return null;
    }
  }

  static Future<void> addCurrentStars(String restaurantId, int amount) async {
    final walletQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: Information.phone)
        .limit(1)
        .get();

    if (walletQuery.docs.isEmpty) {
      throw Exception("Kullanıcı bulunamadı");
    }

    final userDoc = walletQuery.docs.first.reference;

    final walletDoc = await userDoc
        .collection('wallets')
        .where('restaurant_id', isEqualTo: restaurantId)
        .limit(1)
        .get();

    if (walletDoc.docs.isEmpty) {
      throw Exception("Wallet bulunamadı");
    }

    await addActivity(
      phone: Information.phone,
      amount: amount,
      message: "${Information.restaurant!.name} için $amount yıldız kazandın!",
      type: "earned_stars",
    );

    final walletRef = walletDoc.docs.first.reference;

    await walletRef.update({
      'current_amount': FieldValue.increment(amount),
      'total_amount': FieldValue.increment(amount),
    });
  }

  static Future<bool> removeStarsByPhone(String phone, int amount) async {
    // Kullanıcıyı phone alanına göre bul
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("❌ Kullanıcı bulunamadı (phone=$phone)");
    }

    final userDocRef = userQuery.docs.first.reference;

    return await _updateWalletAndActivity(phone, userDocRef, amount);
  }

  static Future<bool> _updateWalletAndActivity(
    String phone,
    DocumentReference userDocRef,
    int amount,
  ) async {
    try {
      // Kullanıcının cüzdanını bul
      final walletQuery = await userDocRef
          .collection('wallets')
          .where('restaurant_id', isEqualTo: Information.restaurant!.id)
          .limit(1)
          .get();

      // Cüzdan yoksa false döndür
      if (walletQuery.docs.isEmpty) {
        debugPrint("❌ Cüzdan bulunamadı.");
        return false;
      }

      final walletRef = walletQuery.docs.first.reference;
      final walletData = walletQuery.docs.first.data();

      final currentStars = walletData['current_amount'] ?? 0;

      // Yeterli yıldız yoksa false döndür
      if (currentStars < amount) {
        debugPrint(
          "❌ Yetersiz yıldız! Mevcut: $currentStars, Gerekli: $amount",
        );
        return false;
      }

      // Aktivite ekle
      await addActivity(
        phone: phone,
        amount: amount,
        message:
            "${Information.restaurant!.name} için $amount yıldız harcadın!",
        type: "spent_stars",
      );

      // Cüzdandan yıldız düş
      await walletRef.update({'current_amount': FieldValue.increment(-amount)});

      debugPrint("✅ $amount yıldız başarıyla harcandı");
      return true;
    } catch (e) {
      debugPrint("❌ Yıldız harcama hatası: $e");
      return false;
    }
  }

  static Future<void> checkQR(BuildContext context, String code) async {
    PendingOrderModel? order = await getPendingOrderById(code);
    if (order != null) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmployeeOrderPage(order: order)),
      );
      return;
    }

    DeepLinkManager().handleDeepLink(code);

    /*

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Kod bulunamadı!")));
    */
  }

  static Future<PendingOrderModel?> getPendingOrderById(String docId) async {
    try {
      // 1. Pending order'ı bul
      final query = await FirebaseFirestore.instance
          .collection("pending")
          .where("order_id", isEqualTo: docId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final orderDoc = query.docs.first;

      // 2. Items alt koleksiyonunu al
      final itemsSnapshot = await orderDoc.reference.collection("items").get();

      final order = PendingOrderModel.fromMap(
        orderDoc.id,
        orderDoc.data(),
        itemsSnapshot.docs
            .map((doc) => OrderItemModel.fromMap(doc.data()))
            .toList(),
      );

      // 3. Restoran kontrolü
      if (order.restaurantId.isEmpty ||
          order.restaurantId != Information.restaurant!.id) {
        return null;
      }

      // 4. Kullanıcıyı phone alanına göre bul
      final phone = order.phone; // PendingOrderModel içinde phone alanı olmalı
      if (phone.isNotEmpty) {
        final userQuery = await FirebaseFirestore.instance
            .collection("users")
            .where("phone", isEqualTo: phone)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          order.name = userData['name'];
          order.surname = userData['surname'];
        }
      } else {
        debugPrint("⚠️ Order içinde phone alanı boş");
      }

      return order;
    } catch (e) {
      debugPrint("❌ Sipariş getirilirken hata oluştu: $e");
      return null;
    }
  }

  static Future<void> loadGuestData() async {
    final futures = [
      _loadRestaurants(),
      _loadCampaigns(),
      _loadGeneralNotifications(),
    ];

    await Future.wait(futures);
  }

  static Future<void> loadAllData(String? phone) async {
    if (phone == null) return;
    Information.phone = phone;

    await Future.wait([_loadUserData()]);

    final futures = [
      _loadRestaurants(),
      _loadCampaigns(),
      loadOrders(),
      loadActivities(),
      loadStars(),
      _loadNotifications(),
    ];

    await Future.wait(futures);
  }

  static Future<void> _loadUserData() async {
    debugPrint("bilgi: user data");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Information.id = prefs.getString("id") ?? '';
    if (Information.id.isEmpty || Information.name.isEmpty) {
      final qs = await _firestore
          .collection('users')
          .where('phone', isEqualTo: Information.phone)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        debugPrint("❌ User bulunamadı ");
        return;
      }

      final userDoc = qs.docs.first;
      final data = userDoc.data();

      Information.id = userDoc.id;
      prefs.setString("id", userDoc.id);

      Information.name = data['name'] ?? '';
      prefs.setString("name", Information.name);

      Information.surname = data['surname'] ?? '';
      prefs.setString("surname", Information.surname);

      Information.city = data['city'] ?? '';
      prefs.setString("city", Information.city);

      Information.userId = data['user_id'] ?? '';
      prefs.setString("user_id", Information.userId);

      Information.badges = List<String>.from(data['badges'] ?? []);
      prefs.setStringList("badges", Information.badges);
    } else {
      Information.name = prefs.getString("name") ?? '';
      Information.surname = prefs.getString("surname") ?? '';
      Information.city = prefs.getString("city") ?? '';
      Information.userId = prefs.getString("user_id") ?? '';
      Information.badges = prefs.getStringList("badges") ?? [];
    }

    debugPrint("bilgi: user data doğrulandı");
  }

  static Future<void> movePendingToOrders(PendingOrderModel order) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final pendingRef = firestore.collection('pending').doc(order.id);
      final pendingSnapshot = await pendingRef.get();

      if (!pendingSnapshot.exists) {
        debugPrint("❌ Pending sipariş bulunamadı");
        return;
      }

      final pendingData = pendingSnapshot.data();
      final ordersRef = firestore.collection('orders').doc(order.id);

      await ordersRef.set(pendingData!);

      debugPrint("✅ Sipariş verisi orders koleksiyonuna taşındı");

      final itemsSnapshot = await pendingRef.collection('items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        await ordersRef.collection('items').doc(itemDoc.id).set(itemDoc.data());
      }

      debugPrint("✅ Alt koleksiyon (items) taşındı");

      await pendingRef.delete();
      debugPrint("🗑️ Pending sipariş silindi");

      await addActivity(
        phone: order.phone,
        amount: order.price,
        message: "${Information.restaurant!.name} için sipariş oluşturdun!",
        type: "order",
      );
    } catch (e) {
      debugPrint("❌ Hata: $e");
    }
  }

  static Future<void> loadOrders() async {
    debugPrint("bilgi: orders");

    try {
      QuerySnapshot orderDocs = await _firestore
          .collection('orders')
          .where('phone', isEqualTo: Information.phone)
          .get();

      if (orderDocs.docs.isEmpty) {
        Information.orders = [];
        debugPrint("bilgi: orders doğrulandı (0 sipariş)");
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
          }).toList(),
        );

        orders.add(orderModel);
      }

      Information.orders = orders;
      debugPrint(
        "bilgi: orders doğrulandı (${Information.orders.length} sipariş)",
      );
    } catch (e) {
      debugPrint("❌ Orders yüklenirken hata oluştu: $e");
    }
  }

  static Future<void> _loadRestaurants() async {
    debugPrint("bilgi: restaurants");

    try {
      QuerySnapshot restaurantDocs = await _firestore
          .collection('restaurants')
          .get();

      Information.restaurants =
          (await Future.wait(
                restaurantDocs.docs.map((doc) async {
                  /*
                  if (doc.id == "89342613") {
                    return null;
                  }
                  */

                  var data = doc.data() as Map<String, dynamic>;

                  RestaurantModel restaurantModel = RestaurantModel.fromMap(
                    doc.id,
                    data,
                    await _loadMenu(doc.id),
                    await _loadReviews(doc.id),
                  );

                  if (restaurantModel.address.contains(Information.city)) {
                    final now = DateTime.now();
                    final oneWeekAgo = now.subtract(const Duration(days: 7));
                    final createdAt = restaurantModel.createdAt.toDate();

                    restaurantModel.isNew = createdAt.isAfter(oneWeekAgo);
                  }

                  return restaurantModel;
                }),
              ))
              .whereType<RestaurantModel>() // null dönenleri at
              .toList();

      debugPrint(
        "bilgi: restaurants doğrulandı (${Information.restaurants.length} restoran)",
      );
    } catch (e) {
      debugPrint("HATA BULUNDU: RESTORANT $e");
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
      debugPrint("❌ Menüyü yüklerken hata oluştu ($restaurantId): $e");
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
      debugPrint("❌ Menüyü yüklerken hata oluştu ($restaurantId): $e");
      return [];
    }
  }

  static Future<void> loadStars() async {
    debugPrint("ℹ️ Wallets yükleniyor...");

    try {
      // önce phone eşleşen kullanıcı belgesini bul
      final qs = await _firestore
          .collection('users')
          .where('phone', isEqualTo: Information.phone)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        debugPrint("⚠️ Böyle bir kullanıcı bulunamadı");
        return;
      }

      final userDoc = qs.docs.first; // eşleşen kullanıcı belgesi
      final userDocId = userDoc.id;

      // wallet alt koleksiyonunu getir
      final walletsSnapshot = await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('wallets')
          .get();

      debugPrint(
        "📌 Wallets belgesi alındı (${walletsSnapshot.docs.length} tane)",
      );

      if (walletsSnapshot.docs.isEmpty) {
        debugPrint("⚠️ Kullanıcının hiç yıldız kaydı yok.");
      }

      final wallets = walletsSnapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint("🔍 Veri: $data");
        return StarModel.fromMap(data, doc.id);
      }).toList();

      Information.wallets = wallets;
      debugPrint(
        "✅ Wallets başarıyla yüklendi (${Information.wallets.length} adet).",
      );
    } catch (e) {
      debugPrint("❌ Stars yüklenirken hata oluştu: $e");
    }
  }

  static Future<void> addActivity({
    required String phone,
    required int amount,
    required String message,
    required String type,
  }) async {
    try {
      final qs = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        debugPrint("❌ Kullanıcı bulunamadı");
        return;
      }

      final userDocId = qs.docs.first.id;

      await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('activities')
          .add({
            'amount': amount,
            'created_at': FieldValue.serverTimestamp(),
            'message': message,
            'type': type,
          });

      debugPrint("✅ Activity başarıyla eklendi.");
    } catch (e) {
      debugPrint("❌ Activity eklenirken hata oluştu: $e");
    }
  }

  static Future<void> loadActivities() async {
    debugPrint("bilgi: activities");

    final qs = await _firestore
        .collection('users')
        .where('phone', isEqualTo: Information.phone)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) {
      debugPrint("❌ User bulunamadı");
      return;
    }

    final userDocId = qs.docs.first.id;

    final activitiesSnapshot = await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('activities')
        .get();

    final activities = activitiesSnapshot.docs.map((doc) {
      final data = doc.data();
      return ActivityModel.fromMap(data, doc.id);
    }).toList();

    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    Information.activities = activities;

    debugPrint("bilgi: activities doğrulandı (${activities.length} aktivite)");
  }

  static Future<void> _loadGeneralNotifications() async {
    try {
      final generalSnap = await _firestore.collection('notifications').get();

      Information.notifications = generalSnap.docs.map((doc) {
        final data = doc.data();
        return NotificationModel.fromMap(data, doc.id);
      }).toList();
      return;
    } catch (e) {
      debugPrint("❌ Notifications yüklenirken hata oluştu: $e");
    }
  }

  /// **Kampanyaları Firestore'dan yükler**
  static Future<void> _loadCampaigns() async {
    debugPrint("bilgi: campaigns");
    try {
      QuerySnapshot snapshot = await _firestore.collection('campaigns').get();

      Information.campaigns = snapshot.docs
          .map(
            (doc) => CampaignModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
      debugPrint("bilgi: campaigns doğrulandı");
    } catch (e) {
      debugPrint("bilgi: campaigns doğrulanmadı");
    }
  }

  static Future<void> _loadNotifications() async {
    debugPrint("ℹ️ Notifications yükleniyor...");

    try {
      // 1. Genel bildirimleri al
      final generalSnap = await _firestore.collection('notifications').get();

      // 2. Kullanıcıyı telefona göre bul
      final qs = await _firestore
          .collection('users')
          .where('phone', isEqualTo: Information.phone)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        debugPrint("⚠️ Kullanıcı bulunamadı (phone=).");
        Information.notifications = generalSnap.docs.map((doc) {
          final data = doc.data();
          return NotificationModel.fromMap(data, doc.id);
        }).toList();
        return;
      }

      final userDocId = qs.docs.first.id;

      // 3. Kullanıcıya özel bildirimleri çek
      final userSnap = await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('notifications')
          .get();

      // 4. Maple
      final generalNotifications = generalSnap.docs.map((doc) {
        final data = doc.data();
        return NotificationModel.fromMap(data, doc.id);
      }).toList();

      final userNotifications = userSnap.docs.map((doc) {
        final data = doc.data();
        return NotificationModel.fromMap(data, doc.id);
      }).toList();

      // 5. Listeyi birleştir
      Information.notifications = [
        ...generalNotifications,
        ...userNotifications,
      ];

      debugPrint(
        "✅ Notifications yüklendi (${Information.notifications.length} adet)",
      );
    } catch (e) {
      debugPrint("❌ Notifications yüklenirken hata oluştu: $e");
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
          .where('phone', isEqualTo: Information.phone)
          .get();

      if (pendingQuery.docs.isNotEmpty) {
        String existingOrderId = pendingQuery.docs.first.id;
        await _firestore.collection('pending').doc(existingOrderId).delete();
        debugPrint(
          "❌ Eski pending siparişi silindi! Order ID: $existingOrderId",
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("❌ Pending Order silinirken hata oluştu: $e");
      return false;
    }
  }

  static Future<void> useCode(BuildContext context, String code) async {
    final db = FirebaseFirestore.instance;

    // kodu bul
    final qs = await db
        .collection('codes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (!context.mounted) return;
    if (qs.docs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kod bulunamadı!")));
      return;
    }

    final doc = qs.docs.first;
    final ref = doc.reference;
    final data = doc.data();

    final int maximum = (data['maximum'] as num?)?.toInt() ?? 0;
    final int usage = (data['usage'] as num?)?.toInt() ?? 0;
    final int balance = (data['balance'] as num?)?.toInt() ?? 0;
    final List<dynamic> users = (data['users'] as List?) ?? [];

    // telefon zaten kullanmış mı?
    if (users.contains(Information.phone)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bu kodu zaten kullanmışsın!")));
      return;
    }
    // limit dolmuş mu?
    if (usage >= maximum) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bu kodun kullanma sayısı bitmiş!")),
      );
      return;
    }

    // güncelle usage +1, kullanıcıyı ekle
    await ref.update({
      'usage': usage + 1,
      'users': [...users, Information.phone],
    });

    // ödül ver
    final String restaurantId = data['restaurant_id']?.toString() ?? '';
    addCurrentStars(restaurantId, balance);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$balance yıldız kazandın!")));
    return;
  }

  static Future<String> createPendingOrder(OrderModel order) async {
    try {
      await deletePendingOrder();

      String orderId = generateRandomId();

      DocumentReference orderRef = await _firestore.collection('pending').add({
        'order_id': orderId,
        'restaurant_id': order.restaurantId,
        'phone': Information.phone,
        'user_id': Information.userId,
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

      debugPrint("✅ Pending Order Oluşturuldu! Order ID: $orderId");

      return orderId;
    } catch (e) {
      debugPrint("❌ Pending Order oluşturulurken hata oluştu: $e");
      return "";
    }
  }
}
