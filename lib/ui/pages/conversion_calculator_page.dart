import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundy/core/services/conversion_service.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/ui/shared/widgets/styled_button_widget.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/string_extension.dart';

class ConversionCalculatorPage extends StatefulWidget {
  const ConversionCalculatorPage({super.key});

  @override
  State<StatefulWidget> createState() => ConversionCalculatorPageState();
}

class ConversionCalculatorPageState extends State<ConversionCalculatorPage> {
  final List<String> _rates = ["BCV", "Paralelo"];
  final TextEditingController _usdController = TextEditingController();
  final TextEditingController _bsController = TextEditingController();
  final FocusNode _usdFocusNode = FocusNode();
  final FocusNode _bsFocusNode = FocusNode();

  String _selectedRate = "BCV";

  void _initializeEditingControllers() {
    _usdController.text = "1.00";
    _bsController.text =
        ConversionService().fetchRate(_selectedRate.toLowerCase()).toString();
  }

  void _addFocusListeners() {
    _usdFocusNode.addListener(() {
      if (!_usdFocusNode.hasFocus) return;

      _usdController.selection = TextSelection(
          baseOffset: 0, extentOffset: _usdController.text.length);
    });
    _bsFocusNode.addListener(() {
      if (!_bsFocusNode.hasFocus) return;

      _bsController.selection =
          TextSelection(baseOffset: 0, extentOffset: _bsController.text.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeEditingControllers();
    _addFocusListeners();
  }

  void _calculateBsToCurrency() {
    if (_bsController.text.isEmpty || !_bsController.text.isNumeric()) {
      return;
    }
    final bsAmount = double.parse(_bsController.text);
    final usdAmount = ConversionService()
        .currencyToUsd(bsAmount, _selectedRate.toLowerCase());
    _usdController.text = usdAmount.toStringAsFixed(2);
  }

  void _calculateCurrencyToBS() {
    if (_usdController.text.isEmpty || !_usdController.text.isNumeric()) {
      return;
    }
    final usdAmount = double.parse(_usdController.text);
    final bsAmount = ConversionService()
        .usdToCurrency(usdAmount, _selectedRate.toLowerCase());
    _bsController.text = bsAmount.toStringAsFixed(2);
  }

  void _calculateConversion() {
    if (_bsFocusNode.hasFocus) {
      _calculateBsToCurrency();
    } else {
      _calculateCurrencyToBS();
    }
  }

  Row _createRateWidget(String rate) {
    return Row(
      children: [
        Radio(
          value: rate,
          groupValue: _selectedRate,
          onChanged: (value) {
            setState(() {
              _selectedRate = rate;
              _calculateConversion();
            });
          },
        ),
        Text(rate)
      ],
    );
  }

  Widget _createRateSelectionWidget() {
    List<Widget> rateRadios = [];
    for (var rate in _rates) {
      rateRadios.add(_createRateWidget(rate));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: rateRadios,
    );
  }

  Widget _createCalculatorInput(String currency,
      TextEditingController textEditingController, FocusNode focusNode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            currency,
            style: TextStyle(
                fontSize: 28, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: TextInputWidget(
            inputController: textEditingController,
            hintText: "0.00",
            focusNode: focusNode,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (p0) {
              setState(() {
                _calculateConversion();
              });
              return null;
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: textEditingController.text,
              ));
            },
            icon: Icon(
              Icons.copy,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }

  Widget _createClearButton() {
    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
        text: getAppLocalizations(context)!.clear,
        onPressed: () {
          setState(() {
            _initializeEditingControllers();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.conversionCalculator),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: ScrollablePageWidget(
        padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
        child: Column(
          children: [
            _createRateSelectionWidget(),
            _createCalculatorInput("USD", _usdController, _usdFocusNode),
            const SizedBox(height: 10),
            _createCalculatorInput("BS", _bsController, _bsFocusNode),
            const SizedBox(height: 10),
            _createClearButton()
          ],
        ),
      ),
    );
  }
}
