import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:paged_view/src/core/base_paging_state.dart';

/// Defines the type of refresh operation to perform.
///
/// During refresh operations, user interaction and scroll-triggered pagination
/// are automatically blocked to prevent interference with the refresh process.
enum RefreshType {
  /// Keep existing data visible while refreshing (default).
  /// Shows isRefreshing = true but maintains current pages and items.
  /// UI is dimmed and user interaction is blocked until refresh completes.
  soft,

  /// Clear all data and show loading indicator.
  /// Resets the state completely and shows first page loading.
  /// All existing data is cleared immediately.
  hard,
}

/// Represents the state of a paginated layout.
@immutable
abstract class PagingState<PageKeyType, ItemType, ErrorType extends Object> {
  const factory PagingState({
    List<List<ItemType>>? pages,
    List<PageKeyType>? keys,
    ErrorType? error,
    bool hasNextPage,
    bool isLoading,
    bool isRefreshing,
    int totalResults,
  }) = BasePagingState<PageKeyType, ItemType, ErrorType>;

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
  ErrorType? get error;

  /// Will be `true` if there is a next page to be fetched.
  bool get hasNextPage;

  /// Will be `true` if a page is currently being fetched.
  bool get isLoading;

  /// the total result count of the paginated data.
  int get totalResults;

  /// Will be `true` if the data is currently being refreshed.
  /// During refresh, pages and keys remain available while new data is fetched.
  /// User interaction and scroll-triggered pagination are blocked during refresh.
  bool get isRefreshing;

  /// Creates a copy of this [PagingState] but with the given fields replaced by the new values.
  /// If a field is not provided, it will default to the current value.
  ///
  /// While this implementation technically accepts Futures, passing a Future is invalid.
  /// The Defaulted type is used to allow for the Omit sentinel value,
  /// which is required to distinguish between a parameter being omitted and a parameter being set to null.
  // copyWith a la Remi Rousselet: https://github.com/dart-lang/language/issues/137#issuecomment-583783054
  PagingState<PageKeyType, ItemType, ErrorType> copyWith({
    Defaulted<List<List<ItemType>>?>? pages = const Omit(),
    Defaulted<List<PageKeyType>?>? keys = const Omit(),
    Defaulted<ErrorType?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<bool>? isRefreshing = const Omit(),
    Defaulted<int>? totalResults = const Omit(),
  });

  /// Returns a copy this [PagingState] but
  /// all fields are reset to their initial values.
  ///
  /// If you are implementing a custom [PagingState], you should override this method
  /// to reset custom fields as well.
  ///
  /// The reason we use this instead of creating a new instance is so that
  /// a custom [PagingState] can be reset without losing its type.
  PagingState<PageKeyType, ItemType, ErrorType> reset();

  // Smart API methods that automatically handle complex logic

  /// Appends a new page of items.
  /// If the state was refreshing, it replaces all existing data with the new page.
  /// Otherwise, it appends the page to existing data.
  PagingState<PageKeyType, ItemType, ErrorType> appendPage({
    required List<ItemType> items,
    required PageKeyType pageKey,
    required bool hasNextPage,
    int? totalResults,
  });

  /// Sets an error state and stops any loading/refreshing operations.
  PagingState<PageKeyType, ItemType, ErrorType> setError(ErrorType error);

  /// Starts a refresh operation with the specified type.
  ///
  /// [RefreshType.soft] (default): Keeps existing data visible while refreshing.
  /// [RefreshType.hard]: Clears all data and shows loading indicator.
  PagingState<PageKeyType, ItemType, ErrorType> refresh([RefreshType type = RefreshType.soft]);
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
