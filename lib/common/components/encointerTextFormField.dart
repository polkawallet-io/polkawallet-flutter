import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// TextFormField styled for the encointer app
class EncointerTextFormField extends StatelessWidget {
  final String labelText;
  final TextStyle textStyle;
  final List<TextInputFormatter> inputFormatters;
  final TextEditingController controller;
  final Key textFormFieldKey;
  final String Function(String) validator;
  final Widget suffixIcon;
  final bool obscureText;

  const EncointerTextFormField({
    Key key,
    this.labelText,
    this.textStyle,
    this.inputFormatters,
    this.controller,
    this.textFormFieldKey,
    this.validator,
    this.suffixIcon,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZurichLion.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
          key: textFormFieldKey,
          style: textStyle,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: Theme.of(context).textTheme.headline4,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 25),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
          inputFormatters: inputFormatters,
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: validator,
          obscureText: obscureText),
    );
  }
}
