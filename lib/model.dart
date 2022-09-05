import 'package:flutter/material.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String image;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.image,
  });
}

class Playlist extends ChangeNotifier {
  static Playlist? _instance;
  Playlist._();
  factory Playlist() => _instance ??= Playlist._();

  List<Song> list = List.empty(growable: true);

  Song? get now => list.isEmpty ? null : list[_index];

  int _index = 0;
  int get index => _index;

  void add(Song s) {
    list.add(s);
    notifyListeners();
  }

  void prev() {
    _index = _index == 0 ? list.length - 1 : _index - 1;
    notifyListeners();
  }

  void next() {
    _index = _index == list.length - 1 ? 0 : _index + 1;
    notifyListeners();
  }

  void clear() {
    _index = 0;
    list.clear();
    notifyListeners();
  }
}

const List<Song> ids = [
  Song(
    id: 'DPEtmqvaKqY',
    artist: '고세구',
    image: '',
    title: '팬서비스',
  ),
  Song(
    id: 'JY-gJkMuJ94',
    artist: '이세계 아이돌',
    image: '',
    title: '겨울봄',
  ),
  Song(
    id: '6hEvgKL0ClA',
    artist: '릴파',
    image: '',
    title: 'Promise',
  ),
  Song(
    id: 'Brf3LWwNVTk',
    artist: '이세계 아이돌',
    image: '',
    title: 'LOVE DIVE',
  ),
  Song(
    id: 'rFxJjpSeXHI',
    artist: '주르르',
    image: '',
    title: 'SCIENTIST',
  ),
  Song(
    id: 'K-5WdjbCYnk',
    artist: '릴파, 뢴트게늄',
    image: '',
    title: '마지막 재회',
  ),
  Song(
    id: 'Empfi8q0aas',
    artist: '이세계 아이돌',
    image: '',
    title: '이세돌 싸이퍼',
  ),
  Song(
    id: '1UbyyaDc8x0',
    artist: '릴파',
    image: '',
    title: '세사빠',
  ),
  Song(
    id: 'fgSXAKsq-Vo',
    artist: '이세계 아이돌',
    image: '',
    title: '리와인드',
  ),
];
