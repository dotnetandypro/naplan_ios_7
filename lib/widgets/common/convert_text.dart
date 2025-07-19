import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ConvertText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  const ConvertText({
    Key? key,
    required this.text,
    this.textStyle,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Force light theme for this widget to prevent dark mode issues
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_containsHtml(text)) {
      return Html(
        data: text,
        style: {
          "p": Style(
            fontSize: FontSize(20),
            color: Colors.black, // Force black text
          ),
          "ul": Style(
            margin: Margins.only(left: 20),
            color: Colors.black, // Force black text
          ),
          "li": Style(
            fontSize: FontSize(20),
            color: Colors.black, // Force black text
          ),
          "div": Style(
            color: Colors.black, // Force black text
          ),
          "span": Style(
            color: Colors.black, // Force black text
          ),
          "body": Style(
            color: Colors.black, // Force black text
          ),
          "*": Style(
            color: Colors.black, // Force black text for all elements
          ),
        },
      );
    } else {
      return Text(
        text,
        textAlign: textAlign ?? TextAlign.start,
        style: textStyle ??
            const TextStyle(
                fontSize: 20, // Increased from 16
                fontWeight: FontWeight.bold,
                color: Colors.black),
      );
    }
  }

  /// Detects whether the text contains HTML tags
  bool _containsHtml(String text) {
    RegExp htmlRegex = RegExp(r"<[^>]+>");
    return htmlRegex.hasMatch(text);
  }
}
