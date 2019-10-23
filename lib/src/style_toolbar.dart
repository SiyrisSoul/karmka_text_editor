import 'dart:async';

import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'spannable_style.dart';
import 'spannable_text.dart';

const defaultColors = [
  null,
  Colors.red,
  Colors.redAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.blue,
  Colors.blueAccent,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.grey,
];

class StyleToolbar extends StatefulWidget {
  final SpannableTextEditingController controller;
  final Color toolbarActionToggleColor;
  final Color toolbarBackgroundColor;
  final Color toolbarActionColor;
  final bool stayFocused;

  StyleToolbar(
      {Key key,
      this.controller,
      this.stayFocused = true,
      this.toolbarActionToggleColor,
      this.toolbarBackgroundColor = Colors.transparent,
      this.toolbarActionColor = Colors.black})
      : super(key: key);

  @override
  _StyleToolbarState createState() => _StyleToolbarState();
}

class _StyleToolbarState extends State<StyleToolbar> {
  final StreamController<TextEditingValue> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _streamController.sink.add(widget.controller.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TextEditingValue>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        var currentStyle = SpannableStyle();
        var currentSelection;
        if (snapshot.hasData) {
          var value = snapshot.data;
          var selection = value.selection;
          if (selection != null && !selection.isCollapsed) {
            currentSelection = selection;
            currentStyle = widget.controller.getSelectionStyle();
          } else {
            currentStyle = widget.controller.composingStyle;
          }
        }
        return Container(
          constraints: BoxConstraints(
              maxHeight: 50, maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            color: widget.toolbarBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    ..._buildActions(
                      currentStyle ?? SpannableStyle(),
                      currentSelection,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.format_color_text,
                  color: getColorFromValue(currentStyle.foregroundColor),
                ),
                onPressed: () async {
                  if (widget.stayFocused) {
                    FocusScope.of(context).unfocus();
                  }

                  ColorSelection colorSelection = await showModalBottomSheet(
                    context: context,
                    builder: (context) => ColorPicker(
                      colors: defaultColors,
                      selectionColor: getColorFromValue(
                        currentStyle.foregroundColor,
                      ),
                    ),
                  );
                  if (colorSelection != null) {
                    _setTextColor(
                      currentStyle ?? SpannableStyle(),
                      useForegroundColor,
                      colorSelection,
                      selection: currentSelection,
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.undo,
                  color: widget.toolbarActionColor,
                ),
                onPressed: widget.controller.canUndo()
                    ? () {
                        widget.controller.undo();
                        if (widget.stayFocused) {
                          FocusScope.of(context).unfocus();
                        }
                      }
                    : null,
              ),
              IconButton(
                icon: Icon(
                  Icons.redo,
                  color: widget.toolbarActionColor,
                ),
                onPressed: widget.controller.canRedo()
                    ? () {
                        widget.controller.redo();
                        if (widget.stayFocused) {
                          FocusScope.of(context).unfocus();
                        }
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  List<Widget> _buildActions(
      SpannableStyle spannableStyle, TextSelection selection) {
    final Map<int, IconData> styleMap = {
      styleBold: Icons.format_bold,
      styleItalic: Icons.format_italic,
      styleUnderline: Icons.format_underlined,
      styleLineThrough: Icons.format_strikethrough,
    };

    return styleMap.keys
        .map((style) => IconButton(
              icon: Icon(
                styleMap[style],
                color: spannableStyle.hasStyle(style)
                    ? widget.toolbarActionToggleColor != null
                        ? widget.toolbarActionToggleColor
                        : Theme.of(context).accentColor
                    : widget.toolbarActionColor,
              ),
              onPressed: () => _toggleTextStyle(
                spannableStyle.copy(),
                style,
                selection: selection,
              ),
            ))
        .toList();
  }

  void _toggleTextStyle(
    SpannableStyle spannableStyle,
    int textStyle, {
    TextSelection selection,
  }) {
    bool hasSelection = selection != null;
    if (spannableStyle.hasStyle(textStyle)) {
      if (hasSelection) {
        widget.controller
            .setSelectionStyle((style) => style..clearStyle(textStyle));
      } else {
        widget.controller.composingStyle = spannableStyle
          ..clearStyle(textStyle);
      }
    } else {
      if (hasSelection) {
        widget.controller
            .setSelectionStyle((style) => style..setStyle(textStyle));
      } else {
        widget.controller.composingStyle = spannableStyle..setStyle(textStyle);
      }
    }
  }

  void _setTextColor(
    SpannableStyle spannableStyle,
    int textStyle,
    ColorSelection colorSelection, {
    TextSelection selection,
  }) {
    bool hasSelection = selection != null;
    if (hasSelection) {
      if (textStyle == useForegroundColor) {
        if (colorSelection.color != null) {
          widget.controller.selection = selection;
          widget.controller.setSelectionStyle(
            (style) => style..setForegroundColor(colorSelection.color),
          );
        } else {
          widget.controller.selection = selection;
          widget.controller.setSelectionStyle(
            (style) => style..clearForegroundColor(),
          );
        }
      }
    } else {
      if (textStyle == useForegroundColor) {
        if (colorSelection.color != null) {
          widget.controller.composingStyle = spannableStyle
            ..setForegroundColor(colorSelection.color);
        } else {
          widget.controller.composingStyle = spannableStyle
            ..clearForegroundColor();
        }
      }
    }
  }
}
