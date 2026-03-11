import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/library_view_model.dart';
import '../../../theme/theme.dart';
import '../../../widgets/song/song_tile.dart';

class LibraryContent extends StatelessWidget {
  const LibraryContent({super.key});

  @override
  Widget build(BuildContext context) {
    LibraryViewModel mv = context.watch<LibraryViewModel>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text("Library", style: AppTextStyles.heading),
          const SizedBox(height: 50),
          Expanded(child: _buildBody(context, mv)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryViewModel mv) {
    return switch (mv.songsAsync) {
      // ── Loading state ──────────────────────────────────────────────────────
      AsyncLoading() => const Center(child: CircularProgressIndicator()),

      // ── Error state ────────────────────────────────────────────────────────
      AsyncError(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load songs:\n$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: mv.retry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

      // ── Success state ──────────────────────────────────────────────────────
      AsyncData(:final value) => ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) => SongTile(
            song: value[index],
            isPlaying: mv.isSongPlaying(value[index]),
            onTap: () => mv.start(value[index]),
          ),
        ),
    };
  }
}
