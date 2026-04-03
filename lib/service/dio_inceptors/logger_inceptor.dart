
import 'package:dio/dio.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart' show TalkerDioLogger, TalkerDioLoggerSettings;
import 'package:ansicolor/ansicolor.dart';



final Interceptor loggerInterceptor = TalkerDioLogger(
  settings: TalkerDioLoggerSettings(
    requestPen: AnsiPen()..blue(bold: true),
    printRequestHeaders: true,
  ),
);