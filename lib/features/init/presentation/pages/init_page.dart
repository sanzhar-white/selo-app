import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:selo/core/constants/routes.dart';
import 'package:selo/features/init/presentation/provider/init_provider.dart';
import 'package:selo/generated/l10n.dart';
import 'package:talker/talker.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/di/di.dart';

class InitPage extends ConsumerStatefulWidget {
  const InitPage({super.key});

  @override
  ConsumerState<InitPage> createState() => _InitPageState();
}

class _InitPageState extends ConsumerState<InitPage> {
  late VideoPlayerController _controller;
  bool _videoInitialized = false;
  bool _videoError = false;
  bool _videoFinished = false;
  final double _videoSizeFactor = 0.5;

  final Talker talker = di<Talker>();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initStateProvider.notifier).initialize();
    });
  }

  Future<void> _initializeVideo() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, 'splash_video.mp4'));
      await rootBundle.load('assets/videos/splash_video.mp4').then((data) {
        tempFile.writeAsBytesSync(data.buffer.asUint8List());
      });

      _controller = VideoPlayerController.file(tempFile);
      await _controller.initialize();

      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          setState(() {
            _videoFinished = true;
          });
        }
      });

      _controller.play();
      setState(() {
        _videoInitialized = true;
      });
    } catch (e) {
      talker.error('Error initializing video: $e');
      setState(() {
        _videoError = true;
      });
    }
  }

  @override
  void dispose() {
    if (_videoInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(initStateProvider);

    if (_videoFinished && initState.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (initState.user != null) {
          context.go(Routes.homePage);
        } else {
          context.go(Routes.authenticationPage);
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xff2a5a46)),
          if (_videoInitialized)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * _videoSizeFactor,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          if (!_videoInitialized && !_videoError)
            const Center(child: SizedBox.shrink()),
          if (_videoError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 24),
                  if (initState.error != null)
                    Column(
                      children: [
                        SelectableText(
                          '${S.of(context)!.error}: ${initState.error}, ${initState.stackTrace}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(initStateProvider.notifier).initialize();
                          },
                          child: Text(S.of(context)!.retry),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
