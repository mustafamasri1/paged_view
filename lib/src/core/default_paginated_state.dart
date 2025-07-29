import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../paged_view.dart';

@immutable
class DefaultPaginatedState<PageKeyType, ItemType> implements PagingState<PageKeyType, ItemType, Object> {
  const DefaultPaginatedState({
    this.pages,
    this.keys,
    this.error,
    this.hasNextPage = true,
    this.isLoading = false,
    this.isRefreshing = false,
    this.refreshCompletedAt,
    this.total = 0,
  });

  @override
  final List<List<ItemType>>? pages;

  @override
  final List<PageKeyType>? keys;

  @override
  final Object? error;

  @override
  final bool hasNextPage;

  @override
  final bool isLoading;

  @override
  final bool isRefreshing;

  @override
  final DateTime? refreshCompletedAt;

  final int total;

  @override
  DefaultPaginatedState<PageKeyType, ItemType> copyWith({
    Defaulted<List<List<ItemType>>?>? pages = const Omit(),
    Defaulted<List<PageKeyType>?>? keys = const Omit(),
    Defaulted<Object?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<bool>? isRefreshing = const Omit(),
    Defaulted<DateTime?>? refreshCompletedAt = const Omit(),
    Defaulted<int>? total = const Omit(),
  }) {
    return DefaultPaginatedState<PageKeyType, ItemType>(
      pages: pages is Omit ? this.pages : pages as List<List<ItemType>>?,
      keys: keys is Omit ? this.keys : keys as List<PageKeyType>?,
      error: error is Omit ? this.error : error,
      hasNextPage: hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
      isLoading: isLoading is Omit ? this.isLoading : isLoading as bool,
      isRefreshing: isRefreshing is Omit ? this.isRefreshing : isRefreshing as bool,
      refreshCompletedAt:
          refreshCompletedAt is Omit ? this.refreshCompletedAt : refreshCompletedAt as DateTime?,
      total: total is Omit ? this.total : total as int,
    );
  }

  @override
  DefaultPaginatedState<PageKeyType, ItemType> reset() {
    return DefaultPaginatedState<PageKeyType, ItemType>(
      pages: null,
      keys: null,
      error: null,
      hasNextPage: true,
      isLoading: false,
      isRefreshing: false,
      refreshCompletedAt: null,
      total: 0,
    );
  }

  @override
  DefaultPaginatedState<PageKeyType, ItemType> refreshing() {
    return DefaultPaginatedState<PageKeyType, ItemType>(
      pages: pages,
      keys: keys,
      error: null,
      hasNextPage: hasNextPage,
      isLoading: false,
      isRefreshing: true,
      refreshCompletedAt: refreshCompletedAt,
      total: total,
    );
  }

  @override
  DefaultPaginatedState<PageKeyType, ItemType> appendPage(
    List<ItemType> newPage,
    PageKeyType pageKey, {
    bool isLastPage = false,
  }) {
    final wasRefreshing = isRefreshing;
    return DefaultPaginatedState<PageKeyType, ItemType>(
      pages: wasRefreshing ? [newPage] : [...?pages, newPage],
      keys: wasRefreshing ? [pageKey] : [...?keys, pageKey],
      error: null,
      hasNextPage: !isLastPage,
      isLoading: false,
      isRefreshing: false,
      refreshCompletedAt: wasRefreshing ? DateTime.now() : refreshCompletedAt,
      total: total,
    );
  }

  @override
  DefaultPaginatedState<PageKeyType, ItemType> setError(Object error) {
    final wasRefreshing = isRefreshing;
    return DefaultPaginatedState<PageKeyType, ItemType>(
      pages: wasRefreshing ? null : pages,
      keys: wasRefreshing ? null : keys,
      error: error,
      hasNextPage: wasRefreshing ? true : hasNextPage,
      isLoading: false,
      isRefreshing: false,
      refreshCompletedAt: refreshCompletedAt,
      total: total,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DefaultPaginatedState<PageKeyType, ItemType>) return false;

    return const DeepCollectionEquality().equals(pages, other.pages) &&
        const ListEquality().equals(keys, other.keys) &&
        error == other.error &&
        hasNextPage == other.hasNextPage &&
        isLoading == other.isLoading &&
        isRefreshing == other.isRefreshing &&
        refreshCompletedAt == other.refreshCompletedAt &&
        total == other.total;
  }

  @override
  int get hashCode {
    return Object.hash(
      const DeepCollectionEquality().hash(pages),
      const ListEquality().hash(keys),
      error,
      hasNextPage,
      isLoading,
      isRefreshing,
      refreshCompletedAt,
      total,
    );
  }
}
