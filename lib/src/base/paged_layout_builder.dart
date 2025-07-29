import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paged_view/src/base/paged_child_builder_delegate.dart';
import 'package:paged_view/src/core/extensions.dart';
import 'package:paged_view/src/core/paging_state.dart';
import 'package:paged_view/src/core/paging_status.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../defaults/defaults.dart';

/// Called to request a new page of data.
typedef NextPageCallback = VoidCallback;

typedef CompletedListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder? noMoreItemsIndicatorBuilder,
);

typedef ErrorListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder newPageErrorIndicatorBuilder,
);

typedef LoadingListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  WidgetBuilder newPageProgressIndicatorBuilder,
);

/// The Flutter layout protocols supported by [PagedLayoutBuilder].
enum PagedLayoutProtocol { sliver, box }

/// Facilitates creating infinitely scrolled paged layouts.
///
/// Combines a [PagingController] with a
/// [PagedChildBuilderDelegate] and calls the supplied
/// [loadingListingBuilder], [errorListingBuilder] or
/// [completedListingBuilder] for filling in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid], [PagedListView],
/// [PagedGridView], [PagedMasonryGridView], or [PagedPageView].
class PagedLayoutBuilder<PageKeyType, ItemType, ErrorType extends Object> extends StatefulWidget {
  const PagedLayoutBuilder({
    required this.state,
    required this.fetchNextPage,
    required this.builderDelegate,
    required this.loadingListingBuilder,
    required this.errorListingBuilder,
    required this.completedListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
  });

  /// The paging state for this layout.
  final PagingState<PageKeyType, ItemType, ErrorType> state;

  /// A callback function that is triggered to request a new page of data.
  final NextPageCallback fetchNextPage;

  /// The delegate for building the UI pieces of scrolling paged listings.
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// The builder for an in-progress listing.
  final LoadingListingBuilder loadingListingBuilder;

  /// The builder for an in-progress listing with a failed request.
  final ErrorListingBuilder errorListingBuilder;

  /// The builder for a completed listing.
  final CompletedListingBuilder completedListingBuilder;

  /// Whether the extent of the first page indicators should be determined by
  /// the contents being viewed.
  ///
  /// If the paged layout builder does not shrink wrap, then the first page
  /// indicators will expand to the maximum allowed size. If the paged layout
  /// builder has unbounded constraints, then [shrinkWrapFirstPageIndicators]
  /// must be true.
  ///
  /// Defaults to false.
  final bool shrinkWrapFirstPageIndicators;

  /// The layout protocol of the widget you're using this to build.
  ///
  /// For example, if [PagedLayoutProtocol.sliver] is specified, then
  /// [loadingListingBuilder], [errorListingBuilder], and
  /// [completedListingBuilder] have to return a Sliver widget.
  final PagedLayoutProtocol layoutProtocol;

  @override
  State<PagedLayoutBuilder<PageKeyType, ItemType, ErrorType>> createState() =>
      _PagedLayoutBuilderState<PageKeyType, ItemType, ErrorType>();
}

