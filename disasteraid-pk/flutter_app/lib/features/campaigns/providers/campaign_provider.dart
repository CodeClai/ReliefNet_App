import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign.dart';
import '../services/campaign_service.dart';

final campaignServiceProvider = Provider((ref) => CampaignService());

final allCampaignsProvider = FutureProvider.family<List<Campaign>, String?>((ref, category) async {
  final service = ref.watch(campaignServiceProvider);
  return service.getAllCampaigns(category: category);
});

final myCampaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  final service = ref.watch(campaignServiceProvider);
  return service.getMyCampaigns();
});
