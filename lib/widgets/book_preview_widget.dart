import 'package:flutter/material.dart';

import 'package:shelfless/models/book.dart';
import 'package:shelfless/models/author.dart';
import 'package:shelfless/providers/library_content_provider.dart';
import 'package:shelfless/screens/edit_book_screen.dart';
import 'package:shelfless/themes/shelfless_colors.dart';
import 'package:shelfless/themes/themes.dart';
import 'package:shelfless/utils/strings/strings.dart';
import 'package:shelfless/widgets/book_thumbnail_widget.dart';

enum BookAction {
  edit,
  moveTo,
  delete,
}

class BookPreviewWidget extends StatelessWidget {
  final Book book;
  final void Function()? onTap;

  const BookPreviewWidget({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Author> authors = book.authorIds
        .map((int authorId) {
          return LibraryContentProvider.instance.authors[authorId];
        })
        .nonNulls
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        spacing: Themes.spacingMedium,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BookThumbnailWidget(book: book),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Themes.spacingSmall),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    spacing: Themes.spacingXSmall,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Title.
                      Text(
                        book.raw.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                      ),

                      // Authors.
                      if (authors.isNotEmpty)
                        Text(
                          authors.length <= 2
                              ? authors.map((Author author) => author.toString()).reduce((String value, String element) => "$value, $element")
                              : "${authors.first}, others",
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                    ],
                  ),
                ),
                PopupMenuButton<BookAction>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Themes.radiusSmall),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: BookAction.edit,
                        child: Row(
                          spacing: Themes.spacingSmall,
                          children: [
                            const Icon(Icons.edit_rounded),
                            Text(strings.bookEdit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: BookAction.moveTo,
                        enabled: false,
                        child: Row(
                          spacing: Themes.spacingSmall,
                          children: [
                            const Icon(Icons.move_up_rounded),
                            Text(strings.bookMoveTo),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: BookAction.delete,
                        child: Row(
                          spacing: Themes.spacingSmall,
                          children: [
                            const Icon(Icons.delete_rounded),
                            Text(strings.bookDeleteAction),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (BookAction value) {
                    switch (value) {
                      case BookAction.edit:
                        // Open EditBookScreen.
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => EditBookScreen(
                            book: book,
                          ),
                        ));
                        break;
                      case BookAction.moveTo:
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(strings.warning),
                            content: Text(strings.unreleasedFeatureAlert),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(strings.ok),
                              ),
                            ],
                          ),
                        );
                        break;
                      case BookAction.delete:
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(strings.deleteBookTitle),
                            content: Text(strings.deleteBookContent),
                            actions: [
                              // Cancel button.
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: ShelflessColors.onMainContentActive,
                                ),
                                child: Text(strings.cancel),
                              ),

                              // Confirm button.
                              ElevatedButton(
                                onPressed: () async {
                                  // Prefetch handlers before async gaps.
                                  final NavigatorState navigator = Navigator.of(context);
                                  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

                                  // Delete the book.
                                  await LibraryContentProvider.instance.deleteBook(book);

                                  messenger.showSnackBar(
                                    SnackBar(
                                      // margin: const EdgeInsets.all(Themes.spacingMedium),
                                      duration: Themes.durationShort,
                                      behavior: SnackBarBehavior.floating,
                                      width: Themes.snackBarSizeSmall,
                                      content: Text(
                                        strings.bookDeleted,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );

                                  // Pop back.
                                  navigator.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ShelflessColors.error,
                                  iconColor: ShelflessColors.onMainContentActive,
                                  foregroundColor: ShelflessColors.onMainContentActive,
                                ),
                                child: Text(strings.ok),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  borderRadius: BorderRadius.circular(Themes.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.all(Themes.spacingSmall),
                    child: Icon(
                      Icons.more_vert_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
