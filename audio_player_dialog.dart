import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../core/helper_functions/date_helper.dart';
import '../../utils/extensions.dart';
import '../../core/models/activity_model.dart';
import 'package:just_audio/just_audio.dart';

Future<void> playAudioWithDialog(
  BuildContext context, {
  required ActivityModel model,
  String? confirmButtonText,
  String? cancelButtonText,
  bool? showCrossButton,
  bool? showButtons,
  String? title,
  Widget? titleWidget,
  Function(BuildContext context)? cancelCallBack,
  Function(BuildContext context)? confirmCallBack,
  Function(BuildContext context)? crossCallBack,
  VoidCallback? cancelButtonCallback,
  VoidCallback? confirmButtonCallback,
  VoidCallback? crossButtonCallback,
}) async {
  final audioPlayer = AudioPlayer();
  var totalDuration =
      await audioPlayer.setFilePath(model.audioFilePath.isNull());
  return showModal(
    configuration: const FadeScaleTransitionConfiguration(
      transitionDuration: Duration(milliseconds: 500),
      barrierDismissible: false,
      reverseTransitionDuration: Duration(milliseconds: 500),
    ),
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: titleWidget ??
                            Text(
                              title ?? 'Dialog Title',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                      ),
                      if (showCrossButton ?? true)
                        Positioned(
                          right: 10,
                          top: 8,
                          child: InkWell(
                            onTap: crossButtonCallback ??
                                () async {
                                  if (crossCallBack != null) {
                                    crossCallBack(context);
                                  } else {
                                    audioPlayer.stop();
                                    audioPlayer.dispose();
                                    Navigator.of(context).pop(true);
                                  }
                                },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 25,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Playing ${model.activityName ?? "Activity 1"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                model.cityName ?? "City 1",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                model.schoolName ?? "School 1",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateHelper.getDateDDMMYYYYFromString(
                                        model.createdOn) ??
                                    "01-03-2023",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? const Duration();
                          if (duration.inSeconds == totalDuration?.inSeconds) {
                            if (audioPlayer.playing) {
                              audioPlayer.pause();
                              audioPlayer.seek(const Duration(seconds: 0));
                            }
                          }
                          return Column(
                            children: [
                              Slider(
                                min: 0,
                                max: totalDuration?.inSeconds
                                        .truncateToDouble() ??
                                    0.0,
                                value: duration.inSeconds.toDouble(),
                                onChanged: (value) async {
                                  var durationToSeek = Duration(
                                      seconds:
                                          ((totalDuration?.inSeconds ?? 0.0) /
                                                      60 +
                                                  value)
                                              .toInt());
                                  await audioPlayer.seek(durationToSeek);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}"),
                                    IconButton(
                                        onPressed: () async {
                                          var durationToSeek = Duration(
                                              seconds:
                                                  (duration.inSeconds - 5) < 1
                                                      ? 0
                                                      : (duration.inSeconds -
                                                          5));
                                          await audioPlayer
                                              .seek(durationToSeek);
                                        },
                                        icon: const Icon(Icons.fast_rewind)),
                                    ValueListenableBuilder(
                                      builder: (context, val, child) {
                                        if (val.playing) {
                                          return IconButton(
                                              onPressed: () async {
                                                audioPlayer.pause();
                                              },
                                              icon: const Icon(Icons.pause));
                                        }

                                        return IconButton(
                                            onPressed: () async {
                                              audioPlayer.play();
                                            },
                                            icon: const Icon(Icons.play_arrow));
                                      },
                                      valueListenable: ValueNotifier(
                                          audioPlayer.playerState),
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          var durationToSeek = Duration(
                                              seconds: (duration
                                                              .inSeconds +
                                                          5) >
                                                      (totalDuration
                                                              ?.inSeconds ??
                                                          0)
                                                  ? (totalDuration?.inSeconds ??
                                                      0)
                                                  : (duration.inSeconds + 5));
                                          await audioPlayer
                                              .seek(durationToSeek);
                                        },
                                        icon: const Icon(Icons.fast_forward)),
                                    Text(
                                        "${totalDuration?.inMinutes}:${((totalDuration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}"),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (showButtons ?? true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: cancelButtonCallback ??
                                  () {
                                    if (cancelCallBack != null) {
                                      cancelCallBack(context);
                                    } else {
                                      audioPlayer.dispose();
                                      Navigator.pop(context);
                                    }
                                  },
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 1.0, color: Colors.red),
                                  fixedSize: const Size(100, 50)),
                              child: Text(
                                cancelButtonText ?? 'Cancel',
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: confirmButtonCallback ??
                                  () async {
                                    if (confirmCallBack != null) {
                                      confirmCallBack(context);
                                    } else {
                                      audioPlayer.dispose();
                                      Navigator.pop(context);
                                    }
                                  },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  fixedSize: const Size(100, 50)),
                              child: Text(
                                confirmButtonText ?? 'Confirm',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
