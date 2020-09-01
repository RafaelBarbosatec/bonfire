import 'dart:async';

import 'package:bonfire/util/talk/say.dart';
import 'package:flutter/material.dart';

class TalkDialog extends StatefulWidget {
  const TalkDialog(
      {Key key,
      this.says,
      this.finish,
      this.onChangeTalk,
      this.textStyle,
      this.boxTextDecoration,
      this.boxTextHeight = 100,
      this.padding})
      : super(key: key);

  static show(
    BuildContext context,
    List<Say> sayList, {
    VoidCallback finish,
    ValueChanged<int> onChangeTalk,
    TextStyle textStyle,
    BoxDecoration boxTextDecoration,
    double boxTextHeight = 100,
    EdgeInsetsGeometry padding,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TalkDialog(
          says: sayList,
          finish: finish,
          onChangeTalk: onChangeTalk,
          textStyle: textStyle,
          boxTextDecoration: boxTextDecoration,
          boxTextHeight: boxTextHeight,
          padding: padding,
        );
      },
    );
  }

  final List<Say> says;
  final VoidCallback finish;
  final ValueChanged<int> onChangeTalk;
  final TextStyle textStyle;
  final BoxDecoration boxTextDecoration;
  final double boxTextHeight;
  final EdgeInsetsGeometry padding;

  @override
  _TalkDialogState createState() => _TalkDialogState();
}

class _TalkDialogState extends State<TalkDialog> {
  Timer timer;
  Say currentSay;
  int currentIndexTalk = 0;
  int countLetter = 1;
  bool finishCurrentTalk = false;

  StreamController<String> _textShowController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    currentSay = widget.says[currentIndexTalk];
    startShowText();
    super.initState();
  }

  @override
  void dispose() {
    _textShowController.close();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (finishCurrentTalk) {
          _nextTalk();
        } else {
          _finishTalk();
        }
      },
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
                height: widget.boxTextHeight,
                decoration: widget.boxTextDecoration ??
                    BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: StreamBuilder(
                      stream: _textShowController.stream,
                      builder: (context, snapshot) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          child: Text(
                            snapshot.hasData ? snapshot.data : '',
                            style: widget.textStyle ??
                                TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            ..._buildPerson(PersonDirection.RIGHT),
          ],
        ),
      ),
    );
  }

  void _finishTalk() {
    timer.cancel();
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
      if (widget.onChangeTalk != null) widget.onChangeTalk(currentIndexTalk);
    } else {
      if (widget.finish != null) widget.finish();
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
          height: widget.boxTextHeight,
          width: widget.boxTextHeight,
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
}
