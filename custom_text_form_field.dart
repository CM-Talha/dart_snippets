import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  //Decorations
  final String? label;
  final String? hint;
  final bool? showBorder;
  final Color? fillColor;
  final Color? borderColor;
  final InputDecoration? decoration;
  //Text Controls
  final int? maxLines;
  final int? maxLength;
  final bool? obscureText;
  final bool? readOnly;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onSaved;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool? enabled;
  final AutovalidateMode? autoValidateMode;
  final TextAlign? textAlign;
  //Focus Node
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool? autofocus;

  //widgets
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;

  const CustomTextFormField(
      {Key? key,
        this.label,
        this.hint,
        this.fillColor,
        this.keyboardType,
        this.maxLines,
        this.maxLength,
        this.controller,
        this.obscureText,
        this.validator,
        this.onSaved,
        this.onChanged,
        this.focusNode,
        this.nextFocusNode,
        this.enabled,
        this.autofocus,
        this.readOnly,
        this.autoValidateMode,
        this.textAlign,
        this.onTap,
        this.showBorder,
        this.borderColor,
        this.decoration,
        this.prefixIcon,
        this.suffixIcon,
        this.prefix,
        this.suffix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: TextFormField(
        onTap: onTap,
        controller: controller,
        obscureText: obscureText ?? false,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: autoValidateMode,
        textAlign: textAlign ?? TextAlign.start,
        onSaved: onSaved,
        onChanged: onChanged,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly ?? false,
        autofocus: autofocus ?? false,
        decoration: decoration ??
            InputDecoration(
              filled: true,
              labelText: label,
              hintText: hint,
              fillColor: fillColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
              suffix: suffix,
              prefix: prefix,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              border: showBorder == null
                  ? InputBorder.none
                  : OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                  width: showBorder ?? false ? 1 : 0,
                ),
              ),
            ),
      ),
    );
  }
}