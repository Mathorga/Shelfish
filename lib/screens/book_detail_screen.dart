import 'dart:math';

import 'package:flutter/material.dart';

import 'package:blur/blur.dart';

import 'package:shelfless/models/book.dart';
import 'package:shelfless/providers/library_content_provider.dart';
import 'package:shelfless/screens/edit_book_screen.dart';
import 'package:shelfless/themes/shelfless_colors.dart';
import 'package:shelfless/themes/themes.dart';
import 'package:shelfless/utils/element_action.dart';
import 'package:shelfless/utils/material_utils.dart';
import 'package:shelfless/utils/strings/strings.dart';
import 'package:shelfless/widgets/book_thumbnail_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;

  @override
  void initState() {
    super.initState();

    _book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets devicePadding = MediaQuery.paddingOf(context);
    final Size deviceSize = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<ElementAction>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: ElementAction.edit,
                  child: Row(
                    spacing: Themes.spacingSmall,
                    children: [
                      const Icon(Icons.edit_rounded),
                      Text(strings.bookEdit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ElementAction.delete,
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
            onSelected: (ElementAction value) async {
              switch (value) {
                case ElementAction.edit:
                  // Open EditBookScreen.
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => EditBookScreen(
                      book: _book,
                      onDone: (Book book) => setState(() {
                        _book = book;
                      }),
                    ),
                  ));
                  break;
                case ElementAction.moveTo:
                  break;
                case ElementAction.delete:
                  final NavigatorState navigator = Navigator.of(context);

                  final bool? deleted = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(strings.deleteBookTitle),
                      content: Text(strings.deleteBookContent),
                      actions: [
                        // Cancel button.
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
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
                            await LibraryContentProvider.instance.deleteBook(_book);

                            messenger.showSnackBar(
                              SnackBar(
                                duration: Themes.durationShort,
                                behavior: SnackBarBehavior.floating,
                                width: Themes.snackBarSizeSmall,
                                content: Text(
                                  strings.bookDeleted,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );

                            // Pop dialog.
                            navigator.pop(true);
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

                  // Pop back if the book was deleted.
                  if (deleted == true) navigator.pop();

                  break;
              }
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          if (_book.raw.cover != null)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.25,
                    1.0,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstOut,
              child: Blur(
                blur: Themes.blurStrengthHigh,
                colorOpacity: Themes.blurOpacity,
                blurColor: Colors.transparent,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.memory(
                    _book.raw.cover!,
                    fit: BoxFit.cover,
                    isAntiAlias: false,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: Themes.scrollPhysics,
              child: SizedBox(
                width: min(deviceSize.width, Themes.maxContentWidth),
                child: Column(
                  spacing: Themes.spacingMedium,
                  children: [
                    // Cover.
                    Column(
                      spacing: Themes.spacingXLarge,
                      children: [
                        // Top padding.
                        SizedBox(
                          height: devicePadding.top,
                        ),
                        Center(
                          child: BookThumbnailWidget(
                            book: _book,
                            showOutBanner: true,
                          ),
                        ),
                      ],
                    ),

                    // Title, edition, publisher and publication year.
                    Column(
                      spacing: Themes.spacingSmall,
                      children: [
                        // TItle.
                        Center(
                          child: Text(
                            _book.raw.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // TODO Edition.

                        // Publisher.
                        if (LibraryContentProvider.instance.publishers[_book.raw.publisherId] != null)
                          Center(
                            child: Text("${LibraryContentProvider.instance.publishers[_book.raw.publisherId]!}"),
                          ),

                        // Publication year.
                        Center(
                          child: Text(
                            "${_book.raw.publishYear}",
                          ),
                        ),
                      ],
                    ),

                    // Authors and genres.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Authors.
                        Padding(
                          padding: const EdgeInsets.all(Themes.spacingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.authorsSectionTitle,
                                style: TextStyle(
                                  color: ShelflessColors.onMainContentInactive,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(Themes.spacingMedium),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _book.authorIds.map((int authorId) => Text(LibraryContentProvider.instance.authors[authorId].toString())).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Genres.
                        Padding(
                          padding: const EdgeInsets.all(Themes.spacingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                strings.genresSectionTitle,
                                style: TextStyle(
                                  color: ShelflessColors.onMainContentInactive,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(Themes.spacingMedium),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: _book.genreIds.map((int genreId) => Text(LibraryContentProvider.instance.genres[genreId].toString())).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Actions.
                    Padding(
                      padding: const EdgeInsets.all(Themes.spacingMedium),
                      child: Row(
                        spacing: Themes.spacingSmall,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildAction(
                              context,
                              onPressed: () {
                                setState(() {
                                  // Update book and store the update in DB.
                                  _book.raw.out = !_book.raw.out;
                                });
                                LibraryContentProvider.instance.storeBookUpdate(_book);
                              },
                              label: _book.raw.out ? strings.bookMarkInAction : strings.bookMarkOutAction,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildAction(
                              context,
                              onPressed: () {
                                MaterialUtils.moveBookTo(context, book: _book);
                              },
                              label: strings.bookMoveTo,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Location.
                    if (_book.raw.locationId != null)
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(Themes.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Themes.spacingSmall,
                            children: [
                              Text(
                                strings.locationTitle,
                                style: TextStyle(
                                  color: ShelflessColors.onMainContentInactive,
                                ),
                              ),
                              Text("${LibraryContentProvider.instance.locations[_book.raw.locationId]}"),
                            ],
                          ),
                        ),
                      ),

                    // Notes.
                    if (_book.raw.notes.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(Themes.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Themes.spacingSmall,
                            children: [
                              Text(
                                strings.bookInfoNotes,
                                style: TextStyle(
                                  color: ShelflessColors.onMainContentInactive,
                                ),
                              ),
                              Text(
                                _book.raw.notes,
                                maxLines: null,
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    void Function()? onPressed,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: ShelflessColors.onMainContentActive,
        backgroundColor: ShelflessColors.mainContentInactive,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Themes.spacingMedium),
        child: Text(
          label,
          maxLines: 1,
        ),
      ),
    );
  }
}
