// file: banner_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner_detail/banner_detail_bloc.dart';

class BannerDetailPage extends StatelessWidget {
  final String bannerId;
  const BannerDetailPage({super.key, required this.bannerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<BannerDetailBloc>()..add(FetchBannerDetail(id: bannerId)),
      child: const BannerDetailView(),
    );
  }
}

class BannerDetailView extends StatelessWidget {
  const BannerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<BannerDetailBloc, BannerDetailState>(
        builder: (context, state) {
          if (state is BannerDetailLoading || state is BannerDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BannerDetailLoaded) {
            return _buildContent(context, bannerData: state.banner);
          }
          if (state is BannerDetailError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      // DIHAPUS: persistentFooterButtons beserta isinya telah dihapus dari sini.
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required BannerEntity bannerData,
  }) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, bannerData),
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
                  bannerData.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (bannerData.user?.name.isNotEmpty ?? false) ...[
                  _buildMetadataRow(
                    context,
                    icon: Icons.person_outline,
                    text: 'Dipublikasikan oleh ${bannerData.user!.name}',
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Deskripsi Promo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bannerData.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.7,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Memberi sedikit ruang di bagian paling bawah halaman
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildMetadataRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(BuildContext context, BannerEntity bannerData) {
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
          tag: 'banner_image_${bannerData.id}',
          child: CachedNetworkImage(
            imageUrl: bannerData.photo,
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
