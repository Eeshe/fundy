import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

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
        onPressed: () {
          widget._onChanged(widget._color);
          Navigator.pop(context);
        },
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
            ColorPicker(
              color: widget._color,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyFormat: ColorPickerCopyFormat.numHexRRGGBB),
              showColorCode: true,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.wheel: true
              },
              onColorChanged: (value) {
                setState(() {
                  widget._color = value;
                  });
              },
            ),
            _createSaveButton()
          ],
        ),
      ),
    );
  }
}
