import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/campaign.dart';

class CampaignService {
  final _api = ApiClient();

  Future<List<Campaign>> getAllCampaigns({String? category}) async {
    try {
      final res = await _api.dio.get('/campaigns', queryParameters: {
        if (category != null) 'category': category,
      });
      // res.data is already the List, not {data: [...]}
      return (res.data as List).map((e) => Campaign.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException('Failed to load campaigns');
    }
  }

  Future<List<Campaign>> getMyCampaigns() async {
    try {
      final res = await _api.dio.get('/campaigns/my');
      return (res.data as List).map((e) => Campaign.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException('Failed to load your campaigns');
    }
  }

  Future<Campaign> createCampaign(FormData formData) async {
    try {
      final res = await _api.dio.post('/campaigns', data: formData);
      return Campaign.fromJson(res.data);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException('Failed to create campaign');
    }
  }

  Future<Campaign> getCampaign(int id) async {
    try {
      final res = await _api.dio.get('/campaigns/$id');
      return Campaign.fromJson(res.data);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException('Campaign not found');
    }
  }

  Future<Campaign> updateCampaign(int id, FormData formData) async {
    try {
      final res = await _api.dio.put('/campaigns/$id', data: formData);
      return Campaign.fromJson(res.data);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException('Failed to update campaign');
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await _api.dio.patch('/campaigns/$id/status', data: {'status': status});
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException('Failed to update status');
    }
  }
}