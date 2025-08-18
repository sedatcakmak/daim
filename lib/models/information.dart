import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/activity_model.dart';
import 'package:daim/models/campaign_model.dart';
import 'package:daim/models/notification_model.dart';
import 'package:daim/models/order_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/models/star_model.dart';

class Information {
  static String id = "";
  static String name = "";
  static String surname = "";
  static String phone = "";
  static String city = "";
  static String userId = "";
  static Timestamp? birthday;
  static Timestamp? register;

  static RestaurantModel? restaurant;

  static List<StarModel> wallets = [];
  static List<CampaignModel> campaigns = [];
  static List<NotificationModel> notifications = [];
  static List<OrderModel> orders = [];
  static List<ActivityModel> activities = [];
  static List<RestaurantModel> restaurants = [];
}
