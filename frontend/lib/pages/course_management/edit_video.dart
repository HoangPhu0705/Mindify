import 'dart:async';
import 'dart:developer';

import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_management/crop_page.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_editor_2/domain/entities/file_format.dart';
import 'package:video_editor_2/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final XFile file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  int cropGridViewerKey = 0;

  late final _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(minutes: 20),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 16 / 9)
        .then((_) => setState(() {}))
        .catchError(
      (error) {
        // handle minumum duration bigger than video duration error
        Navigator.pop(context);
      },
      test: (e) => e is VideoMinDurationError,
    );
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    try {
      final video = await exportVideo(
        onStatistics: (stats) => _exportingProgress.value =
            stats.getProgress(_controller.trimmedDuration.inMilliseconds),
      );

      _isExporting.value = false;

      if (mounted) {
        Navigator.pop(context, video);
      }
    } catch (e) {
      showErrorToast(context, "Error on export video :(");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CropGridViewer.preview(
                            key: ValueKey(cropGridViewerKey),
                            controller: _controller,
                          ),
                          AnimatedBuilder(
                            animation: _controller.video,
                            builder: (_, __) => AnimatedOpacity(
                              opacity: _controller.isPlaying ? 0.0 : 1.0,
                              duration: const Duration(
                                milliseconds: 100,
                              ),
                              child: GestureDetector(
                                onTap: _controller.video.play,
                                child: const Icon(
                                  Icons.play_circle_fill_outlined,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.content_cut,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Trim',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _trimSlider(),
                    ),
                    _topNavBar(),
                    ValueListenableBuilder(
                      valueListenable: _isExporting,
                      builder: (_, bool export, __) => AnimatedOpacity(
                        opacity: export ? 1.0 : 0.0,
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        child: AlertDialog(
                          title: ValueListenableBuilder(
                            valueListenable: _exportingProgress,
                            builder: (_, double value, __) => Text(
                              "Exporting video ${(value * 100).ceil()}%",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const Center(
                child: MyLoading(
                  width: 30,
                  height: 30,
                  color: AppColors.deepBlue,
                ),
              ),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            IconButton(
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.left),
              icon: const Icon(
                Icons.rotate_left,
                color: Colors.white,
              ),
              tooltip: 'Rotate unclockwise',
            ),
            IconButton(
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.right),
              icon: const Icon(
                Icons.rotate_right,
                color: Colors.white,
              ),
              tooltip: 'Rotate clockwise',
            ),
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropScreen(
                      controller: _controller,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.crop,
                color: Colors.white,
              ),
              tooltip: 'Open crop screen',
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            IconButton(
              onPressed: _exportVideo,
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final duration = _controller.videoDuration.inSeconds;
          final pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(
              children: [
                if (pos.isFinite)
                  Text(
                    formatter(Duration(seconds: pos.toInt())),
                    style: const TextStyle(color: Colors.white),
                  ),
                const Expanded(child: SizedBox()),
                AnimatedOpacity(
                  opacity: _controller.isTrimming ? 1.0 : 0.0,
                  duration: const Duration(
                    milliseconds: 300,
                  ), // adjust the duration as needed
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatter(_controller.startTrim),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(formatter(_controller.endTrim),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            textStyle: const TextStyle(
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  //--------//
  // EXPORT //
  //--------//

  Future<String> ioOutputPath(String filePath, FileFormat format) async {
    final tempPath = (await getTemporaryDirectory()).path;
    final name = path.basenameWithoutExtension(filePath);
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return "$tempPath/${name}_$epoch.${format.extension}";
  }

  Future<XFile> exportVideo({
    void Function(FFmpegStatistics)? onStatistics,
    VideoExportFormat outputFormat = VideoExportFormat.mp4,
    double scale = 1.0,
    String customInstruction = '',
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) async {
    final inputPath = _controller.file.path;
    final outputPath = await ioOutputPath(inputPath, outputFormat);

    final config = _controller.createVideoFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: inputPath,
      outputPath: outputPath,
      outputFormat: outputFormat,
      scale: scale,
      customInstruction: customInstruction,
      preset: preset,
      isFiltersEnabled: isFiltersEnabled,
    );

    log('run export video command : [$execute]');

    return const FFmpegExport().executeFFmpegIO(
      execute: execute,
      outputPath: outputPath,
      outputMimeType: outputFormat.mimeType,
      onStatistics: onStatistics,
    );
  }
}

class FFmpegExport {
  const FFmpegExport();

  Future<XFile> executeFFmpegIO({
    required String execute,
    required String outputPath,
    String? outputMimeType,
    void Function(FFmpegStatistics)? onStatistics,
  }) {
    final completer = Completer<XFile>();

    FFmpegKit.executeAsync(
      execute,
      (session) async {
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          completer.complete(XFile(outputPath, mimeType: outputMimeType));
        } else {
          final state = FFmpegKitConfig.sessionStateToString(
            await session.getState(),
          );
          completer.completeError(
            Exception(
              'FFmpeg process exited with state $state and return code $code.'
              '${await session.getOutput()}',
            ),
          );
        }
      },
      null,
      onStatistics != null
          ? (s) => onStatistics(FFmpegStatistics.fromIOStatistics(s))
          : null,
    );

    return completer.future;
  }
}

/// Common class for ffmpeg_kit and ffmpeg_wasm statistics.
class FFmpegStatistics {
  final int videoFrameNumber;
  final double videoFps;
  final double videoQuality;
  final int size;
  final int time;
  final double bitrate;
  final double speed;

  static final statisticsRegex = RegExp(
    r'frame\s*=\s*(\d+)\s+fps\s*=\s*(\d+(?:\.\d+)?)\s+q\s*=\s*([\d.-]+)\s+L?size\s*=\s*(\d+)\w*\s+time\s*=\s*([\d:.]+)\s+bitrate\s*=\s*([\d.]+)\s*(\w+)/s\s+speed\s*=\s*([\d.]+)x',
  );

  const FFmpegStatistics({
    required this.videoFrameNumber,
    required this.videoFps,
    required this.videoQuality,
    required this.size,
    required this.time,
    required this.bitrate,
    required this.speed,
  });

  FFmpegStatistics.fromIOStatistics(Statistics s)
      : this(
          videoFrameNumber: s.getVideoFrameNumber(),
          videoFps: s.getVideoFps(),
          videoQuality: s.getVideoQuality(),
          size: s.getSize(),
          time: s.getTime(),
          bitrate: s.getBitrate(),
          speed: s.getSpeed(),
        );

  static FFmpegStatistics? fromMessage(String message) {
    final match = statisticsRegex.firstMatch(message);
    if (match != null) {
      return FFmpegStatistics(
        videoFrameNumber: int.parse(match.group(1)!),
        videoFps: double.parse(match.group(2)!),
        videoQuality: double.parse(match.group(3)!),
        size: int.parse(match.group(4)!),
        time: _timeToMs(match.group(5)!),
        bitrate: double.parse(match.group(6)!),
        // final bitrateUnit = match.group(7);
        speed: double.parse(match.group(8)!),
      );
    }

    return null;
  }

  double getProgress(int videoDurationMs) {
    return videoDurationMs <= 0.0
        ? 0.0
        : (time / videoDurationMs).clamp(0.0, 1.0);
  }

  static int _timeToMs(String timeString) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final secondsParts = parts[2].split('.');
    final seconds = int.parse(secondsParts[0]);
    final milliseconds = int.parse(secondsParts[1]);
    return ((hours * 60 * 60 + minutes * 60 + seconds) * 1000 + milliseconds);
  }
}
