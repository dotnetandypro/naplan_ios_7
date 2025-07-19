import 'package:flutter/material.dart';

class ConvertTextSpan extends TextSpan {
  const ConvertTextSpan({
    String? text,
    List<InlineSpan>? children,
    TextStyle? textStyle,
  }) : super(
          text: children == null ? text : null,
          children: children,
          style: textStyle ??
              const TextStyle(
                  fontSize: 20, color: Colors.black), // Increased from 16
        );
}
