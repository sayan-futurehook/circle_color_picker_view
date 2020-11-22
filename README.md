<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-yellow.svg" alt="License: MIT"></a>

---


# CircleColorPickerView


## Usage

```dart
...
    body: Center(
        child: ColorPickerView(
            initialColor: Colors.red,
            radius = 120,
            thumbRadius = 10,
            colorListener: (color) => print(color.value),
        ),
    ),
...
```

If you have no idea, how to show the color picker, you can use [circle_color_picker_view](https://pub.dev/packages/circle_color_picker_view). Sample combination of both packages you can find in [example/main.dart](https://github.com/kaya5777/circle_color_picker_view/blob/main/example/lib/main.dart)
