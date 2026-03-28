import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';

class ContentApi {
  final DioClient _dioClient;

  ContentApi(this._dioClient);

  Future<ContentResult> processContent(ContentRequest request) async {
    final endpoint = Endpoints.contentOperation(request.operation.apiPath);
    final response = await _dioClient.dio.post(
      endpoint,
      data: request.toMap(),
    );
    return ContentResult.fromMap(response.data as Map<String, dynamic>);
  }
}
