import 'package:equatable/equatable.dart';
import 'package:signalr/models/book.dart';

enum BooksStatus {
  initial,
  successFetchedOld,
  loading,
  successSubmitted,
  loadingOld,
  error
}

class BooksState extends Equatable {
  final List<Book>? books;
  final List<Book>? olderBooks;
  final BooksStatus? status;

  const BooksState({
    this.books,
    this.olderBooks,
    this.status,
  });

  @override
  List<Object?> get props => [
        books,
        olderBooks,
        status,
      ];

  BooksState copyWith({
    List<Book>? books,
    BooksStatus? status,
    List<Book>? olderBooks,
  }) =>
      BooksState(
        books: books ?? this.books,
        olderBooks: olderBooks ?? this.olderBooks,
        status: status ?? this.status,
      );
}
