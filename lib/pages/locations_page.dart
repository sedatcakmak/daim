import 'dart:io' show Platform;
import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/services/restaurant_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';

class Locations extends StatefulWidget {
  const Locations({super.key});
  @override
  LocationsState createState() => LocationsState();
}

class LocationsState extends State<Locations> {
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  String _searchQuery = "";
  GoogleMapController? _mapController;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensurePermissionFlow();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _ensurePermissionFlow() async {
    try {
      // (İsteğe bağlı) permission_handler ile genel izin isteme
      final phStatus = await Permission.locationWhenInUse.request();

      // Geolocator’ın kendi izin kontrolü
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Konum servisi kapalı.")));
        setState(() => _locationPermissionGranted = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !phStatus.isGranted) {
        if (!mounted) return;
        setState(() => _locationPermissionGranted = false);
        return;
      }

      if (!mounted) return;
      setState(() => _locationPermissionGranted = true);
      _unawaitedGetCurrentLocation();
    } catch (e) {
      debugPrint("❌ İzin akışı hatası: $e");
    }
  }

  void _unawaitedGetCurrentLocation() {
    _getCurrentLocation().catchError((e) {
      debugPrint("Konum alınamadı (async): $e");
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Eğer izin yoksa veya reddedildiyse, direkt çık
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Konum izni verilmedi, en yakın mağazaları liste olarak görebilirsiniz.",
              ),
            ),
          );
        }
        return;
      }

      // Önce son bilinen konum
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        setState(() => _currentPosition = last);
        if (_mapReady && _mapController != null) {
          try {
            await Future.delayed(const Duration(milliseconds: 300));
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(last.latitude, last.longitude),
                15,
              ),
            );
          } catch (e) {
            debugPrint("⚠️ Kamera animasyonu başarısız: $e");
          }
        }
      }

      // Güncel konumu almayı dene (izin varsa)
      final settings = LocationSettings(
        accuracy: Platform.isIOS ? LocationAccuracy.low : LocationAccuracy.high,
      );

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );

      if (!mounted) return;
      setState(() => _currentPosition = pos);

      if (_mapReady && _mapController != null) {
        try {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15),
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("❌ Konum alınamadı: $e");
    }
  }

  List<RestaurantModel> _getFilteredRestaurants() {
    if (_currentPosition == null) {
      return RestaurantService().getAllRestaurants(_searchQuery);
    }
    return RestaurantService().getAllRestaurantsWithSorted(
      _searchQuery,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
  }

  Future<void> _openDirections(RestaurantModel r) async {
    // Önce modeldeki link uygunsa onu dene
    if (r.link.isNotEmpty) {
      final uri = Uri.tryParse(r.link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Yönlendirme açılamadı.")));
      }
    }
    // Fallback: platforma göre harita aç
    final lat = r.latitude;
    final lng = r.longitude;
    final fallback = Platform.isIOS
        ? Uri.parse('http://maps.apple.com/?daddr=$lat,$lng')
        : Uri.parse(
            'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(r.name)})',
          );

    if (await canLaunchUrl(fallback)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("⚠️ Yönlendirme açılamadı");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Yönlendirme açılamadı.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition == null
        ? const LatLng(38.69391896572648, 35.54589288729903)
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Konumlar"),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 10,
              ),
              myLocationButtonEnabled:
                  _locationPermissionGranted && _currentPosition != null,
              myLocationEnabled:
                  _locationPermissionGranted && _currentPosition != null,
              onMapCreated: (controller) async {
                _mapController = controller;
                _mapReady = true;
                // Harita hazır olduğunda konumu aldıysak merkeze getir
                if (_currentPosition != null) {
                  await _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      15,
                    ),
                  );
                }
              },
              markers: Information.restaurants.map((r) {
                return Marker(
                  markerId: MarkerId(r.id), // benzersiz id
                  position: LatLng(r.latitude, r.longitude),
                  infoWindow: InfoWindow(title: r.name, snippet: r.address),
                );
              }).toSet(),
            ),
          ),
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
            flex: 3,
            child: ListView.builder(
              itemCount: _getFilteredRestaurants().length,
              itemBuilder: (context, index) {
                final r = _getFilteredRestaurants()[index];
                return Card(
                  elevation: 5,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      r.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.address),
                        Text("Çalışma Saatleri: ${r.hours}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.directions, size: 40),
                      onPressed: () => _openDirections(r),
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
