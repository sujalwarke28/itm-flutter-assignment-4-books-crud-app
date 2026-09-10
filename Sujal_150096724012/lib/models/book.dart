class Book {
  String id;
  String title;
  String author;
  String isbn;
  String genre;
  double price;
  int quantity;
  String description;
  String publisher;
  DateTime publishedDate;

  Book({
    this.id = '',
    required this.title,
    required this.author,
    this.isbn = '',
    this.genre = '',
    this.price = 0.0,
    this.quantity = 0,
    this.description = '',
    this.publisher = '',
    DateTime? publishedDate,
  }) : publishedDate = publishedDate ?? DateTime.now();

  factory Book.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['publishedDate'] != null) {
      if (json['publishedDate'] is String) {
        parsedDate = DateTime.tryParse(json['publishedDate']) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      publishedDate: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'price': price,
      'quantity': quantity,
      'description': description,
      'publisher': publisher,
      'publishedDate': publishedDate.toIso8601String(),
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? genre,
    double? price,
    int? quantity,
    String? description,
    String? publisher,
    DateTime? publishedDate,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      genre: genre ?? this.genre,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }
}
