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
  GoogleMapController? _mapController; // ✅ Harita kontrolcüsü

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    setState(() {
      _currentPosition = position;
    });

    // ✅ Kamera mevcut konuma gitsin
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  List<RestaurantModel> _getFilteredRestaurants() {
    List<RestaurantModel> filtered = _currentPosition == null
        ? RestaurantService().getAllRestaurants(_searchQuery)
        : RestaurantService().getAllRestaurantsWithSorted(
            _searchQuery,
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Konumlar"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition == null
                    ? LatLng(41.0082, 28.9784) // İstanbul varsayılan
                    : LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                zoom: 10,
              ),
              myLocationEnabled: _locationPermissionGranted,
              onMapCreated: (controller) {
                _mapController = controller; // ✅ Harita kontrolcüsünü kaydet
              },
              markers: Information.restaurants.map((restaurant) {
                return Marker(
                  markerId: MarkerId(restaurant.name),
                  position: LatLng(restaurant.latitude, restaurant.longitude),
                  infoWindow: InfoWindow(
                    title: restaurant.name,
                    snippet: restaurant.address,
                  ),
                );
              }).toSet(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Mağaza Ara",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              children: _getFilteredRestaurants().map((restaurant) {
                return Card(
                  elevation: 5,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      restaurant.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(restaurant.address),
                        Text("Çalışma Saatleri: ${restaurant.hours}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.directions, size: 40),
                      onPressed: () async {
                        Uri uri = Uri.parse(restaurant.link);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
