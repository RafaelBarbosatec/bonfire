import 'dart:async';

import 'package:bonfire/util/talk/say.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TalkDialog extends StatefulWidget {
  const TalkDialog({
    Key? key,
    required this.says,
    this.onFinish,
    this.onChangeTalk,
    this.textBoxMinHeight = 100,
    this.keyboardKeysToNext = const [],
    this.padding,
    this.onClose,
    this.dismissible = false,
  }) : super(key: key);

  static show(
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
  }) {
    showDialog(
      barrierDismissible: dismissible,
      barrierColor: backgroundColor,
      context: context,
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

  @override
  _TalkDialogState createState() => _TalkDialogState();
}

class _TalkDialogState extends State<TalkDialog> {
  final FocusNode _focusNode = FocusNode();
  late Say currentSay;
  int currentIndexTalk = 0;
  bool finishedCurrentSay = false;

  StreamController<List<TextSpan>> _textShowController =
      StreamController<List<TextSpan>>.broadcast();

  @override
  void initState() {
    currentSay = widget.says[currentIndexTalk];
    _startShowText();
    Future.delayed(Duration.zero, () {
      _focusNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.onClose?.call();
    _textShowController.close();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (raw) {
          if (widget.keyboardKeysToNext.isEmpty && raw is RawKeyDownEvent) {
            // Prevent volume buttons from triggering the next dialog
            if (raw.logicalKey != LogicalKeyboardKey.audioVolumeUp &&
                raw.logicalKey != LogicalKeyboardKey.audioVolumeDown) {
              _nextOrFinish();
            }
          } else if (widget.keyboardKeysToNext.contains(raw.logicalKey) &&
              raw is RawKeyDownEvent) {
            _nextOrFinish();
          }
        },
        child: GestureDetector(
          onTap: _nextOrFinish,
          child: Container(
            color: Colors.transparent,
            padding: widget.padding ?? EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: _getAlign(currentSay.personSayDirection),
                  child: currentSay.background ?? SizedBox.shrink(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ..._buildPerson(PersonSayDirection.LEFT),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          currentSay.header ?? SizedBox.shrink(),
                          Container(
                            width: double.maxFinite,
                            padding: currentSay.padding ?? EdgeInsets.all(10),
                            margin: currentSay.margin,
                            constraints: widget.textBoxMinHeight != null
                                ? BoxConstraints(
                                    minHeight: widget.textBoxMinHeight!,
                                  )
                                : null,
                            decoration: currentSay.boxDecoration ??
                                BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                            child: StreamBuilder<List<TextSpan>>(
                              stream: _textShowController.stream,
                              builder: (context, snapshot) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  physics: BouncingScrollPhysics(),
                                  child: RichText(
                                    text: TextSpan(
                                      children: snapshot.data,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          currentSay.bottom ?? SizedBox.shrink(),
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
    _textShowController.add([...currentSay.text]);
    finishedCurrentSay = true;
  }

  void _nextSay() {
    currentIndexTalk++;
    if (currentIndexTalk < widget.says.length) {
      setState(() {
        finishedCurrentSay = false;
        currentSay = widget.says[currentIndexTalk];
      });
      _startShowText();
      if (widget.onChangeTalk != null)
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

  void _startShowText() async {
    // Clean the stream to prevent textStyle from changing before the text
    _textShowController.add([TextSpan()]);

    await Future.forEach<TextSpan>(currentSay.text, (span) async {
      if (_textShowController.isClosed) return;
      for (int i = 0; i < (span.text?.length ?? 0); i++) {
        if (finishedCurrentSay) {
          _textShowController.add([...currentSay.text]);
          break;
        }
        await Future.delayed(Duration(milliseconds: currentSay.speed ?? 50));
        if (_textShowController.isClosed) return;
        _textShowController.add([
          ...currentSay.text.sublist(0, currentSay.text.indexOf(span)),
          TextSpan(
            text: span.text!.substring(0, i + 1),
            style: span.style,
          )
        ]);
      }
    }).then((_) {
      finishedCurrentSay = true;
    });
  }

  List<Widget> _buildPerson(PersonSayDirection direction) {
    if (currentSay.personSayDirection == direction) {
      return [
        if (direction == PersonSayDirection.RIGHT && currentSay.person != null)
          SizedBox(
            width: (widget.padding ?? EdgeInsets.all(10)).horizontal / 2,
          ),
        currentSay.person ?? SizedBox.shrink(),
        if (direction == PersonSayDirection.LEFT && currentSay.person != null)
          SizedBox(
            width: (widget.padding ?? EdgeInsets.all(10)).horizontal / 2,
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
