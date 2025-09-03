import 'dart:convert';
import 'dart:developer';

import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class ReportApiservice {
  static const String reporturl = Constants.reporturl;
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<List<dynamic>> fetchReports() async {
    final response = await http.get(Uri.parse(reporturl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Map<String, dynamic>> fetchReportById(String id) async {
    final response = await http.get(Uri.parse('$reporturl/$id'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      log('Response body: ${response.body}');
      throw Exception('Failed to load post');
    }
  }

  Future<bool> reportPost({
    String? userId,
    String? postId,
    String? reason,
  }) async {
    final body = {"postId": postId, "userId": userId, "title": reason ?? ""};

    log("Submitting feedback with body: $body");

    try {
      final response = await http.post(
        Uri.parse(reporturl),
        headers: _headers,
        body: jsonEncode(body),
      );

      log("Response status: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Report submitted successfully.");
        return true;
      } else {
        log("Failed to submit report: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      log("Exception while submitting report: $e");
      return false;
    } finally {
      log("reportPost execution completed.");
    }
  }

  Future<bool> deleteReportById(String reportId) async {
    try {
      final response = await http.delete(
        Uri.parse('$reporturl/$reportId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        log(
          "Failed to delete report: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      log("Exception in deleteReportById: $e");
      return false;
    } finally {
      log("deleteReportById execution completed.");
    }
  }
}
