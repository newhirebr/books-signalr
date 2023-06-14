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
  String? errorMessage;

  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  HubConnection? hubConnection;
  void submitBook() {
    String title = titleController.text;
    String author = authorController.text;

    if (title.isNotEmpty && author.isNotEmpty) {
      Book book = Book(title, author);
      hubConnection?.invoke("AddBook", args: [book]);
      titleController.clear();
      authorController.clear();
      setState(() {
        errorMessage = null; // Clear any previous error message
      });
    } else {
      setState(() {
        errorMessage = "Please fill in both title and author fields";
      });
    }
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
          .withUrl("ws://bookhubappfinal.azurewebsites.net/bookhub",
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(Color.fromRGBO(210, 80, 88, 1).value,
            getSwatch(Color.fromRGBO(210, 80, 88, 1))),
      ),
      title: 'Book App',
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(210, 80, 88, 1),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Real Time Updates',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              GemTextField(
                controller: titleController,
                label: 'Title',
              ),
              const SizedBox(height: 30),
              GemTextField(
                controller: authorController,
                label: 'Author',
              ),
              const SizedBox(height: 30),
              ActionButton(
                title: 'Add book',
                ontapp: () {
                  submitBook();
                },
              ),
              Text(
                errorMessage ?? '',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Older books',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(books[index].title),
                      subtitle: Text(books[index].author),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class GemTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const GemTextField({Key? key, this.label, this.controller, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white)),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
        ),
        controller: controller,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback ontapp;
  const ActionButton(
      {Key? key, this.color, required this.title, required this.ontapp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          onPressed: ontapp,
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            )),
            backgroundColor: MaterialStateProperty.all(
                (color ?? const Color.fromRGBO(146, 69, 74, 1))),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  color: color != null
                      ? const Color.fromRGBO(146, 69, 74, 1)
                      : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

Map<int, Color> getSwatch(Color color) {
  final hslColor = HSLColor.fromColor(color);
  final lightness = hslColor.lightness;
  final lowDivisor = 6;
  final highDivisor = 5;

  final lowStep = (1.0 - lightness) / lowDivisor;
  final highStep = lightness / highDivisor;

  return {
    50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
    100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
    200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
    300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
    400: (hslColor.withLightness(lightness + lowStep)).toColor(),
    500: (hslColor.withLightness(lightness)).toColor(),
    600: (hslColor.withLightness(lightness - highStep)).toColor(),
    700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
    800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
    900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
  };
}
