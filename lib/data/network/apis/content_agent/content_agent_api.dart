import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';

class ContentAgentApi {
  final DioClient _dioClient;

  ContentAgentApi(this._dioClient);

  /// GET /api/projects/{projectId}/content-agents
  /// Returns { agents, stats, availableBlogPromptCount }
  Future<Map<String, dynamic>> getAgents(String projectId) async {
    final res = await _dioClient.dio.get(Endpoints.contentAgents(projectId));
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// GET /api/projects/{projectId}/content-agents/executions
  /// Query params: page, limit, status[], agentType[], startDate, endDate
  Future<Map<String, dynamic>> getExecutions(
    String projectId, {
    int page = 1,
    int limit = 10,
    List<String>? statuses,
    List<String>? agentTypes,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (statuses != null && statuses.isNotEmpty) {
      queryParams['status'] = statuses;
    }
    if (agentTypes != null && agentTypes.isNotEmpty) {
      queryParams['agentType'] = agentTypes;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final res = await _dioClient.dio.get(
      Endpoints.contentAgentExecutions(projectId),
      queryParameters: queryParams,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// GET /api/projects/{projectId}/content-profiles
  Future<List<Map<String, dynamic>>> getContentProfiles(String projectId) async {
    final res = await _dioClient.dio.get(Endpoints.contentProfiles(projectId));
    final data = res.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    // handle { data: [...] } wrapper
    final list = (data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// PATCH /api/content-agents/{agentId}
  Future<Map<String, dynamic>> updateAgent(
    String agentId, {
    bool? isActive,
    String? contentProfileId,
    int? postsPerDay,
  }) async {
    final body = <String, dynamic>{};
    if (isActive != null) body['isActive'] = isActive;
    if (contentProfileId != null) body['contentProfileId'] = contentProfileId;
    if (postsPerDay != null) body['postsPerDay'] = postsPerDay;

    final res = await _dioClient.dio.patch(
      Endpoints.updateContentAgent(agentId),
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
