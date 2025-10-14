import 'dart:io' show Platform;
import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';

class Locations extends StatefulWidget {
  const Locations({super.key});
  @override
  LocationsState createState() => LocationsState();
}

class LocationsState extends State<Locations> {
  String _searchQuery = "";

  List<RestaurantModel> _getFilteredRestaurants() {
    return Information.restaurants.where((r) {
      return r.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _openDirections(RestaurantModel r) async {
    try {
      if (r.link.isNotEmpty) {
        final uri = Uri.tryParse(r.link);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      final lat = r.latitude;
      final lng = r.longitude;

      Uri mapUrl;

      if (Platform.isIOS) {
        mapUrl = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng');
      } else {
        mapUrl = Uri.parse(
          'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(r.name)})',
        );

        if (!await canLaunchUrl(mapUrl)) {
          mapUrl = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
          );
        }
      }

      if (await canLaunchUrl(mapUrl)) {
        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
        );
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Harita açılamadı');
        }
      }
    } catch (e) {
      debugPrint("⚠️ Yönlendirme hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Harita açılamadı. Lütfen harita uygulamanızı kontrol edin.",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _getFilteredRestaurants();

    return Scaffold(
      appBar: CustomAppBar(title: "Konumlar"),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Mağaza Ara",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: filteredRestaurants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Henüz restoran yok'
                              : 'Aradığınız restoran bulunamadı',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"$_searchQuery" için sonuç bulunamadı',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final r = filteredRestaurants[index];
                      return Card(
                        elevation: 3,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          title: Text(
                            r.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      r.address,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      r.hours,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Material(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _openDirections(r),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.directions,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Yol Tarifi',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
