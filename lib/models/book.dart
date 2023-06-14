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