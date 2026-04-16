import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class ProgressService {
  static Future<Response> getProgress() {
    return DioHelper.getData(endPoint: EndPoints.progress.overview);
  }
}
