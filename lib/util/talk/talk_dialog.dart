import 'dart:async';

import 'package:bonfire/util/talk/say.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TalkDialog extends StatefulWidget {
  const TalkDialog({
    Key? key,
    required this.says,
    this.finish,
    this.onChangeTalk,
    this.textBoxMinHeight = 100,
    this.keyboardKeyToNext,
    this.padding,
  }) : super(key: key);

  static show(
    BuildContext context,
    List<Say> sayList, {
    VoidCallback? finish,
    ValueChanged<int>? onChangeTalk,
    double boxTextHeight = 100,
    LogicalKeyboardKey? logicalKeyboardKeyToNext,
    EdgeInsetsGeometry? padding,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TalkDialog(
          says: sayList,
          finish: finish,
          onChangeTalk: onChangeTalk,
          textBoxMinHeight: boxTextHeight,
          keyboardKeyToNext: logicalKeyboardKeyToNext,
          padding: padding,
        );
      },
    );
  }

  final List<Say> says;
  final VoidCallback? finish;
  final ValueChanged<int>? onChangeTalk;
  final double? textBoxMinHeight;
  final LogicalKeyboardKey? keyboardKeyToNext;
  final EdgeInsetsGeometry? padding;

  @override
  _TalkDialogState createState() => _TalkDialogState();
}

class _TalkDialogState extends State<TalkDialog> {
  final FocusNode _focusNode = FocusNode();
  Timer? timer;
  late Say currentSay;
  int currentIndexTalk = 0;
  int countLetter = 1;
  bool finishCurrentTalk = false;

  StreamController<String> _textShowController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    currentSay = widget.says[currentIndexTalk];
    startShowText();
    Future.delayed(Duration.zero, () {
      _focusNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    _textShowController.close();
    _focusNode.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (raw) {
          if (widget.keyboardKeyToNext == null && raw is RawKeyDownEvent) {
            _nextOrFinish();
          } else if (raw.logicalKey == widget.keyboardKeyToNext &&
              raw is RawKeyDownEvent) {
            _nextOrFinish();
          }
        },
        child: GestureDetector(
          onTap: _nextOrFinish,
          child: Padding(
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
                            child: StreamBuilder<String>(
                              stream: _textShowController.stream,
                              builder: (context, snapshot) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  physics: BouncingScrollPhysics(),
                                  child: Text(
                                    snapshot.hasData
                                        ? (snapshot.data ?? '')
                                        : '',
                                    style: currentSay.textStyle ??
                                        TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
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

  void _finishTalk() {
    timer?.cancel();
    _textShowController.add(currentSay.text);
    countLetter = 1;
    finishCurrentTalk = true;
  }

  void _nextTalk() {
    currentIndexTalk++;
    if (currentIndexTalk < widget.says.length) {
      setState(() {
        finishCurrentTalk = false;
        currentSay = widget.says[currentIndexTalk];
      });
      startShowText();
      if (widget.onChangeTalk != null)
        widget.onChangeTalk?.call(currentIndexTalk);
    } else {
      if (widget.finish != null) widget.finish?.call();
      Navigator.pop(context);
    }
  }

  void startShowText() {
    timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      _textShowController.add(currentSay.text.substring(0, countLetter));
      countLetter++;
      if (countLetter == currentSay.text.length + 1) {
        timer.cancel();
        countLetter = 1;
        finishCurrentTalk = true;
      }
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

  void _nextOrFinish() {
    if (finishCurrentTalk) {
      _nextTalk();
    } else {
      _finishTalk();
    }
  }

  Alignment _getAlign(PersonSayDirection personDirection) {
    return personDirection == PersonSayDirection.LEFT
        ? Alignment.bottomLeft
        : Alignment.bottomRight;
  }
}
