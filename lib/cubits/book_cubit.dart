import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr/cubits/book_state.dart';
import 'package:signalr/models/book.dart';
import 'package:signalr_netcore/signalr_client.dart';

class BookCubit extends Cubit<BooksState> {
  List<Book> books = [];
  List<Book> olderBooks = [];
  HubConnection? hubConnection;
  BookCubit()
      : super(BooksState(
            books: [], olderBooks: [], status: BooksStatus.initial)) {
    connectToHub();
  }

  Future<void> connectToHub() async {
    emit(state.copyWith(status: BooksStatus.loadingOld));
    try {
      hubConnection = HubConnectionBuilder()
          .withUrl("ws://book-signalr-hub.azurewebsites.net/bookhub",
              options: HttpConnectionOptions(
                skipNegotiation: true,
                transport: HttpTransportType.WebSockets,
              ))
          .build();

      hubConnection?.on("ReceiveBook", (books) {
        emit(state.copyWith(
            status: BooksStatus.successSubmitted,
            books: List<Book>.from(this.books)
              ..addAll(Book.fromJsonList(books ?? []))));
      });

      hubConnection?.on("ReceiveOlderBooks", (books) {
        emit(state.copyWith(
            status: BooksStatus.successFetchedOld,
            olderBooks: List<Book>.from(this.books)
              ..addAll(Book.fromJsonList(books![0] as List))));
      });

      await hubConnection?.start();
      await hubConnection?.invoke("SendOlderBooks", args: []);
    } catch (e) {
      emit(
        state.copyWith(status: BooksStatus.error),
      );
    }
  }

  Future<void> addBook(Book book) async {
    try {
      emit(state.copyWith(status: BooksStatus.loading));
      await hubConnection?.invoke("AddBook", args: [book]);
      this.books.add(book);
      emit(state.copyWith(status: BooksStatus.successFetchedOld));
    } catch (e) {
      emit(state.copyWith(status: BooksStatus.error));
    }
  }
}
