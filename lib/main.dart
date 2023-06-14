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
          .withUrl("ws://bookhubapp2.azurewebsites.net/bookhub",
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
      hubConnection?.on("ReceiveOlderBooks", (books) {
        setState(() {
          this.books.addAll(Book.fromJsonList(books![0] as List));
        });
      });
      await hubConnection?.start();
      await hubConnection?.invoke("SendOlderBooks", args: []);
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
  static List<Book> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Book.fromJson(json)).toList();
  }
}
