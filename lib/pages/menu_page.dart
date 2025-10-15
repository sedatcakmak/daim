import 'dart:io';

import 'package:daim/main.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/star_model.dart';
import 'package:flutter/material.dart';
import 'package:daim/models/menu_item_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/pages/order_items_page.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatefulWidget {
  final RestaurantModel restaurant;

  const MenuPage({super.key, required this.restaurant});

  @override
  State<StatefulWidget> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Map<MenuItemModel, int> _order = {};
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  late StarModel wallet;

  @override
  Widget build(BuildContext context) {
    wallet = Information.wallets.firstWhere(
      (element) => element.restaurantId == widget.restaurant.id,
      orElse: () => StarModel(
        restaurantId: widget.restaurant.id,
        totalAmount: 0,
        currentAmount: 0,
      ),
    );

    Map<String, List<MenuItemModel>> categorizedItems = {};
    for (var item in widget.restaurant.menu) {
      if (item.price > 0 &&
          (searchQuery.isEmpty ||
              item.name.toLowerCase().contains(searchQuery.toLowerCase()))) {
        categorizedItems.putIfAbsent(item.category, () => []).add(item);
      }
    }

    return Scaffold(
      appBar: CustomAppBar(title: widget.restaurant.name),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Column(
        children: [
          _buildRestaurantInfoCard(), // 🌟 En üste restoran bilgileri geldi
          // 🔎 Ürün Arama Alanı
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Ürün ara...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                bottom:
                    kFloatingActionButtonMargin +
                    56 +
                    MediaQuery.of(context).padding.bottom,
              ),
              children: [
                for (var category in categorizedItems.keys)
                  _buildCategorySection(category, categorizedItems[category]!),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 0,
            child: Icon(
              Icons.shopping_cart_checkout,
              size: 30,
              color: Colors.black,
            ),
            onPressed: () async {
              if (_order.isNotEmpty) {
                bool? updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderPage(restaurant: widget.restaurant, order: _order),
                  ),
                );

                if (updated == true) {
                  setState(() {});
                }
              } else {
                _showMessage("Hiç ürün eklemedin!");
              }
            },
          ),
          if (_order.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  _order.values.fold(0, (sum, item) => sum + item).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 📌 Kategori Başlığı ve Ürün Listesi
  Widget _buildCategorySection(String title, List<MenuItemModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => _buildMenuItem(item)),
      ],
    );
  }

  /// 🍽️ Menü Öğesi Kartı (Ekleme Kontrolleri Eklendi)
  Widget _buildMenuItem(MenuItemModel item) {
    final int quantity = _order[item] ?? 0;
    final bool canAddMore = quantity < item.maximum;

    // 📌 Siparişteki toplam yıldız harcaması hesaplanıyor
    int totalUsed = _order.entries
        .where((entry) => entry.key.price > 0)
        .fold(0, (sum, entry) => sum + (entry.key.price * entry.value));

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${item.price} ⭐",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuantityButton(
                      Icons.remove,
                      () => quantity > 0 ? _removeItem(item) : null,
                      isEnabled: quantity > 0,
                    ),
                    Text("$quantity", style: TextStyle(fontSize: 16)),
                    _buildQuantityButton(Icons.add, () {
                      if (!canAddMore) {
                        _showMessage("Bu üründen daha fazla ekleyemezsin!");
                        return;
                      }
                      if (item.price > 0 &&
                          (totalUsed + item.price) > wallet.currentAmount) {
                        _showMessage("Yeterli yıldızın yok!");
                        return;
                      }
                      _addItem(item);
                    }, isEnabled: canAddMore),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback? onPressed, {
    bool isEnabled = true,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 32,
        color: isEnabled ? AppColors.black : AppColors.gray,
      ),
      onPressed: onPressed,
      constraints: BoxConstraints(),
      padding: EdgeInsets.zero,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addItem(MenuItemModel item) {
    setState(() {
      if ((_order[item] ?? 0) < item.maximum) {
        _order[item] = (_order[item] ?? 0) + 1;
      }
    });
  }

  void _removeItem(MenuItemModel item) {
    setState(() {
      if (_order[item] != null && _order[item]! > 0) {
        _order[item] = _order[item]! - 1;
        if (_order[item] == 0) {
          _order.remove(item);
        }
      }
    });
  }

  Widget _buildRestaurantInfoCard() {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Çalışma Saatleri: ${widget.restaurant.hours}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final Uri uri = Uri.parse(widget.restaurant.link);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Bağlantı açılamadı")),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 18, color: AppColors.black),
                      SizedBox(width: 6),
                      Text(
                        "İşletme Menüsünü Görüntüle",
                        style: TextStyle(color: AppColors.black, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final latitude = widget.restaurant.latitude;
                    final longitude = widget.restaurant.longitude;

                    final googleUrl =
                        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                    final appleUrl =
                        'http://maps.apple.com/?ll=$latitude,$longitude';

                    if (Platform.isAndroid) {
                      final Uri geoUri = Uri.parse(
                        'geo:$latitude,$longitude?q=$latitude,$longitude',
                      );
                      if (await canLaunchUrl(geoUri)) {
                        await launchUrl(
                          geoUri,
                          mode: LaunchMode.externalApplication,
                        );
                        return;
                      }
                    }

                    if (Platform.isIOS) {
                      final Uri appleUri = Uri.parse(appleUrl);
                      if (await canLaunchUrl(appleUri)) {
                        await launchUrl(
                          appleUri,
                          mode: LaunchMode.externalApplication,
                        );
                        return;
                      }
                    }

                    final Uri googleUri = Uri.parse(googleUrl);
                    if (await canLaunchUrl(googleUri)) {
                      await launchUrl(
                        googleUri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 18, color: AppColors.black),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.restaurant.address,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.money, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Her siparişten ${widget.restaurant.stars} ⭐ kazanırsın.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_half, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Harcanabilen Yıldız: ${wallet.currentAmount} ⭐",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Toplam Yıldız: ${wallet.totalAmount} ⭐",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 📌 Restoran Bilgileri Kartı
