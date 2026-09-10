import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static String get baseUrl {
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:5000/api/books';
        }
      } catch (_) {}
    }
    return 'http://localhost:5000/api/books';
  }

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// GET /api/books - Get all books
  Future<List<Book>> getAllBooks() async {
    final response = await client.get(
      Uri.parse(baseUrl),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to load books (Status: ${response.statusCode})');
    }
  }

  /// GET /api/books/:id - Get a specific book
  Future<Book> getBookById(String id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to load book (Status: ${response.statusCode})');
    }
  }

  /// POST /api/books - Add a new book
  Future<Book> createBook(Book book) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(book.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final body = jsonDecode(response.body);
      final details = body['details'];
      if (details is List && details.isNotEmpty) {
        throw Exception(details.join(', '));
      }
      throw Exception(body['error'] ?? 'Failed to create book (Status: ${response.statusCode})');
    }
  }

  /// PUT /api/books/:id - Update a book
  Future<Book> updateBook(String id, Book book) async {
    final response = await client.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(book.toJson()),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final body = jsonDecode(response.body);
      final details = body['details'];
      if (details is List && details.isNotEmpty) {
        throw Exception(details.join(', '));
      }
      throw Exception(body['error'] ?? 'Failed to update book (Status: ${response.statusCode})');
    }
  }

  /// DELETE /api/books/:id - Delete a book
  Future<bool> deleteBook(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to delete book (Status: ${response.statusCode})');
    }
  }
}

class BookProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedGenre = 'All';

  BookProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;

  List<String> get availableGenres {
    final Set<String> genres = {};
    for (final book in _books) {
      if (book.genre.trim().isNotEmpty) {
        genres.add(book.genre.trim());
      }
    }
    final list = genres.toList()..sort();
    return ['All', ...list];
  }

  List<Book> get filteredBooks {
    return _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.isbn.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesGenre = _selectedGenre == 'All' ||
          book.genre.trim().toLowerCase() == _selectedGenre.toLowerCase();

      return matchesSearch && matchesGenre;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _apiService.getAllBooks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Book?> getBookById(String id) async {
    try {
      final book = await _apiService.getBookById(id);
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books[index] = book;
        notifyListeners();
      }
      return book;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<Book> addBook(Book book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final createdBook = await _apiService.createBook(book);
      _books.insert(0, createdBook);
      _isLoading = false;
      notifyListeners();
      return createdBook;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Book> updateBook(String id, Book book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateBook(id, book);
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteBook(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
