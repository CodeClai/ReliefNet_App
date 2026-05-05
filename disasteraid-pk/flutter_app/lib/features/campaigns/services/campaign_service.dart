import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/campaign.dart';

class CampaignService {
  final _dio = ApiClient.dio;

  Future<List<Campaign>> getAllCampaigns({String? category}) async {
    final res = await _dio.get('/api/campaigns', queryParameters: {
      if (category!= null) 'category': category,
    });
    return (res.data['data'] as List).map((e) => Campaign.fromJson(e)).toList();
  }

  Future<List<Campaign>> getMyCampaigns() async {
    final res = await _dio.get('/api/campaigns/my');
    return (res.data['data'] as List).map((e) => Campaign.fromJson(e)).toList();
  }

  Future<Campaign> createCampaign(Map<String, dynamic> data) async {
    final res = await _dio.post('/api/campaigns', data: data);
    return Campaign.fromJson(res.data['data']);
  }

  Future<Campaign> getCampaign(int id) async {
    final res = await _dio.get('/api/campaigns/$id');
    return Campaign.fromJson(res.data['data']);
  }
}
