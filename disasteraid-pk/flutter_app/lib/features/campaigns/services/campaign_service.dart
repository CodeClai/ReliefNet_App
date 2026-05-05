import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/campaign.dart';

class CampaignService {
  final _api = ApiClient();

  Future<List<Campaign>> getAllCampaigns({String? category}) async {
    final res = await _api.dio.get('/campaigns', queryParameters: {
      if (category!= null) 'category': category,
    });
    return (res.data['data'] as List).map((e) => Campaign.fromJson(e)).toList();
  }

  Future<List<Campaign>> getMyCampaigns() async {
    final res = await _api.dio.get('/ngos/campaigns');
    return (res.data['data'] as List).map((e) => Campaign.fromJson(e)).toList();
  }

  Future<Campaign> createCampaign(FormData formData) async {
    final res = await _api.dio.post('/campaigns', data: formData);
    return Campaign.fromJson(res.data['data']);
  }

  Future<Campaign> getCampaign(int id) async {
    final res = await _api.dio.get('/campaigns/$id');
    return Campaign.fromJson(res.data['data']);
  }
}