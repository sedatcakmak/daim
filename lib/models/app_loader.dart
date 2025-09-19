import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/main.dart';
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
import 'package:daim/pages/reward_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      print("🔥 Çalışan Hata: $e");
    }
  }

  static Future<RestaurantModel?> _loadRestaurantById(
    String restaurantId,
  ) async {
    print("bilgi: restaurant yükleniyor ($restaurantId)");

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

  static Future<void> removeStarsByPhone(String phone, int amount) async {
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

    await _updateWalletAndActivity(userDocRef, amount);
  }

  static Future<void> _updateWalletAndActivity(
    DocumentReference userDocRef,
    int amount,
  ) async {
    final walletQuery = await userDocRef
        .collection('wallets')
        .where('restaurant_id', isEqualTo: Information.restaurant!.id)
        .limit(1)
        .get();

    if (walletQuery.docs.isEmpty) throw Exception("❌ Wallet bulunamadı");

    final walletRef = walletQuery.docs.first.reference;

    await addActivity(
      amount: amount,
      message: "${Information.restaurant!.name} için $amount yıldız harcadın!",
      type: "spent_stars",
    );

    await walletRef.update({'current_amount': FieldValue.increment(-amount)});
    print("✅ $amount yıldız başarıyla harcandı");
  }

  static Future<void> handleDeepLink(String link) async {
    print("🎯 Deep link geldi: $link");

    final uri = Uri.parse(link);

    if (uri.host == 'reward') {
      final code = uri.queryParameters['code'];
      print("📦 Kod alındı: $code");

      if (code != null && Information.userId.isNotEmpty) {
        String newCode = "${Information.userId}-$code";
        await _verifyQrCode(newCode);
      }
    }
  }

  static Future<void> _verifyQrCode(String fullCode) async {
    final uri = Uri.parse(
      "https://api.daimapp.com/verify_qr",
    ).replace(queryParameters: {"code": fullCode});

    print("📤 İstek gönderildi: $uri");

    try {
      final response = await http.get(uri);
      print("📥 Yanıt: ${response.body}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result == true) {
          _navigateToReward("✅ Kod doğrulandı ve yıldız verildi!");
        } else {
          _navigateToReward("❌ Kod geçersiz veya süresi dolmuş.");
        }
      } else {
        _navigateToReward("⚠️ Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      _navigateToReward("⚠️ Hata: $e");
    }
  }

  static void _navigateToReward(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RewardPage(message: message)),
        (route) => false,
      );
    });
  }

  static Future<void> checkQR(BuildContext context, String code) async {
    PendingOrderModel? order = await getPendingOrderById(code);
    if (order != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmployeeOrderPage(order: order)),
      );
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Kod bulunamadı!")));
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
        print("⚠️ Order içinde phone alanı boş");
      }

      return order;
    } catch (e) {
      print("❌ Sipariş getirilirken hata oluştu: $e");
      return null;
    }
  }

  static Future<void> loadAllData(String? phone) async {
    if (phone == null) return;
    Information.phone = phone;

    await Future.wait([_loadUserData()]);

    final futures = [
      _loadRestaurants(),
      _loadCampaigns(),
      _loadOrders(),
      _loadActivities(),
      _loadStars(),
      _loadNotifications(),
    ];

    await Future.wait(futures);
  }

  static Future<void> _loadUserData() async {
    print("bilgi: user data");

    final qs = await _firestore
        .collection('users')
        .where('phone', isEqualTo: Information.phone)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) {
      print("❌ User bulunamadı ");
      return;
    }

    final userDoc = qs.docs.first;
    final data = userDoc.data();

    Information.id = userDoc.id;
    Information.name = data['name'] ?? '';
    Information.surname = data['surname'] ?? '';
    Information.city = data['city'] ?? '';
    Information.phone = data['phone'] ?? '';
    Information.userId = data['user_id'] ?? '';
    Information.badges = List<String>.from(data['badges'] ?? []);

    print("bilgi: user data doğrulandı");
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
        amount: order.price,
        message: "${Information.restaurant!.name} için sipariş oluşturdun!",
        type: "order",
      );
    } catch (e) {
      print("❌ Hata: $e");
    }
  }

  static Future<void> _loadOrders() async {
    print("bilgi: orders");

    try {
      QuerySnapshot orderDocs = await _firestore
          .collection('orders')
          .where('phone', isEqualTo: Information.phone)
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
          }).toList(),
        );

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
      QuerySnapshot restaurantDocs = await _firestore
          .collection('restaurants')
          .get();

      Information.restaurants = await Future.wait(
        restaurantDocs.docs.map((doc) async {
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
      );

      print(
        "bilgi: restaurants doğrulandı (${Information.restaurants.length} restoran)",
      );
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

  static Future<void> _loadStars() async {
    print("ℹ️ Wallets yükleniyor...");

    try {
      // önce phone eşleşen kullanıcı belgesini bul
      final qs = await _firestore
          .collection('users')
          .where('phone', isEqualTo: Information.phone)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        print("⚠️ Böyle bir kullanıcı bulunamadı");
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

      print("📌 Wallets belgesi alındı (${walletsSnapshot.docs.length} tane)");

      if (walletsSnapshot.docs.isEmpty) {
        print("⚠️ Kullanıcının hiç yıldız kaydı yok.");
      }

      final wallets = walletsSnapshot.docs.map((doc) {
        final data = doc.data();
        print("🔍 Veri: $data");
        return StarModel.fromMap(data, doc.id);
      }).toList();

      Information.wallets = wallets;
      print(
        "✅ Wallets başarıyla yüklendi (${Information.wallets.length} adet).",
      );
    } catch (e) {
      print("❌ Stars yüklenirken hata oluştu: $e");
    }
  }

  static Future<void> addActivity({
    required int amount,
    required String message,
    required String type,
  }) async {
    try {
      final qs = await _firestore
          .collection('users')
          .where('phone', isEqualTo: Information.phone)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        print("❌ Kullanıcı bulunamadı");
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

      print("✅ Activity başarıyla eklendi.");
    } catch (e) {
      print("❌ Activity eklenirken hata oluştu: $e");
    }
  }

  static Future<void> _loadActivities() async {
    print("bilgi: activities");

    final qs = await _firestore
        .collection('users')
        .where('phone', isEqualTo: Information.phone)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) {
      print("❌ User bulunamadı");
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

    print("bilgi: activities doğrulandı (${activities.length} aktivite)");
  }

  /// **Kampanyaları Firestore'dan yükler**
  static Future<void> _loadCampaigns() async {
    print("bilgi: campaigns");
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
      print("bilgi: campaigns doğrulandı");
    } catch (e) {
      print("bilgi: campaigns doğrulanmadı");
    }
  }

  static Future<void> _loadNotifications() async {
    print("ℹ️ Notifications yükleniyor...");

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
        print("⚠️ Kullanıcı bulunamadı (phone=).");
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

      print(
        "✅ Notifications yüklendi (${Information.notifications.length} adet)",
      );
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
