import 'dart:async';

import 'package:flutter/material.dart';

class TypeWriter extends StatefulWidget {
  final TextStyle? style;
  final List<TextSpan> text;
  final VoidCallback? onFinish;
  final int speed;
  final bool autoStart;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any. If there is no ambient
  /// [Directionality], then this must not be null.
  final TextDirection? textDirection;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final TextScaler textScaler;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis textWidthBasis;
  const TypeWriter({
    required this.text,
    super.key,
    this.style,
    this.speed = 50,
    this.autoStart = true,
    this.onFinish,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
  });

  @override
  State<TypeWriter> createState() => TypeWriterState();
}

class TypeWriterState extends State<TypeWriter> {
  late StreamController<List<TextSpan>> _textSpanController;
  late List<TextSpan> textSpanList;
  bool _finished = false;

  @override
  void initState() {
    textSpanList = widget.text;
    _textSpanController = StreamController<List<TextSpan>>.broadcast();
    if (widget.autoStart) {
      Future.delayed(Duration.zero, start);
    }
    super.initState();
  }

  @override
  void dispose() {
    _textSpanController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TextSpan>>(
      stream: _textSpanController.stream,
      builder: (context, snapshot) {
        return RichText(
          locale: widget.locale,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          softWrap: widget.softWrap,
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          textScaler: widget.textScaler,
          textWidthBasis: widget.textWidthBasis,
          text: TextSpan(
            children: snapshot.data,
            style: widget.style,
          ),
        );
      },
    );
  }

  Future<void> start({List<TextSpan>? text}) async {
    _finished = false;
    if (text != null) {
      textSpanList = text;
    }
    // Clean the stream to prevent textStyle from changing before the text
    _textSpanController.add([const TextSpan()]);

    for (final span in textSpanList) {
      if (_textSpanController.isClosed) {
        return;
      }
      for (var i = 0; i < (span.text?.length ?? 0); i++) {
        await Future.delayed(Duration(milliseconds: widget.speed));
        if (_textSpanController.isClosed || _finished) {
          return;
        }
        _textSpanController.add(
          [
            ...textSpanList.sublist(0, textSpanList.indexOf(span)),
            TextSpan(
              text: span.text?.substring(0, i + 1),
              style: span.style,
            ),
          ],
        );
      }
    }
    _finished = true;
    widget.onFinish?.call();
  }

  void finishTyping() {
    _finished = true;
    _textSpanController.add([...textSpanList]);
    widget.onFinish?.call();
  }
}
