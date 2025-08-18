import 'package:flutter/material.dart';
import 'package:daim/models/information.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:intl/intl.dart';

class AccountActivities extends StatelessWidget {
  const AccountActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Hesap Hareketleri"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Information.activities.isEmpty
          ? Center(
              child: Text(
                textAlign: TextAlign.center,
                "hesap hareketi bulunamadı.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(5),
              itemCount: Information.activities.length,
              itemBuilder: (context, index) {
                final activity = Information.activities[index];

                final activityStyle = activityStyles[activity.type] ??
                    ActivityStyle(
                      type: "?",
                      icon: Icons.help_outline,
                      color: Colors.grey,
                    );

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(
                        activityStyle.icon,
                        color: activityStyle.color,
                      ),
                      title: Text(
                        activity.message,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(activity.createdAt.toDate()),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        "${activity.amount} ${activityStyle.type}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: activityStyle.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ActivityStyle {
  final IconData icon;
  final Color color;
  final String type;

  ActivityStyle({required this.type, required this.icon, required this.color});
}

final Map<String, ActivityStyle> activityStyles = {
  "earned_stars":
      ActivityStyle(type: "⭐", icon: Icons.star, color: Colors.green),
  "spent_stars": ActivityStyle(type: "⭐", icon: Icons.star, color: Colors.red),
  "order":
      ActivityStyle(type: "⭐", icon: Icons.shopping_bag, color: Colors.blue),
};
