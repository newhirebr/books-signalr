import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr/cubits/book_cubit.dart';
import 'package:signalr/cubits/book_state.dart';
import 'package:signalr/models/book.dart';
import 'package:signalr/widgets/action_button.dart';
import 'package:signalr/widgets/text_field.dart';

void main() {
  runApp(BookApp());
}

class BookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Book App',
      home: BlocProvider(
        create: (context) => BookCubit(),
        child: BookScreen(),
      ),
    );
  }
}

class BookScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),
            ),
            const SizedBox(height: 30),
            MyTextField(
              controller: titleController,
              label: 'Title',
            ),
            const SizedBox(height: 30),
            MyTextField(
              controller: authorController,
              label: 'Author',
            ),
            const SizedBox(height: 30),
            ActionButton(
              title: 'Add book',
              onTap: () {
                final title = titleController.text;
                final author = authorController.text;

                if (title.isNotEmpty && author.isNotEmpty) {
                  final book = Book(title, author);
                  context.read<BookCubit>().addBook(book);
                  titleController.clear();
                  authorController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please fill in both title and author fields'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            Text(
              'Older books',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: BlocBuilder<BookCubit, BooksState>(
                builder: (context, state) {
                  if (state.status == BooksStatus.loadingOld) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.teal),
                    );
                  } else if (state.status != BooksStatus.error) {
                    final books = state.olderBooks;
                    return ListView.builder(
                      itemCount: books!.length,
                      itemBuilder: (context, index) {
                        return Card(
                            shadowColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              title: Text(
                                books[index].title,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                books[index].author,
                                style: TextStyle(color: Colors.teal),
                              ),
                            ));
                      },
                    );
                  } else if (state.status == BooksStatus.error) {
                    return Center(
                      child: Text(
                        'Something went wrong',
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Text(
              'New books',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: BlocBuilder<BookCubit, BooksState>(
                builder: (context, state) {
                  if (state.status == BooksStatus.loading) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.teal),
                    );
                  } else if (state.status != BooksStatus.error) {
                    final books = state.books;
                    return ListView.builder(
                      itemCount: books!.length,
                      itemBuilder: (context, index) {
                        return Card(
                            shadowColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              title: Text(
                                books[index].title,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                books[index].author,
                                style: TextStyle(color: Colors.teal),
                              ),
                            ));
                      },
                    );
                  } else if (state.status == BooksStatus.error) {
                    return Center(
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
