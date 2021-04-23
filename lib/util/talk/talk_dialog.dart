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
    this.textStyle,
    this.textBoxDecoration,
    this.textBoxMinHeight = 100,
    this.padding,
    this.keyboardKeyToNext,
    this.headerWidget,
    this.bottomWidget,
  }) : super(key: key);

  static show(BuildContext context, List<Say> sayList,
      {VoidCallback? finish,
      ValueChanged<int>? onChangeTalk,
      TextStyle? textStyle,
      BoxDecoration? boxTextDecoration,
      double boxTextHeight = 100,
      EdgeInsetsGeometry? padding,
      LogicalKeyboardKey? logicalKeyboardKeyToNext,
      Widget? headerWidget,
      Widget? bottomWidget}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TalkDialog(
          says: sayList,
          finish: finish,
          onChangeTalk: onChangeTalk,
          textStyle: textStyle,
          textBoxDecoration: boxTextDecoration,
          textBoxMinHeight: boxTextHeight,
          padding: padding,
          keyboardKeyToNext: logicalKeyboardKeyToNext,
          headerWidget: headerWidget,
          bottomWidget: bottomWidget,
        );
      },
    );
  }

  final List<Say> says;
  final VoidCallback? finish;
  final ValueChanged<int>? onChangeTalk;
  final TextStyle? textStyle;
  final BoxDecoration? textBoxDecoration;
  final double? textBoxMinHeight;
  final EdgeInsetsGeometry? padding;
  final LogicalKeyboardKey? keyboardKeyToNext;
  final Widget? headerWidget;
  final Widget? bottomWidget;

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
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (raw) {
        if (widget.keyboardKeyToNext == null) {
          _nextOrFinish();
        } else if (raw.logicalKey == widget.keyboardKeyToNext &&
            raw is RawKeyDownEvent) {
          _nextOrFinish();
        }
      },
      child: GestureDetector(
        onTap: _nextOrFinish,
        child: Container(
          color: Colors.transparent,
          width: double.maxFinite,
          height: double.maxFinite,
          padding: widget.padding ?? EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ..._buildPerson(PersonDirection.LEFT),
              Expanded(
                child: Container(
                  constraints: widget.textBoxMinHeight != null
                      ? BoxConstraints(
                          minHeight: widget.textBoxMinHeight!,
                        )
                      : null,
                  decoration: widget.textBoxDecoration ??
                      BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.headerWidget != null) widget.headerWidget!,
                          StreamBuilder<String>(
                            stream: _textShowController.stream,
                            builder: (context, snapshot) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                child: Text(
                                  snapshot.hasData ? (snapshot.data ?? '') : '',
                                  style: widget.textStyle ??
                                      TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                ),
                              );
                            },
                          ),
                          if (widget.bottomWidget != null) widget.bottomWidget!,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ..._buildPerson(PersonDirection.RIGHT),
            ],
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

  List<Widget> _buildPerson(PersonDirection direction) {
    if (currentSay.personDirection == direction) {
      return [
        if (direction == PersonDirection.RIGHT)
          SizedBox(
            width: 10,
          ),
        Container(
          height: widget.textBoxMinHeight,
          width: widget.textBoxMinHeight,
          child: currentSay.person,
        ),
        if (direction == PersonDirection.LEFT)
          SizedBox(
            width: 10,
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
}
