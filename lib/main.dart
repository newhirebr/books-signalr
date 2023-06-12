import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';

void main() {
  runApp(BookApp());
}

class BookApp extends StatefulWidget {
  @override
  _BookAppState createState() => _BookAppState();
}

class _BookAppState extends State<BookApp> {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  HubConnection? hubConnection;
  void submitBook() {
    String title = titleController.text;
    String author = authorController.text;
    Book book = Book(title, author);
    hubConnection?.invoke("AddBook", args: [book]);
    titleController.clear();
    authorController.clear();
  }

  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    connectToHub();
  }

  Future<void> connectToHub() async {
    try {
      hubConnection = HubConnectionBuilder()
          .withUrl("ws://bookhubapptestmarwa.azurewebsites.net/bookhub",
              options: HttpConnectionOptions(
                skipNegotiation: true,
                transport: HttpTransportType.WebSockets,
              ))
          .build();

      hubConnection?.on("ReceiveBook", (books) {
        setState(() {
          for (var book in books ?? []) {
            this.books.add(Book.fromJson(book));
          }
        });
      });
      await hubConnection?.start();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Book App',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Book App'),
            ),
            body: Column(children: [
              // Form fields for book title and author
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Author'),
              ),
              // Button to submit the book
              ElevatedButton(
                onPressed: () => submitBook(),
                child: Text('Submit'),
              ),
              // List of books
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(books[index].title),
                      subtitle: Text(books[index].author),
                    );
                  },
                ),
              ),
            ])));
  }
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(json['title'], json['author']);
  }
}
