


import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_inceptors/dio_inceptors.dart';

abstract final class DioHelper {
  static late Dio _dio;
  static late Dio _dioWithoutToken;

  static void init() {
    _dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
        contentType: 'application/json',
        headers: {},
      ),
    )..interceptors.addAll(dioInterceptoprs);

    _dioWithoutToken = Dio(
      BaseOptions(
        // receiveDataWhenStatusError: true,
        contentType: 'application/json',
        headers: {
        },
      ),
    )..interceptors.addAll(dioInterceptoprsWithoutToken);
  }

  static Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      endPoint,
      queryParameters: queryParameters,
    );
  }
  static Future<Response> getDataWithoutAuth({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dioWithoutToken.get(
      endPoint,
      queryParameters: queryParameters,
    );
  }
  static Future<Response> postData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dio.post(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }

  static Future<Response> postWithOutAuthData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dioWithoutToken.post(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }

  static Future<Response> putData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dio.put(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }

  static Future<Response> patchData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dio.patch(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }

  static Future<Response> deleteData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    return _dio.delete(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }
  // static Future<Response> downloadFile({
  //   required String endPoint,
  //   required String fileName,
  // }) async {
  //   return _dio.download(endPoint, fileName);
  // }
  // static Future<bool> uploadFiles({
  //   required List<XFile> files,
  //   required String endPoint,
  // }) async {
  //   try {
  //     List<Map<String, Uint8List>> filesAsBytes = await Future.wait(
  //       files.map((file) async {
  //         return {
  //           file.name: await file.readAsBytes(),
  //         };
  //       }).toList(),
  //     );

  //     final formData = FormData.fromMap(
  //       {
  //         'profile_picture': filesAsBytes
  //             .map(
  //               (file) => MultipartFile.fromBytes(
  //                 file.values.first,
  //                 filename: file.keys.first,
  //                 contentType: MediaType.parse(
  //                   lookupMimeType(file.keys.first) ??
  //                       'application/octet-stream',
  //                 ),
  //               ),
  //             )
  //             .toList(),
  //       },
  //     );

  //     var response = await putData(endPoint: endPoint, data: formData);
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //     return false;
  //   }
  // }

  // static Future<bool> uploadPlatformFiles({
  //   required PlatformFile file,
  //   required String endPoint,
  // }) async {
  //   try {
  //     // Use file.bytes directly, as it is already a Uint8List
  //     final fileBytes = file.bytes;

  //     if (fileBytes == null) {
  //       log("File bytes are null. Unable to upload.");
  //       return false;
  //     }

  //     final formData = FormData.fromMap({
  //       'file': MultipartFile.fromBytes(
  //         fileBytes,
  //         filename: file.name,
  //         contentType: MediaType.parse(
  //           lookupMimeType(file.name) ?? 'application/octet-stream',
  //         ),
  //       ),
  //     });

  //     // Initialize Dio and make the POST request

  //     final response = await postData(endPoint: endPoint, data: formData);

  //     // Check for a successful response
  //     if (response.statusCode == 200) {
  //       log("File uploaded successfully: ${response.data}");
  //       return true;
  //     } else {
  //       log("File upload failed with status code: ${response.statusCode}");
  //       return false;
  //     }
  //   } catch (e) {
  //     log("Error during file upload: $e");
  //     return false;
  //   }
  // }

  static Future<Response> postAuthData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dioWithoutToken.post(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }
}
