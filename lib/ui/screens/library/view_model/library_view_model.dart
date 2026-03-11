import 'package:flutter/material.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../states/player_state.dart';
import '../../../../model/songs/song.dart';

sealed class AsyncValue<T> {
  const AsyncValue();
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncValue<T> {
  final T value;
  const AsyncData(this.value);
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  const AsyncError(this.error);
}

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final PlayerState playerState;

  // Starts as loading; transitions to AsyncData or AsyncError after fetch.
  AsyncValue<List<Song>> _songsAsync = const AsyncLoading();

  LibraryViewModel({required this.songRepository, required this.playerState}) {
    playerState.addListener(notifyListeners);
    _init();
  }

  AsyncValue<List<Song>> get songsAsync => _songsAsync;

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  void _init() async {
    _songsAsync = const AsyncLoading();
    notifyListeners();

    try {
      final songs = await songRepository.fetchSongs();
      _songsAsync = AsyncData(songs);
    } catch (e) {
      _songsAsync = AsyncError(e);
    }

    notifyListeners();
  }

  /// Retry fetching songs (useful from the error state).
  void retry() => _init();

  bool isSongPlaying(Song song) => playerState.currentSong == song;

  void start(Song song) => playerState.start(song);
  void stop(Song song) => playerState.stop();
}
