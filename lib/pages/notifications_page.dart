import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/information.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:daim/widgets/notification.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = Information.notifications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Bildirimler"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: notifications.isEmpty
          ? Center(child: Text("henüz bir bildiriminiz yok."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                return NotificationCard(
                  title: notif.title,
                  description: notif.description,
                  date: _formatDate(notif.createdAt),
                  imageUrl: notif.image,
                );
              },
            ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "bilinmeyen tarih";

    DateTime date = timestamp.toDate();
    String formattedDate = DateFormat('dd.MM.yyyy').format(date);
    return "$formattedDate tarihinde gönderildi.";
  }
}
