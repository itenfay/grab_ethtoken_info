//
// Created by dyf on 2018/9/3.
// Copyright (c) 2018 dyf.
//

import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

export 'package:dio/dio.dart';
export 'dart:io';

// ===============================================
// Response callbacks the http info.
// ===============================================

/// When data is received, it is called.
typedef void OnResponseSuccess(Response response);

/// When the request fails, it is called.
typedef void OnResponseError(DioError error);


/// Defines a HTTP tool to receive data, download and upload files, etc.
class HttpUtils {
  /// Request base url, it can contain sub path, like: "https://www.google.com/api/".
  String baseUrl;

  /// Timeout in seconds for opening url.
  int connectTimeout;

  /// This is not the receiving time limitation, in seconds.
  int receiveTimeout;

  /// Http request headers.
  Map<String, dynamic> headers;

  /// The request Content-Type. The default value is [ContentType.json].
  /// If you want to encode request body with "application/x-www-form-urlencoded",
  /// you can set `ContentType.parse("application/x-www-form-urlencoded")`, and [Dio]
  /// will automatically encode the request body.
  ContentType contentType;

  /// Cookie manager for http requests。Learn more details about
  /// CookieJar please refer to [cookie_jar](https://github.com/flutterchina/cookie_jar)
  CookieJar cookieJar;

  /// A powerful Http client.
  Dio _dio;

  /// You can cancel a request by using a cancel token.
  CancelToken _cancelToken;

  /// Each Dio instance has a interceptor by which you can intercept requests or responses before they are
  /// handled by `then` or `catchError`. the [interceptor] field
  /// contains a [RequestInterceptor] and a [ResponseInterceptor] instance.
  Interceptor get interceptor => _dio.interceptor;

  /// If the `url` starts with "http(s)", the `baseURL` will be ignored, otherwise,
  /// it will be combined and then resolved with the baseUrl.
  String url = "";

  /// Success response callback.
  OnResponseSuccess _onSuccess;

  /// Failure response callback.
  OnResponseError _onError;

  /// Constructor
  HttpUtils({
    this.baseUrl,
    this.connectTimeout: 0,
    this.receiveTimeout: 0,
    this.headers,
    this.contentType,
    this.cookieJar
  });

  /// Named constructor
  HttpUtils.config({
    String baseUrl,
    int connectTimeout: 0,
    int receiveTimeout: 0,
    Map<String, dynamic> headers,
    ContentType contentType,
    CookieJar cookieJar
  }) : connectTimeout = 0,
       receiveTimeout = 0 {
    if (baseUrl != null) {
      this.baseUrl = baseUrl;
    }
    if (connectTimeout > 0) {
      this.connectTimeout = connectTimeout;
    }
    if (receiveTimeout > 0) {
      this.receiveTimeout = receiveTimeout;
    }
    if (headers != null) {
      this.headers = headers;
    }
    if (contentType != null) {
      this.contentType = contentType;
    }
    if (cookieJar != null) {
      this.cookieJar = cookieJar;
    }
  }

  void _init() {
    _cancelToken = new CancelToken();
    // Create Dio instance with default [Options].
    _dio = new Dio();
  }

  void _mergeOptions() {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }
    if (connectTimeout > 0) {
      _dio.options.connectTimeout = 1000 * connectTimeout;
    }
    if (receiveTimeout > 0) {
      _dio.options.receiveTimeout = 1000 * receiveTimeout;
    }
    if (headers != null) {
      _dio.options.headers = headers;
    }
    if (contentType != null) {
      _dio.options.contentType = contentType;
    }
  }

  String _checkPath(String path) {
    if (baseUrl != null && baseUrl.isNotEmpty && path.contains(baseUrl)) {
      url = path;
    } else {
      url = (baseUrl ?? "") + path;
    }
    return url;
  }

  void _checkCookie() {
    if (cookieJar != null) {
      _dio.cookieJar = cookieJar;
    }
  }

  /// Callback to listen the http info.
  void listen(OnResponseSuccess onSuccess, OnResponseError onError) {
    _onSuccess = onSuccess;
    _onError = onError;
  }

  /// Handy method to make http GET request.
  void get(String path, {data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);
      var response;
      if (data != null) {
        response = await _dio.get(url, data: data, cancelToken: _cancelToken);
      } else {
        response = await _dio.get(url, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Handy method to make http POST request.
  void post(String path, {data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);
      var response;
      if (data != null) {
        response = await _dio.post(url, data: data, cancelToken: _cancelToken);
      } else {
        response = await _dio.post(url, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Handy method to make http PUT request.
  void put(String path, {data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);
      var response;
      if (data != null) {
        response = await _dio.put(url, data: data, cancelToken: _cancelToken);
      } else {
        response = await _dio.put(url, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Handy method to make http HEAD request.
  void head(String path, {data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);

      var response;
      if (data != null) {
        response = await _dio.head(url, data: data, cancelToken: _cancelToken);
      } else {
        response = await _dio.head(url, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Handy method to make http DELETE request.
  void delete(String path, {data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);

      var response;
      if (data != null) {
        response = await _dio.delete(url, data: data, cancelToken: _cancelToken);
      } else {
        response = await _dio.delete(url, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Handy method to make http PATCH request.
  void patch(String path, {data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);

      var response;
      if (data != null) {
        response = await _dio.patch(url, data: data, cancelToken: _cancelToken);
      } else {
        response = await _dio.patch(url, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Download the file and save it in local. The default http method is "GET".
  void download(String path, String savePath, {OnDownloadProgress onProgress, data}) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);

      var response;
      if (data != null) {
        response = await _dio.download(url, savePath,
            onProgress: onProgress, cancelToken: _cancelToken, data: data);
      } else {
        response = await _dio.download(url, savePath,
            onProgress: onProgress, cancelToken: _cancelToken);
      }

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Handy method to make http POST request.
  /// [UploadFileInfo] Describes the info of file to upload,
  /// e.g.: UploadFileInfo(new File("./example/upload.txt"), "upload.txt").
  void upload(String path, Map<String, dynamic> data) async {
    try {
      _init();
      _mergeOptions();
      _checkCookie();

      var url = _checkPath(path);

      FormData formData = new FormData.from(data);
      var response =
          await _dio.post(url, data: formData, cancelToken: _cancelToken);

      if (_onSuccess != null) _onSuccess(response);
    } on DioError catch (e) {
      if (_onError != null) _onError(e);
    }
  }

  /// Cancel the request.
  void cancel() {
    _cancelToken.cancel();
  }
}