class _PagedLayoutBuilderState<PageKeyType, ItemType, ErrorType extends Object>
    extends State<PagedLayoutBuilder<PageKeyType, ItemType, ErrorType>> {
  PagingState<PageKeyType, ItemType, ErrorType> get _state => widget.state;

  NextPageCallback get _fetchNextPage =>
      // We make sure to only schedule the fetch after the current build is done.
      // This is important to prevent recursive builds.
      () => WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.fetchNextPage();
          });

  PagedChildBuilderDelegate<ItemType> get _builderDelegate => widget.builderDelegate;

  bool get _shrinkWrapFirstPageIndicators => widget.shrinkWrapFirstPageIndicators;

  PagedLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  WidgetBuilder get _firstPageErrorIndicatorBuilder =>
      _builderDelegate.firstPageErrorIndicatorBuilder ??
      (_) => FirstPageErrorIndicator(
            onTryAgain: _fetchNextPage,
          );

  WidgetBuilder get _newPageErrorIndicatorBuilder =>
      _builderDelegate.newPageErrorIndicatorBuilder ??
      (_) => NewPageErrorIndicator(
            onTap: _fetchNextPage,
          );

  WidgetBuilder get _firstPageProgressIndicatorBuilder =>
      _builderDelegate.firstPageProgressIndicatorBuilder ??
      (_) => const FirstPageProgressIndicator();

  WidgetBuilder get _newPageProgressIndicatorBuilder =>
      _builderDelegate.newPageProgressIndicatorBuilder ?? (_) => const NewPageProgressIndicator();

  WidgetBuilder get _noItemsFoundIndicatorBuilder =>
      _builderDelegate.noItemsFoundIndicatorBuilder ?? (_) => const NoItemsFoundIndicator();

  WidgetBuilder? get _noMoreItemsIndicatorBuilder => _builderDelegate.noMoreItemsIndicatorBuilder;

  int get _invisibleItemsThreshold => _builderDelegate.invisibleItemsThreshold;

  int get _itemCount => _state.items?.length ?? 0;

  bool get _hasNextPage => _state.hasNextPage;

  /// Avoids duplicate requests on rebuilds.
  bool _hasRequestedNextPage = false;

  @override
  void didUpdateWidget(covariant PagedLayoutBuilder<PageKeyType, ItemType, ErrorType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (_state.status == PagingStatus.ongoing) {
        _hasRequestedNextPage = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PagedLayoutAnimator(
      animateTransitions: _builderDelegate.animateTransitions,
      transitionDuration: _builderDelegate.transitionDuration,
      layoutProtocol: _layoutProtocol,
      isRefreshing: _state.isRefreshing,
      child: switch (_state.status) {
        PagingStatus.loadingFirstPage => _FirstPageStatusIndicatorBuilder(
            key: const ValueKey(PagingStatus.loadingFirstPage),
            builder: _firstPageProgressIndicatorBuilder,
            shrinkWrap: _shrinkWrapFirstPageIndicators,
            layoutProtocol: _layoutProtocol,
          ),
        PagingStatus.firstPageError => _FirstPageStatusIndicatorBuilder(
            key: const ValueKey(PagingStatus.firstPageError),
            builder: _firstPageErrorIndicatorBuilder,
            shrinkWrap: _shrinkWrapFirstPageIndicators,
            layoutProtocol: _layoutProtocol,
          ),
        PagingStatus.noItemsFound => _FirstPageStatusIndicatorBuilder(
            key: const ValueKey(PagingStatus.noItemsFound),
            builder: _noItemsFoundIndicatorBuilder,
            shrinkWrap: _shrinkWrapFirstPageIndicators,
            layoutProtocol: _layoutProtocol,
          ),
        PagingStatus.ongoing => widget.loadingListingBuilder(
            context,
            // We must create this closure to close over the [itemList]
            // value. That way, we are safe if [itemList] value changes
            // while Flutter rebuilds the widget (due to animations, for
            // example.)
            (context, index) => _buildListItemWidget(
              context,
              index,
              _state.items ?? [],
            ),
            _itemCount,
            _newPageProgressIndicatorBuilder,
          ),
        PagingStatus.subsequentPageError => widget.errorListingBuilder(
            context,
            (context, index) => _buildListItemWidget(
              context,
              index,
              _state.items ?? [],
            ),
            _itemCount,
            (context) => _newPageErrorIndicatorBuilder(context),
          ),
        PagingStatus.completed => widget.completedListingBuilder(
            context,
            (context, index) => _buildListItemWidget(
              context,
              index,
              _state.items ?? [],
            ),
            _itemCount,
            _noMoreItemsIndicatorBuilder,
          ),
      },
    );
  }

  /// Connects the [_pagingController] with the [_builderDelegate] in order to
  /// create a list item widget and request more items if needed.
  Widget _buildListItemWidget(
    BuildContext context,
    int index,
    List<ItemType> itemList,
  ) {
    // Don't trigger pagination during refresh operations
    if (!_hasRequestedNextPage && !_state.isRefreshing) {
      final maxIndex = max(0, _itemCount - 1);
      final triggerIndex = max(0, maxIndex - _invisibleItemsThreshold);

      // It is important to check whether we are past the trigger, not just at it.
      // This is because otherwise, large tresholds will place the trigger behind the user,
      // Leading to the refresh never being triggered.
      // This behaviour is okay because we make sure not to excessively request pages.
      final hasPassedTrigger = index >= triggerIndex;

      if (_hasNextPage && hasPassedTrigger) {
        _hasRequestedNextPage = true;
        _fetchNextPage();
      }
    }
    if (index >= itemList.length) {
      // If the index is out of bounds, we return an empty container.
      // This can happen if the list is empty or if the index exceeds the number of items.
      return const SizedBox.shrink();
    }
    final item = itemList[index];
    return _builderDelegate.itemBuilder(context, item, index);
  }
}

class _PagedLayoutAnimator extends StatelessWidget {
  const _PagedLayoutAnimator({
    required this.child,
    required this.animateTransitions,
    required this.transitionDuration,
    required this.layoutProtocol,
    required this.isRefreshing,
  });

  final Widget child;
  final bool animateTransitions;
  final Duration transitionDuration;
  final PagedLayoutProtocol layoutProtocol;
  final bool isRefreshing;
  @override
  Widget build(BuildContext context) {
    if (!animateTransitions) return child;
    return switch (layoutProtocol) {
      PagedLayoutProtocol.sliver => SliverAnimatedOpacity(
          opacity: isRefreshing ? 0.5 : 1.0,
          duration: transitionDuration,
          sliver: SliverIgnorePointer(
            ignoring: isRefreshing,
            sliver: SliverAnimatedSwitcher(
              duration: transitionDuration,
              child: child,
            ),
          ),
        ),
      PagedLayoutProtocol.box => AnimatedOpacity(
          opacity: isRefreshing ? 0.5 : 1.0,
          duration: transitionDuration,
          child: IgnorePointer(
            ignoring: isRefreshing,
            child: AnimatedSwitcher(
              duration: transitionDuration,
              child: child,
            ),
          ),
        ),
    };
  }
}

class _FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const _FirstPageStatusIndicatorBuilder({
    super.key,
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
  });

  final WidgetBuilder builder;
  final bool shrinkWrap;
  final PagedLayoutProtocol layoutProtocol;

  @override
  Widget build(BuildContext context) {
    return switch (layoutProtocol) {
      PagedLayoutProtocol.sliver => shrinkWrap
          ? SliverToBoxAdapter(child: builder(context))
          : SliverFillRemaining(
              hasScrollBody: false,
              child: builder(context),
            ),
      PagedLayoutProtocol.box => shrinkWrap ? builder(context) : Center(child: builder(context)),
    };
  }
}
