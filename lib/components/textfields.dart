import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show TextInputAction, TextInputFormatter, TextInputType;
import 'package:shinda_app/constants/text_syles.dart' show primary;

class NormalTextFormField extends StatelessWidget {
  const NormalTextFormField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.enableSuggestions,
    this.autocorrect,
    required this.hintText,
    required this.labelText,
    this.validator,
    this.maxLines = 1,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType? keyboardType;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final String? Function(String?)? validator;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: TextInputAction.next,
      enableSuggestions: enableSuggestions ?? false,
      autocorrect: autocorrect ?? false,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      cursorColor: primary,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red[900]!, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        hintText: hintText,
        labelText: labelText,
      ),
      validator: validator,
    );
  }
}

class PasswordTextFormField extends StatefulWidget {
  const PasswordTextFormField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.next,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            icon: _obscureText
                ? const Icon(Icons.visibility_outlined)
                : const Icon(Icons.visibility_off_outlined),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red[900]!, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        hintText: 'Enter your password',
        labelText: 'Password',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password required.';
        } else if (value.length < 8) {
          return 'Password length must be more than 8 characters.';
        }
        return null;
      },
    );
  }
}
