import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:books_crud_app/main.dart';
import 'package:books_crud_app/models/book.dart';

void main() {
  test('Book model serialization and deserialization', () {
    final now = DateTime.now();
    final book = Book(
      id: '123',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '9780132350884',
      genre: 'Technology',
      price: 29.99,
      quantity: 5,
      description: 'A handbook of agile software craftsmanship.',
      publisher: 'Prentice Hall',
      publishedDate: now,
    );

    final json = book.toJson();
    expect(json['title'], 'Clean Code');
    expect(json['author'], 'Robert C. Martin');
    expect(json['isbn'], '9780132350884');
    expect(json['genre'], 'Technology');
    expect(json['price'], 29.99);
    expect(json['quantity'], 5);

    final fromJsonBook = Book.fromJson(json);
    expect(fromJsonBook.id, '123');
    expect(fromJsonBook.title, 'Clean Code');
    expect(fromJsonBook.author, 'Robert C. Martin');
    expect(fromJsonBook.price, 29.99);
  });

  testWidgets('App renders book collection screen and add book button', (WidgetTester tester) async {
    await tester.pumpWidget(const BooksApp());

    expect(find.text('Books Collection'), findsOneWidget);
    expect(find.text('Add Book'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
