import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_state.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventInitial ||
              state is EventDetailLoading ||
              state is EventDetailLoaded ||
              state is EventDetailError) {
            context.read<EventBloc>().add(GetAllEventsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventAllLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventAllError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is EventAllLoaded) {
            final events = state.events;
            if (events.isEmpty) {
              return const Center(child: Text('Belum ada event'));
            }
            return _EventListView(events: events);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EventListView extends StatefulWidget {
  final List<EventEntity> events;

  const _EventListView({required this.events});

  @override
  State<_EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<_EventListView> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);

    if (widget.events.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!mounted) return;
        final nextPage = _currentPage < widget.events.length - 1
            ? _currentPage + 1
            : 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.events.length,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    context.push('${InitialRoutes.eventDetail}/${event.id}');
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'event_image_${event.id}',
                              child: CachedNetworkImage(
                                imageUrl: event.cover,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              event.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.events.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 5),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.orange
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
