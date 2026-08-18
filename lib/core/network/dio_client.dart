import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/auth/auth_token_provider.dart';
import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_starter/core/network/auth_interceptor.dart';
import 'package:flutter_starter/core/network/safe_network_log_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  dio.interceptors.add(AuthInterceptor(dio, ref.watch(authTokenProvider)));

  if (AppConfig.instance.enableLogging) {
    dio.interceptors.add(SafeNetworkLogInterceptor(debugPrint));
  }

  return dio;
});
