import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/event/event_state.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is! EventDetailLoaded || state.event.id != eventId) {
            context.read<EventBloc>().add(GetEventByIdEvent(eventId));
          }

          if (state is EventDetailLoading || state is EventInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventDetailError || state is EventAllError) {
            final message = state is EventDetailError
                ? state.message
                : (state as EventAllError).message;
            return Center(
              child: Text(message, style: const TextStyle(color: Colors.red)),
            );
          }

          if (state is EventDetailLoaded) {
            return _buildContent(context, event: state.event);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required EventEntity event}) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, event),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Detail Event',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nikmati promo spesial dan penawaran menarik di event ini.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.7,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildSliverHeader(BuildContext context, EventEntity event) {
    return SliverAppBar(
      expandedHeight: 280.0,
      backgroundColor: Colors.grey[50],
      elevation: 0,
      pinned: true,
      stretch: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.5),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'event_image_${event.id}',
          child: CachedNetworkImage(
            imageUrl: event.cover,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
            imageBuilder: (context, imageProvider) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black45],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
