import 'package:freezed_annotation/freezed_annotation.dart';

import '../../paged_view.dart';

part 'paginated_state.freezed.dart';

@Freezed(copyWith: false)
class PaginatedState<ItemType>
    with _$PaginatedState<ItemType>
    implements PagingState<int, ItemType> {
  const PaginatedState._();

  const factory PaginatedState({
    List<List<ItemType>>? pages,
    List<int>? keys,
    Object? error,
    @Default(true) bool hasNextPage,
    @Default(false) bool isLoading,
    @Default(0) int total,
  }) = _PaginatedState<ItemType>;

  @override
  PaginatedState<ItemType> copyWith({
    Defaulted<List<List<ItemType>>?>? pages = const Omit(),
    Defaulted<List<int>?>? keys = const Omit(),
    Defaulted<Object?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<int>? total = const Omit(),
  }) {
    return PaginatedState<ItemType>(
      pages: pages is Omit ? this.pages : pages as List<List<ItemType>>?,
      keys: keys is Omit ? this.keys : keys as List<int>?,
      error: error is Omit ? this.error : error,
      hasNextPage: hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
      isLoading: isLoading is Omit ? this.isLoading : isLoading as bool,
      total: total is Omit ? this.total : total as int,
    );
  }

  @override
  PaginatedState<ItemType> reset() {
    return PaginatedState<ItemType>(
      pages: null,
      keys: null,
      error: null,
      hasNextPage: true,
      isLoading: false,
      total: 0,
    );
  }
}
