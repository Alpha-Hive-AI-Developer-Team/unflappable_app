// endpoint.dart
library;

import 'package:unflappable/service/endpoint/endpoint.dart';

part 'authentication_endpoints.dart';



abstract final class EndPoints {
  static const String baseUrl = 'https://dev.pawapp.net';
  static _Authentication get auth => _Authentication(apiBaseUrl: baseUrl);
  
}




