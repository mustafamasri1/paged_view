import 'package:flutter/foundation.dart';

import '../../paged_view.dart';

@immutable
class BasePagingState<PageKeyType, ItemType, ErrorType extends Object>
    implements PagingState<PageKeyType, ItemType, ErrorType> {
  const BasePagingState({
    this.pages,
    this.keys,
    this.error,
    this.hasNextPage = true,
    this.isLoading = false,
    this.isRefreshing = false,
    this.total = 0,
  });

  @override
  final List<List<ItemType>>? pages;

  @override
  final List<PageKeyType>? keys;

  @override
  final ErrorType? error;

  @override
  final bool hasNextPage;

  @override
  final bool isLoading;

  @override
  final bool isRefreshing;

  final int total;

  @override
  PagingState<PageKeyType, ItemType, ErrorType> copyWith({
    Defaulted<List<List<ItemType>>?>? pages = const Omit(),
    Defaulted<List<PageKeyType>?>? keys = const Omit(),
    Defaulted<ErrorType?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<bool>? isRefreshing = const Omit(),
    Defaulted<int>? total = const Omit(),
  }) {
    return BasePagingState<PageKeyType, ItemType, ErrorType>(
      pages: pages is Omit ? this.pages : pages as List<List<ItemType>>?,
      keys: keys is Omit ? this.keys : keys as List<PageKeyType>?,
      error: error is Omit ? this.error : error as ErrorType?,
      hasNextPage: hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
      isLoading: isLoading is Omit ? this.isLoading : isLoading as bool,
      isRefreshing: isRefreshing is Omit ? this.isRefreshing : isRefreshing as bool,
      total: total is Omit ? this.total : total as int,
    );
  }

  @override
  PagingState<PageKeyType, ItemType, ErrorType> appendPage({
    required List<ItemType> items,
    required PageKeyType pageKey,
    required bool hasNextPage,
  }) {
    final wasRefreshing = isRefreshing;

    if (wasRefreshing) {
      // If we were refreshing, replace all data with the new page
      return copyWith(
        pages: [items],
        keys: [pageKey],
        hasNextPage: hasNextPage,
        isLoading: false,
        isRefreshing: false,
        error: null,
      );
    } else {
      // Normal append - add to existing pages
      final newPages = [...?pages, items];
      final newKeys = [...?keys, pageKey];

      return copyWith(
        pages: newPages,
        keys: newKeys,
        hasNextPage: hasNextPage,
        isLoading: false,
        error: null,
      );
    }
  }

  @override
  PagingState<PageKeyType, ItemType, ErrorType> reset() {
    return BasePagingState<PageKeyType, ItemType, ErrorType>(
      pages: null,
      keys: null,
      error: null,
      hasNextPage: true,
      isLoading: false,
      isRefreshing: false,
      total: 0,
    );
  }

  @override
  PagingState<PageKeyType, ItemType, ErrorType> setError(ErrorType error) {
    final wasRefreshing = isRefreshing;
    return copyWith(
      pages: wasRefreshing ? null : pages,
      keys: wasRefreshing ? null : keys,
      error: error,
      isLoading: false,
      isRefreshing: false,
    );
  }

  @override
  PagingState<PageKeyType, ItemType, ErrorType> refresh([RefreshType type = RefreshType.soft]) {
    return switch (type) {
      RefreshType.soft => copyWith(
          isRefreshing: true,
          isLoading: false,
          error: null,
        ),
      RefreshType.hard => reset(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BasePagingState<PageKeyType, ItemType, ErrorType> &&
        listEquals(other.pages, pages) &&
        listEquals(other.keys, keys) &&
        other.error == error &&
        other.hasNextPage == hasNextPage &&
        other.isLoading == isLoading &&
        other.isRefreshing == isRefreshing &&
        other.total == total;
  }

  @override
  int get hashCode {
    return Object.hash(
      pages,
      keys,
      error,
      hasNextPage,
      isLoading,
      isRefreshing,
      total,
    );
  }

  @override
  String toString() {
    return 'DefaultPaginatedState<$PageKeyType, $ItemType, $ErrorType>('
        'pages: $pages, '
        'keys: $keys, '
        'error: $error, '
        'hasNextPage: $hasNextPage, '
        'isLoading: $isLoading, '
        'isRefreshing: $isRefreshing, '
        'total: $total)';
  }
}
