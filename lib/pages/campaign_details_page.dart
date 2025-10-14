import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:daim/models/campaign_model.dart';

class CampaignDetailPage extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignDetailPage({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: campaign.title),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  campaign.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                campaign.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(campaign.description, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
