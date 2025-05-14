import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart' show JustAudioBackground, MediaItem;
Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TestFile(),
    );
  }
}
class TestFile extends StatefulWidget {
  const TestFile({super.key});

  @override
  State<TestFile> createState() => _TestFileState();
}

class _TestFileState extends State<TestFile> {
  static int _nextMediaId = 0;
  late AudioPlayer _player;
  bool isLoading = true;

  static final _playlist = [
    ClippingAudioSource(
      start: const Duration(seconds: 60),
      end: const Duration(seconds: 90),
      child: AudioSource.uri(
        Uri.parse(
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
        ),
      ),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science (30 seconds)",
        artUri: Uri.parse(
          "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer(maxSkipsOnError: 3);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.black),
    );
    _init();
  }

  Future<void> _init() async {
    _player.errorStream.listen((e) {
      print('A stream error occurred: $e');
    });
    try {
      // Preloading audio is not currently supported on Linux.
      await _player.setAudioSources(_playlist,
  );
      setState(() {
        isLoading = false;
      });
    } on PlayerException catch (e) {
      // Catch load errors: 404, invalid url...
      print("Error loading playlist: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test")),
      body:
          isLoading
              ? CircularProgressIndicator()
              : Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _player.play();
                    },
                    child: const Text("Play"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _player.stop();
                    },
                    child: const Text("Stop"),
                  ),
                ],
              ),
    );
  }
}