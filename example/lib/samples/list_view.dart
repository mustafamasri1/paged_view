import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_example/common/list_tile.dart';
import 'package:infinite_example/remote/api.dart';
import 'package:infinite_example/remote/item.dart';
import 'package:paged_view/paged_view.dart';

import '../common/bloc.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  late final bloc = PagingBloc<Photo>(
    fetchFn: (pageKey) => RemoteApi.getPhotos(pageKey),
  );
  @override
  void initState() {
    super.initState();
    bloc.add(const PagingFetchNext());
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => bloc,
        child: Scaffold(
          appBar: AppBar(
            title: BlocBuilder<PagingBloc<Photo>, DefaultPaginatedState<int, Photo>>(
              builder: (context, state) {
                return Text(
                  '${state.refreshCompletedAt?.toLocal().toIso8601String() ?? 'Never'}',
                );
              },
            ),
          ),
          body: BlocBuilder<PagingBloc<Photo>, DefaultPaginatedState<int, Photo>>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PagingBloc<Photo>>().add(PagingRefresh());
                  await bloc.stream.firstWhere(
                    (state) => !state.isRefreshing,
                    orElse: () => state,
                  );
                },
                child: PagedListView<int, Photo>.separated(
                  state: state,
                  fetchNextPage: () => bloc.add(const PagingFetchNext()),
                  itemExtent: 48,
                  builderDelegate: PagedChildBuilderDelegate(
                    animateTransitions: true,
                    itemBuilder: (context, item, index) => ImageListTile(
                      key: ValueKey(item.id),
                      item: item,
                    ),
                  ),
                  separatorBuilder: (context, index) => const Divider(),
                ),
              );
            },
          ),
        ),
      );
}
