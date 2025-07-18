import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_example/common/bloc.dart';
import 'package:infinite_example/common/search_input.dart';
import 'package:infinite_example/remote/remote.dart';
import 'package:paged_view/paged_view.dart';

class SliverGridScreen extends StatefulWidget {
  const SliverGridScreen({super.key});

  @override
  State<SliverGridScreen> createState() => _SliverGridScreenState();
}

class _SliverGridScreenState extends State<SliverGridScreen> {
  late final PagingBloc<Photo> bloc = PagingBloc(
    fetchFn: (pageKey) => RemoteApi.getPhotos(pageKey),
  );

  @override
  void initState() {
    super.initState();

    bloc.add(PagingFetchNext());
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => bloc,
        child: BlocBuilder<PagingBloc<Photo>, PaginatedState<Photo>>(builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final bloc = context.read<PagingBloc<Photo>>();
              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async => bloc.add(PagingRefresh()),
                  child: CustomScrollView(
                    slivers: [
                      SearchInputSliver(
                        onChanged: (searchTerm) => bloc.add(PagingChangeSearch(searchTerm)),
                        getSuggestions: (searchTerm) => (state.items
                                ?.expand((photo) => photo.title.split(' '))
                                .where((e) => e.contains(searchTerm))
                                .toSet()
                                .toList() ??
                            []),
                      ),
                      PagedSliverGrid<int, Photo>(
                        state: state,
                        fetchNextPage: () => bloc.add(PagingFetchNext()),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          childAspectRatio: 1 / 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          maxCrossAxisExtent: 200,
                        ),
                        builderDelegate: PagedChildBuilderDelegate(
                          itemBuilder: (context, item, index) => CachedNetworkImage(
                            imageUrl: item.thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      );
}
