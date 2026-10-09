import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  // Poin akhir endpoint resmi Google Books
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Fungsi untuk mencari buku berdasarkan kata kunci [query]
  static Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=15',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items == null) return [];

        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          final imageLinks = volumeInfo['imageLinks'] ?? {};
          
          // Mengambil daftar penulis (authors)
          final authorsList = volumeInfo['authors'] as List?;
          final authors = authorsList != null 
              ? authorsList.join(', ') 
              : 'Penulis tidak diketahui';

          // Memastikan tautan gambar menggunakan HTTPS agar tidak diblokir di Android/iOS
          String rawCover = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
          if (rawCover.startsWith('http://')) {
            rawCover = rawCover.replaceFirst('http://', 'https://');
          }

          return {
            'id': item['id'],
            'title': volumeInfo['title'] ?? 'Tanpa Judul',
            'authors': authors,
            'publisher': volumeInfo['publisher'] ?? '',
            'publishedDate': volumeInfo['publishedDate'] ?? '',
            'description': volumeInfo['description'] ?? '',
            'coverUrl': rawCover,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error GoogleBooksService: $e');
    }

    return [];
  }
}