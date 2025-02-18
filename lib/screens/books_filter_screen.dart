import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:shelfless/models/author.dart';
import 'package:shelfless/models/genre.dart';
import 'package:shelfless/models/publisher.dart';
import 'package:shelfless/providers/authors_provider.dart';
import 'package:shelfless/providers/books_provider.dart';
import 'package:shelfless/providers/genres_provider.dart';
import 'package:shelfless/providers/libraries_provider.dart';
import 'package:shelfless/providers/publishers_provider.dart';
import 'package:shelfless/screens/books_screen.dart';
import 'package:shelfless/screens/edit_publisher_screen.dart';
import 'package:shelfless/themes/themes.dart';
import 'package:shelfless/utils/strings/strings.dart';
import 'package:shelfless/widgets/author_preview_widget.dart';
import 'package:shelfless/widgets/search_list_widget.dart';
import 'package:shelfless/widgets/genre_preview_widget.dart';
import 'package:shelfless/widgets/publisher_preview_widget.dart';
import 'package:shelfless/widgets/dialog_button_widget.dart';
import 'package:shelfless/widgets/separator_widget.dart';
import 'package:shelfless/widgets/unfocus_widget.dart';

class BooksFilterScreen extends StatefulWidget {
  static const String routeName = "/books/filter";

  const BooksFilterScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<BooksFilterScreen> createState() => _BooksFilterScreenState();
}

class _BooksFilterScreenState extends State<BooksFilterScreen> {
  final Box<Author> _authors = Hive.box<Author>("authors");
  final Box<Genre> _genres = Hive.box<Genre>("genres");

  final List<Author> _selectedAuthors = [];
  final List<Genre> _selectedGenres = [];
  final List<Publisher> _selectedPublishers = [];
  DateTime _startPublishDate = DateTime.now();
  DateTime _endPublishDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Fetch providers.
    final BooksProvider _booksProvider = Provider.of(context, listen: false);
    final LibrariesProvider _librariesProvider = Provider.of(context, listen: false);

    const double dialogWidth = 300.0;

    final int currentYear = DateTime.now().year;

    return UnfocusWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.filterTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.all(Themes.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Authors.
                      Text(strings.bookInfoAuthors),
                      if (_selectedAuthors.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(Themes.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _selectedAuthors.map((Author author) => _buildAuthorPreview(author)).toList(),
                          ),
                        ),

                      DialogButtonWidget(
                        label: const Icon(Icons.add_rounded),
                        title: Text(strings.bookInfoAuthors),
                        content: Consumer<AuthorsProvider>(
                          builder: (BuildContext context, AuthorsProvider provider, Widget? child) => SearchListWidget<Author>(
                            children: provider.authors,
                            filter: (Author author, String? filter) => filter != null ? author.toString().toLowerCase().contains(filter) : true,
                            builder: (Author author) => GestureDetector(
                              onTap: () {
                                // Only add the author if not already there.
                                if (!_selectedAuthors.contains(author)) {
                                  setState(() {
                                    _selectedAuthors.add(author);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(strings.authorAlreadyAdded),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                                Navigator.of(context).pop();
                              },
                              child: AuthorPreviewWidget(author: author),
                            ),
                          ),
                        ),
                      ),

                      const SeparatorWidget(
                        child: Divider(
                          height: 2.0,
                        ),
                      ),

                      // Genres.
                      Text(strings.bookInfoGenres),
                      if (_selectedGenres.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(Themes.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _selectedGenres.map((Genre genre) => _buildGenrePreview(genre)).toList(),
                          ),
                        ),

                      DialogButtonWidget(
                        label: const Icon(Icons.add_rounded),
                        title: Text(strings.bookInfoGenres),
                        content: Consumer<GenresProvider>(
                          builder: (BuildContext context, GenresProvider provider, Widget? child) => SearchListWidget<Genre>(
                            children: provider.genres,
                            filter: (Genre genre, String? filter) => filter != null ? genre.toString().toLowerCase().contains(filter) : true,
                            builder: (Genre genre) => GestureDetector(
                              onTap: () {
                                // Only add the author if not already there.
                                if (!_selectedGenres.contains(genre)) {
                                  setState(() {
                                    _selectedGenres.add(genre);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(strings.authorAlreadyAdded),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                                Navigator.of(context).pop();
                              },
                              child: GenrePreviewWidget(genre: genre),
                            ),
                          ),
                        ),
                      ),

                      const SeparatorWidget(
                        child: Divider(
                          height: 2.0,
                        ),
                      ),

                      // Publisher.
                      Text(strings.bookInfoPublisher),
                      if (_selectedPublishers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _selectedPublishers.map((Publisher publisher) => _buildPublisherPreview(publisher)).toList(),
                          ),
                        ),

                      DialogButtonWidget(
                          label: Text(strings.addOne),
                          title: Text(strings.bookInfoPublisher),
                          content: Consumer<PublishersProvider>(
                            // Listen to changes in saved publishers.
                            builder: (BuildContext context, PublishersProvider provider, Widget? child) => SizedBox(
                              width: dialogWidth,
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  ...List.generate(
                                    provider.publishers.length + 1,
                                    (int index) => index < provider.publishers.length
                                        ? GestureDetector(
                                            onTap: () {
                                              final Publisher publisher = provider.publishers[index];

                                              // Only add the publisher if not already there.
                                              if (!_selectedPublishers.contains(publisher)) {
                                                setState(() {
                                                  _selectedPublishers.add(publisher);
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(strings.genreAlreadyAdded),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: PublisherPreviewWidget(publisher: provider.publishers[index]),
                                          )
                                        : ListTile(
                                            leading: Text(strings.add),
                                            trailing: const Icon(Icons.add),
                                            onTap: () => Navigator.of(context).pushNamed(EditPublisherScreen.routeName),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          )),

                      const SeparatorWidget(
                        child: Divider(
                          height: 2.0,
                        ),
                      ),

                      const SeparatorWidget(
                        child: Divider(
                          height: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(Themes.spacingMedium),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(strings.filterCancel),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(Themes.spacingMedium),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => BooksScreen(
                            authors: _selectedAuthors.toSet(),
                            genres: _selectedGenres.toSet(),
                            publisher: _selectedPublishers.isNotEmpty ? _selectedPublishers.first : null,
                          ),
                        ));
                      },
                      child: Text(strings.filterApply),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorPreview(Author author) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AuthorPreviewWidget(author: author),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedAuthors.remove(author);
            });
          },
          icon: const Icon(
            Icons.cancel_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildGenrePreview(Genre genre) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GenrePreviewWidget(genre: genre),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedGenres.remove(genre);
            });
          },
          icon: const Icon(
            Icons.cancel_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildPublisherPreview(Publisher publisher) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: PublisherPreviewWidget(publisher: publisher),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedPublishers.remove(publisher);
            });
          },
          icon: const Icon(
            Icons.cancel_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
