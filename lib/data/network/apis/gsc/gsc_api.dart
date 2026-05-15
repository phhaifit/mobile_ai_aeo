import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';

/// API client for Google Search Console endpoints.
class GscApi {
  final DioClient _dioClient;

  GscApi(this._dioClient);

  /// Connect Google Search Console via OAuth.
  /// Post code and PKCE parameters to backend.
  Future<Map<String, dynamic>> connectGsc(Map<String, dynamic> data) async {
    final res = await _dioClient.dio.post(
      Endpoints.gscConnect,
      data: data,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Get GSC connection status for a project.
  Future<Map<String, dynamic>> getStatus(String projectId) async {
    final res = await _dioClient.dio.get(
      Endpoints.gscStatus(projectId),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// List accessible GSC properties for a connected project.
  Future<List<Map<String, dynamic>>> getSites(String projectId) async {
    final res = await _dioClient.dio.get(
      Endpoints.gscSites(projectId),
    );
    final list = res.data as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Get the GSC property linked to a project.
  /// Returns null if no property is linked.
  Future<Map<String, dynamic>?> getLinkedSite(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.gscLinkedSite(projectId),
      );
      if (res.data != null && res.data.toString().isNotEmpty) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } catch (e) {
      // Backend returns 404 or empty if not linked or other errors
      return null;
    }
  }

  /// Link a GSC property to a project.
  Future<Map<String, dynamic>> linkSite(Map<String, dynamic> data) async {
    final res = await _dioClient.dio.post(
      Endpoints.gscLink,
      data: data,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Disconnect Google Search Console for a project.
  Future<Map<String, dynamic>> disconnect(String projectId) async {
    final res = await _dioClient.dio.delete(
      Endpoints.gscDisconnect(projectId),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
