import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OmdbService {
  // Ganti dengan API Key milik Anda dari email OMDb
  static const String _apiKey = '980f0793';

  static Future<List<Map<String, dynamic>>> searchMedia(String query, {String? type}) async {
    if (query.trim().isEmpty) return [];

    // 's' = parameter pencarian judul
    // 'type' = opsional ('movie', 'series', atau null untuk semua)
    var urlString = 'https://www.omdbapi.com/?apikey=$_apiKey&s=${Uri.encodeComponent(query)}';
    if (type != null && type.isNotEmpty) {
      urlString += '&type=$type';
    }

    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // OMDb mengembalikan Response: "True" jika data ditemukan
        if (data['Response'] == 'True') {
          final searchList = data['Search'] as List;
          return searchList.map((item) {
            return {
              'id': item['imdbID'],
              'title': item['Title'] ?? 'Tanpa Judul',
              'type': item['Type'] == 'movie' ? 'Film' : 'Serial',
              'year': item['Year'] ?? '',
              'posterUrl': (item['Poster'] != null && item['Poster'] != 'N/A')
                  ? item['Poster']
                  : '',
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error OMDb API: $e');
    }
    return [];
  }
}