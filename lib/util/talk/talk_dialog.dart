import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TalkDialog extends StatefulWidget {
  const TalkDialog({
    required this.says,
    super.key,
    this.onFinish,
    this.onChangeTalk,
    this.textBoxMinHeight = 100,
    this.keyboardKeysToNext = const [],
    this.padding,
    this.onClose,
    this.dismissible = false,
    this.talkAlignment = Alignment.bottomCenter,
    this.style,
    this.speed = 50,
  });

  static Future<T?> show<T>(
    BuildContext context,
    List<Say> sayList, {
    VoidCallback? onFinish,
    VoidCallback? onClose,
    ValueChanged<int>? onChangeTalk,
    Color? backgroundColor,
    double boxTextHeight = 100,
    List<LogicalKeyboardKey> logicalKeyboardKeysToNext = const [],
    EdgeInsetsGeometry? padding,
    bool dismissible = false,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    Alignment talkAlignment = Alignment.bottomCenter,
    TextStyle? style,
    int speed = 50,
  }) {
    return showDialog<T>(
      barrierDismissible: dismissible,
      barrierColor: backgroundColor,
      context: context,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return TalkDialog(
          says: sayList,
          onFinish: onFinish,
          onClose: onClose,
          onChangeTalk: onChangeTalk,
          textBoxMinHeight: boxTextHeight,
          keyboardKeysToNext: logicalKeyboardKeysToNext,
          padding: padding,
          dismissible: dismissible,
          talkAlignment: talkAlignment,
          style: style,
          speed: speed,
        );
      },
    );
  }

  final List<Say> says;
  final VoidCallback? onFinish;
  final VoidCallback? onClose;
  final ValueChanged<int>? onChangeTalk;
  final double? textBoxMinHeight;
  final List<LogicalKeyboardKey> keyboardKeysToNext;
  final EdgeInsetsGeometry? padding;
  final bool dismissible;
  final Alignment talkAlignment;
  final TextStyle? style;

  /// in milliseconds
  final int speed;

  @override
  TalkDialogState createState() => TalkDialogState();
}

class TalkDialogState extends State<TalkDialog> {
  final FocusNode _focusNode = FocusNode();
  late Say currentSay;
  int currentIndexTalk = 0;
  bool finishedCurrentSay = false;

  final GlobalKey<TypeWriterState> _writerKey = GlobalKey();

  @override
  void initState() {
    currentSay = widget.says[currentIndexTalk];
    Future.delayed(Duration.zero, _focusNode.requestFocus);
    super.initState();
  }

  @override
  void dispose() {
    widget.onClose?.call();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (raw) {
          if (widget.keyboardKeysToNext.isEmpty && raw is KeyDownEvent) {
            // Prevent volume buttons from triggering the next dialog
            if (raw.logicalKey != LogicalKeyboardKey.audioVolumeUp &&
                raw.logicalKey != LogicalKeyboardKey.audioVolumeDown) {
              _nextOrFinish();
            }
          } else if (widget.keyboardKeysToNext.contains(raw.logicalKey) &&
              raw is KeyDownEvent) {
            _nextOrFinish();
          }
        },
        child: GestureDetector(
          onTap: _nextOrFinish,
          child: Container(
            color: Colors.transparent,
            padding: widget.padding ?? const EdgeInsets.all(10),
            child: Stack(
              alignment: widget.talkAlignment,
              children: [
                Align(
                  alignment: _getAlign(currentSay.personSayDirection),
                  child: currentSay.background ?? const SizedBox.shrink(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ..._buildPerson(PersonSayDirection.LEFT),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          currentSay.header ?? const SizedBox.shrink(),
                          Container(
                            width: double.maxFinite,
                            padding:
                                currentSay.padding ?? const EdgeInsets.all(10),
                            margin: currentSay.margin,
                            constraints: widget.textBoxMinHeight != null
                                ? BoxConstraints(
                                    minHeight: widget.textBoxMinHeight!,
                                  )
                                : null,
                            decoration: currentSay.boxDecoration ??
                                BoxDecoration(
                                  color: Colors.black.setOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.white.setOpacity(0.5),
                                  ),
                                ),
                            child: TypeWriter(
                              key: _writerKey,
                              text: currentSay.text,
                              speed: widget.speed,
                              style: widget.style ??
                                  const TextStyle(
                                    color: Colors.white,
                                  ),
                              onFinish: () {
                                finishedCurrentSay = true;
                              },
                            ),
                          ),
                          currentSay.bottom ?? const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    ..._buildPerson(PersonSayDirection.RIGHT),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finishCurrentSay() {
    _writerKey.currentState?.finishTyping();
    finishedCurrentSay = true;
  }

  void _nextSay() {
    currentIndexTalk++;
    if (currentIndexTalk < widget.says.length) {
      setState(() {
        finishedCurrentSay = false;
        currentSay = widget.says[currentIndexTalk];
      });
      _writerKey.currentState?.start(text: currentSay.text);
      widget.onChangeTalk?.call(currentIndexTalk);
    } else {
      widget.onFinish?.call();
      Navigator.pop(context);
    }
  }

  void _nextOrFinish() {
    if (finishedCurrentSay) {
      _nextSay();
    } else {
      _finishCurrentSay();
    }
  }

  List<Widget> _buildPerson(PersonSayDirection direction) {
    if (currentSay.personSayDirection == direction) {
      return [
        if (direction == PersonSayDirection.RIGHT && currentSay.person != null)
          SizedBox(
            width: (widget.padding ?? const EdgeInsets.all(10)).horizontal / 2,
          ),
        SizedBox(
          key: UniqueKey(),
          child: currentSay.person,
        ),
        if (direction == PersonSayDirection.LEFT && currentSay.person != null)
          SizedBox(
            width: (widget.padding ?? const EdgeInsets.all(10)).horizontal / 2,
          ),
      ];
    } else {
      return [];
    }
  }

  Alignment _getAlign(PersonSayDirection personDirection) {
    return personDirection == PersonSayDirection.LEFT
        ? Alignment.bottomLeft
        : Alignment.bottomRight;
  }
}
