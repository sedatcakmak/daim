import 'package:daim/main.dart';
import 'package:daim/pages/all_campaigns_page.dart';
import 'package:flutter/material.dart';
import 'package:daim/models/campaign_model.dart';
import 'package:daim/models/information.dart';
import 'package:daim/pages/campaign_details_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CampaignsWidget extends StatefulWidget {
  const CampaignsWidget({super.key});

  @override
  State<CampaignsWidget> createState() => _CampaignsWidgetState();
}

class _CampaignsWidgetState extends State<CampaignsWidget> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final campaigns = Information.campaigns;
    final screenWidth = MediaQuery.of(context).size.width * 0.95;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Text(
                "Kampanyalar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CampaignListPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tümü',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: screenWidth,
          height: screenWidth, // 1:1 oran
          child: PageView.builder(
            controller: _controller,
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _buildCampaignImage(campaign),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _controller,
          count: campaigns.isNotEmpty ? campaigns.length : 1,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 22,
            activeDotColor: Colors.black,
            dotColor: Colors.grey,
            spacing: 7,
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignImage(CampaignModel campaign) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetailPage(campaign: campaign),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          campaign.image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, size: 40));
          },
        ),
      ),
    );
  }
}
