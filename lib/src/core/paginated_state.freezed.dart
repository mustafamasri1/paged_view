// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaginatedState<ItemType> {
  List<List<ItemType>>? get pages => throw _privateConstructorUsedError;
  List<int>? get keys => throw _privateConstructorUsedError;
  Object? get error => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
}

/// @nodoc

class _$PaginatedStateImpl<ItemType> extends _PaginatedState<ItemType> {
  const _$PaginatedStateImpl(
      {final List<List<ItemType>>? pages,
      final List<int>? keys,
      this.error,
      this.hasNextPage = true,
      this.isLoading = false,
      this.total = 0})
      : _pages = pages,
        _keys = keys,
        super._();

  final List<List<ItemType>>? _pages;
  @override
  List<List<ItemType>>? get pages {
    final value = _pages;
    if (value == null) return null;
    if (_pages is EqualUnmodifiableListView) return _pages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _keys;
  @override
  List<int>? get keys {
    final value = _keys;
    if (value == null) return null;
    if (_keys is EqualUnmodifiableListView) return _keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Object? error;
  @override
  @JsonKey()
  final bool hasNextPage;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int total;

  @override
  String toString() {
    return 'PaginatedState<$ItemType>(pages: $pages, keys: $keys, error: $error, hasNextPage: $hasNextPage, isLoading: $isLoading, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedStateImpl<ItemType> &&
            const DeepCollectionEquality().equals(other._pages, _pages) &&
            const DeepCollectionEquality().equals(other._keys, _keys) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pages),
      const DeepCollectionEquality().hash(_keys),
      const DeepCollectionEquality().hash(error),
      hasNextPage,
      isLoading,
      total);
}

abstract class _PaginatedState<ItemType> extends PaginatedState<ItemType> {
  const factory _PaginatedState(
      {final List<List<ItemType>>? pages,
      final List<int>? keys,
      final Object? error,
      final bool hasNextPage,
      final bool isLoading,
      final int total}) = _$PaginatedStateImpl<ItemType>;
  const _PaginatedState._() : super._();

  @override
  List<List<ItemType>>? get pages;
  @override
  List<int>? get keys;
  @override
  Object? get error;
  @override
  bool get hasNextPage;
  @override
  bool get isLoading;
  @override
  int get total;
}
