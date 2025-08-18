class CampaignModel {
  final String id;
  final String title;
  final String description;
  final String image;

  CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory CampaignModel.fromMap(Map<String, dynamic> data, String id) {
    return CampaignModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
