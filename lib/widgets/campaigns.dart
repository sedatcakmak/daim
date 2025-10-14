import 'package:daim/main.dart';
import 'package:daim/models/campaign_model.dart';
import 'package:daim/models/information.dart';
import 'package:daim/pages/all_campaigns_page.dart';
import 'package:daim/pages/campaign_details_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CampaignsWidget extends StatefulWidget {
  const CampaignsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _CampaignsWidgetState();
}

class _CampaignsWidgetState extends State<CampaignsWidget> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                "Kampanyalar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CampaignListPage()),
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
          width: 400,
          height: 300,
          child: PageView(
            controller: _controller,
            children: Information.campaigns
                .map((campaign) => _buildCampaignImage(campaign, context))
                .toList(),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: SmoothPageIndicator(
            controller: _controller,
            count: Information.campaigns.isNotEmpty
                ? Information.campaigns.length
                : 1,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 22,
              activeDotColor: AppColors.black,
              dotColor: AppColors.gray,
              spacing: 7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignImage(CampaignModel campaign, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignDetailPage(campaign: campaign),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.network(campaign.image, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
