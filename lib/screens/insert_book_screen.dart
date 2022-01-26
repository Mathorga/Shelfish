import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'package:shelfish/models/author.dart';
import 'package:shelfish/models/book.dart';
import 'package:shelfish/models/genre.dart';

class InsertBookScreen extends StatelessWidget {
  static const String routeName = "/insert-book";

  const InsertBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Insert Book"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Title"),
              const TextField(),
              const SizedBox(height: 12.0),
              const Text("Authors"),
              const TextField(),
              const SizedBox(height: 12.0),
              const Text("Publish date"),
              const TextField(
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12.0),
              const Text("Genre"),
              const TextField(),
              const SizedBox(height: 12.0),
              const Text("Publisher"),
              const TextField(),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Row(
            children: const [
              Text("Done"),
              SizedBox(width: 12.0),
              Icon(Icons.check),
            ],
          )),
    );
  }

  void addBook() {
    final Box box = Hive.box<Book>("books");
    box.add(Book(
        title: "test",
        authors: [Author("Maurizio", "Micheletti")],
        publishDate: 1978,
        genre: Genre(name: "Thriller", color: Colors.red.value),
        publisher: "Mondadori",
        location: "Here"));
  }
}
