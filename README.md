# Paged View

A Flutter package that provides pagination widgets for displaying large datasets in lists, grids, and page views with lazy loading capabilities.

## Features

- **PagedListView** - Paginated list with optional separators
- **PagedGridView** - Paginated grid layout
- **PagedPageView** - Paginated page view for swiping through items
- **PagedSliverList** - Sliver list for use in CustomScrollView
- **PagedSliverGrid** - Sliver grid for use in CustomScrollView
- **Customizable indicators** - Built-in progress, error, and empty state indicators
- **State management agnostic** - Works with any state management solution
- **Flexible architecture** - Implement your own PagingState or use the provided PaginatedState

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  paged_view: ^5.1.0
```

## Basic Usage

### 1. Define your state

Implement the `PagingState` interface or use the provided `PaginatedState`:

```dart
// Using the provided PaginatedState
PagingState<int, Photo> state = const PaginatedState<int, Photo>();

// Or implement your own
class MyPagingState implements PagingState<int, Photo> {
  // Implementation details...
}
```

### 2. Use with PagedListView

```dart
PagedListView<int, Photo>(
  state: state,
  fetchNextPage: () => loadNextPage(),
  builderDelegate: PagedChildBuilderDelegate<Photo>(
    itemBuilder: (context, item, index) => ListTile(
      title: Text(item.title),
      subtitle: Text(item.description),
    ),
  ),
)
```

### 3. With separators

```dart
PagedListView<int, Photo>.separated(
  state: state,
  fetchNextPage: () => loadNextPage(),
  builderDelegate: PagedChildBuilderDelegate<Photo>(
    itemBuilder: (context, item, index) => ListTile(
      title: Text(item.title),
    ),
  ),
  separatorBuilder: (context, index) => const Divider(),
)
```

## Advanced Usage

### PagedGridView

```dart
PagedGridView<int, Photo>(
  state: state,
  fetchNextPage: () => loadNextPage(),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 1.0,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  builderDelegate: PagedChildBuilderDelegate<Photo>(
    itemBuilder: (context, item, index) => Image.network(item.imageUrl),
  ),
)
```

### PagedPageView

```dart
PagedPageView<int, Photo>(
  state: state,
  fetchNextPage: () => loadNextPage(),
  builderDelegate: PagedChildBuilderDelegate<Photo>(
    itemBuilder: (context, item, index) => PhotoCard(photo: item),
  ),
)
```

### With CustomScrollView

```dart
CustomScrollView(
  slivers: [
    const SliverAppBar(title: Text('Photos')),
    PagedSliverGrid<int, Photo>(
      state: state,
      fetchNextPage: () => loadNextPage(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1.0,
      ),
      builderDelegate: PagedChildBuilderDelegate<Photo>(
        itemBuilder: (context, item, index) => Image.network(item.imageUrl),
      ),
    ),
  ],
)
```

## State Management Examples

### With BLoC

```dart
class PhotoBloc extends Bloc<PhotoEvent, PaginatedState<int, Photo>> {
  PhotoBloc() : super(const PaginatedState<int, Photo>()) {
    on<LoadNextPage>(_onLoadNextPage);
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<PaginatedState<int, Photo>> emit,
  ) async {
    if (state.isLoading) return;
    
    emit(state.copyWith(isLoading: true));
    
    try {
      final nextPageKey = (state.keys?.lastOrNull ?? 0) + 1;
      final newPhotos = await photoRepository.getPhotos(nextPageKey);
      
      emit(state.copyWith(
        pages: [...?state.pages, newPhotos],
        keys: [...?state.keys, nextPageKey],
        hasNextPage: newPhotos.isNotEmpty,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(error: error, isLoading: false));
    }
  }
}
```

### Direct state management

```dart
class PhotoPage extends StatefulWidget {
  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  PagingState<int, Photo> _state = const PaginatedState<int, Photo>();

  void _fetchNextPage() async {
    if (_state.isLoading) return;

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final nextPageKey = (_state.keys?.lastOrNull ?? 0) + 1;
      final newPhotos = await RemoteApi.getPhotos(nextPageKey);
      final isLastPage = newPhotos.isEmpty;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, newPhotos],
          keys: [...?_state.keys, nextPageKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Photo>(
      state: _state,
      fetchNextPage: _fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate<Photo>(
        itemBuilder: (context, item, index) => PhotoTile(photo: item),
      ),
    );
  }
}
```

## Customization

### Custom indicators

```dart
PagedChildBuilderDelegate<Photo>(
  itemBuilder: (context, item, index) => PhotoTile(photo: item),
  firstPageProgressIndicatorBuilder: (context) => 
    const Center(child: CircularProgressIndicator()),
  newPageProgressIndicatorBuilder: (context) => 
    const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    ),
  firstPageErrorIndicatorBuilder: (context) => 
    ErrorWidget(onRetry: () => retryFirstPage()),
  newPageErrorIndicatorBuilder: (context) => 
    ErrorWidget(onRetry: () => retryNewPage()),
  noItemsFoundIndicatorBuilder: (context) => 
    const Center(child: Text('No items found')),
)
```

## Examples

Check out the `/example` folder for complete working examples:

- **list_view.dart** - Basic list with BLoC state management
- **sliver_grid.dart** - Grid layout with search functionality
- **page_view.dart** - Page view with direct state management

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.