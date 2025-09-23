import 'package:daim/models/restaurant_model.dart';
import 'package:daim/services/restaurant_service.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:daim/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final RestaurantService service = RestaurantService();
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  int selected = 0;
  double userLatitude = 0.0;
  double userLongitude = 0.0;

  List<String> sortingOptions = [
    "En yakından en uzağa",
    "En uzaktan en yakına",
  ];

  void _showSortingOptions() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(sortingOptions.length, (index) {
            return ListTile(
              title: Text(sortingOptions[index]),
              onTap: () {
                if (!mounted) return;
                setState(() {
                  selected = index;
                });
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, true);
                }
              },
            );
          }),
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    }
  }

  Future<bool> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (!mounted) return false;
    setState(() {
      userLatitude = position.latitude;
      userLongitude = position.longitude;
    });

    return true;
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    List<RestaurantModel> filteredRestaurants = service.getAllRestaurants(
      searchQuery,
    );

    switch (selected) {
      case 0: // En yakından en uzağa
        if (userLatitude != 0.0 && userLongitude != 0.0) {
          filteredRestaurants.sort(
            (a, b) =>
                Geolocator.distanceBetween(
                  userLatitude,
                  userLongitude,
                  a.latitude,
                  a.longitude,
                ).compareTo(
                  Geolocator.distanceBetween(
                    userLatitude,
                    userLongitude,
                    b.latitude,
                    b.longitude,
                  ),
                ),
          );
        }
        break;
      case 1: // En uzaktan en yakına
        if (userLatitude != 0.0 && userLongitude != 0.0) {
          filteredRestaurants.sort(
            (a, b) =>
                Geolocator.distanceBetween(
                  userLatitude,
                  userLongitude,
                  b.latitude,
                  b.longitude,
                ).compareTo(
                  Geolocator.distanceBetween(
                    userLatitude,
                    userLongitude,
                    a.latitude,
                    a.longitude,
                  ),
                ),
          );
        }
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Restoranlar"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Restoran ara...",
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
                                if (!mounted) return;
                                setState(() {
                                  searchController.clear();
                                  searchQuery = "";
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.sort, size: 28),
                  onPressed: _showSortingOptions,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = filteredRestaurants[index];

                return Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: RestaurantCardWidget(restaurant: restaurant),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
