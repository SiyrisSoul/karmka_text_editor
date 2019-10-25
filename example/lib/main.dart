import 'package:flutter/material.dart';
import 'package:karmka_text_editor/rich_text_editor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karmka Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Karmka Editor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SpannableTextEditingController _controller = SpannableTextEditingController();
  String _savedStyleJson;
  String _savedText;
  bool _showToolbar = true;

  void save() {
    _savedText = _controller.text;
    _savedStyleJson = _controller.styleList.toJson();
    print('saved');
  }

  void load() {
    setState(() {
      _controller = SpannableTextEditingController.fromJson(
          text: _savedText, styleJson: _savedStyleJson);
      final val = TextSelection.collapsed(offset: _controller.text.length);
      _controller.selection = val;
    });
    refreshToolbar();
    print('loaded');
  }

  void refreshToolbar() async {
    setState(() {
      _showToolbar = false;
    });
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _showToolbar = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Center(
            child: GestureDetector(
              child: Text('SAVE'),
              onTap: () => save(),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Center(
            child: GestureDetector(
              child: Text('LOAD'),
              onTap: () => load(),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scrollbar(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showToolbar,
            child: StyleToolbar(
              stayFocused: false,
              toolbarUndoRedoColor: Colors.white,
              toolbarActionColor: Colors.white.withOpacity(0.5),
              toolbarBackgroundColor: Colors.indigo,
              toolbarActionToggleColor: Colors.white,
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
