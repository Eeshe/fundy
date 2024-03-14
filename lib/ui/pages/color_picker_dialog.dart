import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  Color _color;
  final Function(Color color) _onChanged;

  ColorPickerDialog(this._color, this._onChanged, {super.key});

  @override
  State<StatefulWidget> createState() => ColorPickerDialogState();
}

class ColorPickerDialogState extends State<ColorPickerDialog> {
  Widget _createSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
        text: getAppLocalizations(context)!.save,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      content: ScrollablePageWidget(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              child: HueRingPicker(
                pickerColor: widget._color,
                enableAlpha: true,
                displayThumbColor: true,
                onColorChanged: (value) {
                  setState(() {
                    widget._color = value;
                  });
                  widget._onChanged(value);
                },
              ),
            ),
            _createSaveButton()
          ],
        ),
      ),
    );
  }
}
