import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paged_view/paged_view.dart';

typedef PaginatedState<T> = PagingState<int, T, Object>;

sealed class PagingEvent {
  const PagingEvent();
}

/// Event to fetch the next page of data.
/// 
/// This event is used for both initial loading and subsequent page loading.
/// During refresh operations, it automatically handles fetching from page 1.
final class PagingFetchNext extends PagingEvent {
  const PagingFetchNext();
}

/// Event to refresh the current data.
/// 
/// Supports two types of refresh:
/// - [RefreshType.soft] (default): Keeps existing data visible while refreshing
/// - [RefreshType.hard]: Clears all data and shows loading indicator
final class PagingRefresh extends PagingEvent {
  /// The type of refresh operation to perform.
  final RefreshType type;
  
  /// Creates a refresh event.
  /// 
  /// [type] defaults to [RefreshType.soft] which keeps existing data visible
  /// while new data is being fetched.
  const PagingRefresh([this.type = RefreshType.soft]);
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

/// A BLoC for managing paginated data with refresh capabilities.
/// 
/// This bloc handles:
/// - Loading initial and subsequent pages
/// - Soft and hard refresh operations
/// - Request cancellation to prevent race conditions
/// - Error handling and state management
class PagingBloc<T> extends Bloc<PagingEvent, PaginatedState<T>> {
  /// Creates a new [PagingBloc].
  /// 
  /// [fetchFn] is called to fetch data for a given page key (starting from 1).
  /// It should return a [Future<List<T>>] containing the items for that page.
  PagingBloc({
    required this.fetchFn,
  }) : super(PaginatedState<T>()) {
    on<PagingFetchNext>(_onFetchNext);
    on<PagingRefresh>(_onRefresh);
  }

  /// Token to cancel ongoing fetch operations when needed.
  BlocCancelToken? _cancelToken;

  /// Function to fetch data for a given page key.
  /// 
  /// Page keys are 1-indexed integers. For refresh operations,
  /// this function will be called with pageKey = 1.
  final Future<List<T>> Function(int pageKey)? fetchFn;

  /// Handles [PagingFetchNext] events.
  /// 
  /// This method:
  /// 1. Prevents duplicate requests if already loading
  /// 2. Determines the correct page key (1 for refresh, next sequential for normal fetch)
  /// 3. Sets loading state for normal fetches (refresh state is already set)
  /// 4. Calls [fetchFn] and updates state with results or errors
  /// 5. Handles request cancellation to prevent race conditions
  Future<void> _onFetchNext(
    PagingFetchNext event,
    Emitter<PaginatedState<T>> emit,
  ) async {
    // Prevent duplicate requests
    if (state.isLoading) return;

    final isRefreshFetch = state.isRefreshing;
    
    // For normal pagination, check if there are more pages
    if (!isRefreshFetch && !state.hasNextPage) return;

    // Get the appropriate page key (1 for refresh, next sequential for normal)
    final pageKey = state.nextIntPageKey;

    // Handle edge case where last page was empty
    if (!isRefreshFetch && state.lastPageIsEmpty) {
      emit(state.copyWith(hasNextPage: false));
      return;
    }

    // Cancel any ongoing request to prevent race conditions
    _cancelToken?.cancel();
    final cancelToken = BlocCancelToken();
    _cancelToken = cancelToken;

    // Set loading state only for normal fetches (refresh state already set)
    if (!isRefreshFetch) {
      emit(state.copyWith(isLoading: true, error: null));
    }

    try {
      final result = await fetchFn!(pageKey);
      
      // Check if request was cancelled while fetching
      if (cancelToken.isCancelled) return;

      // Determine if this is the last page (empty result indicates no more data)
      final isLastPage = result.isEmpty;
      
      // Update state with new page data
      emit(state.appendPage(
        items: result,
        pageKey: pageKey,
        hasNextPage: !isLastPage,
      ));
    } catch (e) {
      // Only emit error if request wasn't cancelled
      if (!cancelToken.isCancelled) {
        emit(state.setError(e));
      }
    } finally {
      // Clean up cancel token
      _cancelToken = null;
    }
  }

  /// Handles [PagingRefresh] events.
  /// 
  /// This method:
  /// 1. Cancels any ongoing fetch to prevent race conditions
  /// 2. Sets the appropriate refresh state based on [RefreshType]
  /// 3. Triggers a [PagingFetchNext] event to start fetching from page 1
  Future<void> _onRefresh(
    PagingRefresh event,
    Emitter<PaginatedState<T>> emit,
  ) async {
    // Cancel any ongoing request to prevent conflicts
    _cancelToken?.cancel();
    
    // Set refresh state (soft keeps data visible, hard clears everything)
    emit(state.refresh(event.type));
    
    // Trigger fetch from page 1
    add(const PagingFetchNext());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
