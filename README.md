# Flutter Paged Views

<p align="center">
  <img src="https://img.shields.io/badge/flutter-paged_views-blue" alt="Flutter Paged Views" />
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_paged_views"><img src="https://img.shields.io/pub/v/flutter_paged_views.svg" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="MIT License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/platform-flutter-ff69b4.svg" alt="Flutter Platform"></a>
</p>

---

A **minimal, flexible pagination library** for Flutter that provides essential widgets for building paginated lists, grids, and page views. Designed to work seamlessly with any state management solution, especially BLoC/Cubit.

## ✨ Key Features

- **🎯 Minimal & Focused** - Only the essential pagination widgets you need
- **🏗️ State Management Agnostic** - Works with BLoC, Cubit, Riverpod, or any state solution
- **📱 Essential Widgets** - PagedListView, PagedGridView, PagedPageView, and their Sliver variants
- **⚙️ Highly Customizable** - Bring your own indicators, state management, and styling
- **🪶 Lightweight** - Minimal dependencies, maximum flexibility

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_paged_views: ^1.0.0
```

## 🚀 Quick Start

### With BLoC/Cubit

```dart
class PhotoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoCubit, PhotoState>(
      builder: (context, state) {
        return PagedListView<int, Photo>(
          state: state,
          fetchNextPage: () => context.read<PhotoCubit>().loadNextPage(),
          builderDelegate: PagedChildBuilderDelegate<Photo>(
            itemBuilder: (context, photo, index) => PhotoTile(photo: photo),
            firstPageProgressIndicatorBuilder: (context) => 
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (context) => 
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            firstPageErrorIndicatorBuilder: (context) => 
                ErrorWidget(onRetry: () => context.read<PhotoCubit>().retry()),
            noItemsFoundIndicatorBuilder: (context) => 
                const Center(child: Text('No photos found')),
          ),
        );
      },
    );
  }
}
```

### Your State Implementation

```dart
// Implement the PagingState interface in your BLoC/Cubit state
class PhotoState implements PagingState<int, Photo> {
  const PhotoState({
    this.photos = const [],
    this.pageKeys = const [],
    this.error,
    this.hasNextPage = true,
    this.isLoading = false,
  });

  final List<Photo> photos;
  final List<int> pageKeys;
  final Object? error;
  final bool hasNextPage;
  final bool isLoading;

  @override
  List<List<Photo>> get pages => photos.isEmpty 
      ? [] 
      : [photos]; // Adapt to your page structure

  @override
  List<int> get keys => pageKeys;

  @override
  PagingState<int, Photo> copyWith({
    List<List<Photo>>? pages,
    List<int>? keys,
    Object? error,
    bool? hasNextPage,
    bool? isLoading,
  }) {
    // Your copyWith implementation
  }

  @override
  PagingState<int, Photo> reset() {
    return const PhotoState();
  }
}
```

## 🎨 Available Widgets

### Lists
- `PagedListView` - Scrollable list with pagination
- `PagedSliverList` - Sliver version for CustomScrollView

### Grids
- `PagedGridView` - Grid with pagination support
- `PagedSliverGrid` - Sliver grid for CustomScrollView

### Page Views
- `PagedPageView` - PageView with pagination

### Separated Lists
```dart
PagedListView.separated(
  state: state,
  fetchNextPage: fetchNextPage,
  builderDelegate: builderDelegate,
  separatorBuilder: (context, index) => const Divider(),
)
```

## 🔧 Customization

### Custom Indicators

```dart
PagedChildBuilderDelegate<Item>(
  itemBuilder: (context, item, index) => ItemTile(item: item),
  
  // Customize loading indicators
  firstPageProgressIndicatorBuilder: (context) => 
      const CustomLoadingWidget(),
  
  // Customize error indicators  
  firstPageErrorIndicatorBuilder: (context) => 
      CustomErrorWidget(onRetry: retryCallback),
  
  // Customize empty state
  noItemsFoundIndicatorBuilder: (context) => 
      const CustomEmptyWidget(),
)
```

### With Custom ScrollView

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Photos')),
    PagedSliverList<int, Photo>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: builderDelegate,
    ),
  ],
)
```

## 🏗️ Architecture

This library provides the UI widgets while leaving state management entirely up to you:

1. **Implement `PagingState`** in your state class
2. **Use your preferred state management** (BLoC, Cubit, Riverpod, etc.)
3. **Pass state and callback** to the paged widgets
4. **Customize indicators** to match your app's design

## 🤝 State Management Examples

### With Cubit
```dart
class PhotoCubit extends Cubit<PhotoState> {
  PhotoCubit() : super(const PhotoState());

  Future<void> loadNextPage() async {
    if (state.isLoading) return;
    
    emit(state.copyWith(isLoading: true));
    
    try {
      final photos = await api.getPhotos(state.nextPageKey);
      emit(state.copyWith(
        photos: [...state.photos, ...photos],
        hasNextPage: photos.isNotEmpty,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(error: error, isLoading: false));
    }
  }
}
```

### With Riverpod
```dart
final photoProvider = StateNotifierProvider<PhotoNotifier, PhotoState>((ref) {
  return PhotoNotifier();
});

class PhotoNotifier extends StateNotifier<PhotoState> {
  PhotoNotifier() : super(const PhotoState());

  Future<void> loadNextPage() async {
    // Similar implementation
  }
}
```

## 📝 License

MIT License. See [LICENSE](LICENSE) for details.

## 🙌 Contributing

Contributions are welcome! This library focuses on providing minimal, essential pagination widgets. Please keep contributions aligned with this philosophy.

---

**Built with ❤️ for the Flutter community**