import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paged_view/paged_view.dart';

sealed class PagingEvent {
  const PagingEvent();
}

final class PagingFetchNext extends PagingEvent {}

final class PagingRefresh extends PagingEvent {}

final class PagingCancel extends PagingEvent {}

final class PagingChangeSearch extends PagingEvent {
  const PagingChangeSearch(this.newSearch);

  final String? newSearch;
}

/// A simple implementation of a cancel token.
class BlocCancelToken {
  BlocCancelToken();

  bool _isCancelled = false;
  final _completer = Completer<void>();

  /// Whether the token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Completes when cancelled.
  Future<void> get whenCancelled => _completer.future;

  /// Cancel the operation.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _completer.complete();
  }
}

class PagingBloc<T> extends Bloc<PagingEvent, PaginatedState<T>> {
  PagingBloc({
    required this.fetchFn,
  }) : super(PaginatedState<T>()) {
    on<PagingFetchNext>(_onFetchNext);
    on<PagingRefresh>(_onRefresh);
  }

  final Future<List<T>> Function(int pageKey)? fetchFn;

  Future<void> _onFetchNext(
    PagingFetchNext event,
    Emitter<PaginatedState<T>> emit,
  ) async {
    final current = state;
    if (current.isLoading || !current.hasNextPage) return;

    final pageKey = current.lastPageIsEmpty ? null : current.nextIntPageKey;
    if (pageKey == null) {
      emit(current.copyWith(hasNextPage: false));
      return;
    }

    emit(current.copyWith(
      isLoading: true,
      error: null,
    ));

    try {
      final result = await fetchFn!(pageKey);

      final isLastPage = result.isEmpty;
      emit(state.copyWith(
        isLoading: false,
        error: null,
        hasNextPage: !isLastPage,
        pages: [...?state.pages, result],
        keys: [...?state.keys, pageKey],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> _onRefresh(
    PagingRefresh event,
    Emitter<PaginatedState<T>> emit,
  ) async {
    emit(state.reset());
    add(PagingFetchNext());
  }
}
