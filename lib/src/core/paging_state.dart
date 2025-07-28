import 'dart:async';

import 'package:flutter/foundation.dart';

/// Represents the state of a paginated layout.
@immutable
abstract class PagingState<PageKeyType, ItemType> {
  /// The pages fetched so far.
  ///
  /// This contains all pages fetched so far.
  /// The corresponding key for each page is at the same index in [keys].
  List<List<ItemType>>? get pages;

  /// The keys of the pages fetched so far.
  ///
  /// This contains all keys used to fetch pages so far.
  /// The corresponding page for each key is at the same index in [pages].
  List<PageKeyType>? get keys;

  /// The last error that occurred while fetching a page.
  /// This is null if no error occurred.
  Object? get error;

  /// Will be `true` if there is a next page to be fetched.
  bool get hasNextPage;

  /// Will be `true` if a page is currently being fetched.
  bool get isLoading;

  /// Will be `true` if the data is being refreshed while preserving existing pages.
  bool get isRefreshing;

  /// Timestamp indicating when the last refresh completed.
  /// Used to trigger UI animations when refresh finishes.
  DateTime? get refreshCompletedAt;

  /// Creates a copy of this [PagingState] but with the given fields replaced by the new values.
  /// If a field is not provided, it will default to the current value.
  ///
  /// While this implementation technically accepts Futures, passing a Future is invalid.
  /// The Defaulted type is used to allow for the Omit sentinel value,
  /// which is required to distinguish between a parameter being omitted and a parameter being set to null.
  // copyWith a la Remi Rousselet: https://github.com/dart-lang/language/issues/137#issuecomment-583783054
  PagingState<PageKeyType, ItemType> copyWith({
    Defaulted<List<List<ItemType>>?>? pages = const Omit(),
    Defaulted<List<PageKeyType>?>? keys = const Omit(),
    Defaulted<Object?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<bool>? isRefreshing = const Omit(),
    Defaulted<DateTime?>? refreshCompletedAt = const Omit(),
  });

  /// Returns a copy this [PagingState] but
  /// all fields are reset to their initial values.
  ///
  /// If you are implementing a custom [PagingState], you should override this method
  /// to reset custom fields as well.
  ///
  /// The reason we use this instead of creating a new instance is so that
  /// a custom [PagingState] can be reset without losing its type.
  PagingState<PageKeyType, ItemType> reset();

  /// Returns a copy of this [PagingState] with isRefreshing set to true
  /// while preserving existing pages and keys.
  ///
  /// This is useful for refresh operations where you want to show a refresh indicator
  /// while keeping the existing data visible to the user.
  PagingState<PageKeyType, ItemType> refreshing();

  /// Appends a new page to the state, handling both refresh and pagination scenarios.
  ///
  /// If [isRefreshing] is true, this replaces all existing pages with the new page
  /// and sets [refreshCompletedAt] to trigger animations.
  /// If [isRefreshing] is false, this appends the new page to existing pages.
  PagingState<PageKeyType, ItemType> appendPage(
    List<ItemType> newPage,
    PageKeyType pageKey, {
    bool isLastPage = false,
  });

  /// Sets an error state, handling both refresh and pagination error scenarios.
  ///
  /// If [isRefreshing] is true, this sets [refreshCompletedAt] to complete the refresh cycle.
  /// If [isRefreshing] is false, this preserves the current [refreshCompletedAt] value.
  PagingState<PageKeyType, ItemType> setError(Object error);
}

typedef Defaulted<T> = FutureOr<T>;

/// Sentinel value to omit a parameter from a copyWith call.
/// This is used to distinguish between a parameter being omitted and a parameter
/// being set to null.
/// See https://github.com/dart-lang/language/issues/140 for why this is necessary.
final class Omit<T> implements Future<T> {
  const Omit();

  // coverage:ignore-start
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError(
        'It is an error to attempt to use a Omit as a Future.',
      );
  // coverage:ignore-end
}
