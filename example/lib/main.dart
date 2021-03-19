import 'package:circle_color_picker_view/circle_color_picker_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(ColorPickerApp());

class ColorPickerApp extends StatefulWidget {
  @override
  _ColorPickerAppState createState() => _ColorPickerAppState();
}

class _ColorPickerAppState extends State<ColorPickerApp> {
  Color currentColor = Color(0xffffd600);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ColorPicker",
      home: Scaffold(
        appBar: AppBar(
          title: Text("ColorPicker"),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              ColorPickerView(
                  initialColor: currentColor,
                  colorListener: (color) {
                    setState(() {
                      currentColor = color;
                    });
                  }),
              const Padding(
                padding: EdgeInsets.only(top: 20),
              ),
              Container(
                width: 150,
                height: 50,
                color: currentColor,
                alignment: Alignment.center,
                child: Text(
                  currentColor.value.toRadixString(16).toUpperCase(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
