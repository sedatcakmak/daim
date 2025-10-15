import 'package:daim/pages/campaign_details_page.dart';
import 'package:flutter/material.dart';
import 'package:daim/models/campaign_model.dart';
import 'package:daim/models/information.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class CampaignListPage extends StatelessWidget {
  const CampaignListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Kampanyalar"),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: _CampaignListView(),
      ),
    );
  }
}

class _CampaignListView extends StatelessWidget {
  const _CampaignListView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: Information.campaigns.length,
      padding: EdgeInsets.fromLTRB(12, 12, 12, 50),
      itemBuilder: (context, index) {
        CampaignModel campaign = Information.campaigns[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampaignDetailPage(campaign: campaign),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    campaign.image,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
