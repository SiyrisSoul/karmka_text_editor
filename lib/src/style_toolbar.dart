/*
 * Karmka Text Editor
 * Copyright 2019 Adam Bahr.
 * https://github.com/TutOsirisOm/karmka_text_editor/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * This project uses modified source code from https://github.com/namhyun-gu/flutter_rich_text_editor, copyright Namhyun Gu 2019, licensed under the Apache 2.0 license.
 */
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
  final Color toolbarUndoRedoColor;
  final Color toolbarActionColor;
  final bool stayFocused;

  StyleToolbar(
      {Key key,
      this.controller,
      this.stayFocused = true,
      this.toolbarActionToggleColor,
      this.toolbarBackgroundColor = Colors.transparent,
      this.toolbarUndoRedoColor = Colors.black,
      this.toolbarActionColor = Colors.grey,})
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
              maxHeight: 55, maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            color: widget.toolbarBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(20, 15),
              topRight: Radius.elliptical(20, 15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      )),
                  child: Row(
                    children: <Widget>[
                      ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          ..._buildActions(
                            currentStyle ?? SpannableStyle(),
                            currentSelection,
                          ),
                        ],
                      ),
                      RawMaterialButton(
                        padding: EdgeInsets.all(1),
                        hoverElevation: 0.0,
                        hoverColor: Colors.white.withOpacity(0.1),
                        focusColor: Colors.white.withOpacity(0.1),
                        splashColor: Colors.white.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.1),
                        disabledElevation: 0.0,
                        highlightElevation: 0.0,
                        focusElevation: 0.0,
                        shape: CircleBorder(side: BorderSide.none),
                        elevation: 0.0,
                        fillColor: Colors.white,
                        constraints: BoxConstraints(
                            maxHeight: double.infinity,
                            maxWidth: double.infinity),
                        onPressed: () async {
                          if (widget.stayFocused) {
                            FocusScope.of(context).unfocus();
                          }

                          ColorSelection colorSelection =
                              await showModalBottomSheet(
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
                        child: Center(
                          child: Icon(
                            Icons.fiber_manual_record,
                            color:
                                getColorFromValue(currentStyle.foregroundColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      )),
                  child: Row(
                    children: <Widget>[
                      RawMaterialButton(
                        hoverElevation: 0.0,
                        hoverColor: Colors.white.withOpacity(0.1),
                        focusColor: Colors.white.withOpacity(0.1),
                        splashColor: Colors.white.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.1),
                        disabledElevation: 0.0,
                        highlightElevation: 0.0,
                        focusElevation: 0.0,
                        shape: CircleBorder(side: BorderSide.none),
                        elevation: 0.0,
                        fillColor: Colors.transparent,
                        constraints: BoxConstraints(
                            maxHeight: double.infinity,
                            maxWidth: double.infinity),
                        onPressed: widget.controller.canUndo()
                            ? () {
                                widget.controller.undo();
                                if (widget.stayFocused) {
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Center(
                            child: Icon(
                              Icons.undo,
                              color: widget.toolbarUndoRedoColor,
                            ),
                          ),
                        ),
                      ),
                      RawMaterialButton(
                        hoverElevation: 0.0,
                        hoverColor: Colors.white.withOpacity(0.1),
                        focusColor: Colors.white.withOpacity(0.1),
                        splashColor: Colors.white.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.1),
                        disabledElevation: 0.0,
                        highlightElevation: 0.0,
                        focusElevation: 0.0,
                        shape: CircleBorder(side: BorderSide.none),
                        elevation: 0.0,
                        fillColor: Colors.transparent,
                        constraints: BoxConstraints(
                            maxHeight: double.infinity,
                            maxWidth: double.infinity),
                        onPressed: widget.controller.canRedo()
                            ? () {
                                widget.controller.redo();
                                if (widget.stayFocused) {
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Center(
                            child: Icon(
                              Icons.redo,
                              color: widget.toolbarUndoRedoColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
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
