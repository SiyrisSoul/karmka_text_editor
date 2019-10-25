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
import 'package:flutter/material.dart';

typedef ColorSelectCallback = void Function(Color);

class ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final double itemSize;
  final Color selectionColor;

  const ColorPicker({
    Key key,
    @required this.colors,
    this.selectionColor,
    this.itemSize = 40,
  })  : assert(colors != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _ColorContainer(
            colors: colors,
            itemSize: itemSize,
            selectionColor: selectionColor,
            onColorSelected: (color) {
              Navigator.pop(context, ColorSelection(color));
            },
          ),
        ),
      ],
    );
  }
}

class _ColorContainer extends StatelessWidget {
  final List<Color> colors;
  final double itemSize;
  final Color selectionColor;
  final ColorSelectCallback onColorSelected;

  _ColorContainer({
    Key key,
    @required this.colors,
    this.selectionColor,
    this.itemSize,
    this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: colors
          .map((color) => _ColorButton(
                color: color,
                selected: color?.value == selectionColor?.value,
                onTap: () => onColorSelected(color),
              ))
          .toList(),
      maxCrossAxisExtent: itemSize,
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  const _ColorButton({
    Key key,
    @required this.color,
    this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Stack(
      children: <Widget>[
        Material(
          color: color ?? themeData.textTheme.body1.color,
          shape: CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: CircleBorder(),
          ),
        ),
        Visibility(
          visible: selected,
          child: Container(
            decoration: BoxDecoration(
              color: themeData.dividerColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check,
              color: color != null
                  ? Colors.white
                  : themeData.brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        )
      ],
    );
  }
}

@immutable
class ColorSelection {
  final Color color;

  ColorSelection(this.color);

  @override
  String toString() {
    return '_ColorSelection(color: $color)';
  }
}
