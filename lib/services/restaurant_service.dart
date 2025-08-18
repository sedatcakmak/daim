import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantService {
  List<RestaurantModel> getAllRestaurants(String search) {
    List<RestaurantModel> restaurants = Information.restaurants;
    String city = Information.city;

    if (search.isEmpty) {
      return restaurants
          .where((restaurant) =>
              restaurant.address.toLowerCase().contains(city.toLowerCase()))
          .toList();
    }

    return restaurants
        .where((restaurant) =>
            (restaurant.name.toLowerCase().contains(search.toLowerCase()) &&
                restaurant.address.toLowerCase().contains(city.toLowerCase())))
        .toList();
  }

  List<RestaurantModel> getAllRestaurantsWithSorted(
      String search, double userLatitude, double userLongitude) {
    List<RestaurantModel> filteredRestaurants = getAllRestaurants(search);

    filteredRestaurants.sort((a, b) => Geolocator.distanceBetween(
            userLatitude, userLongitude, a.latitude, a.longitude)
        .compareTo(Geolocator.distanceBetween(
            userLatitude, userLongitude, b.latitude, b.longitude)));
    return filteredRestaurants;
  }
}
