import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:html/dom.dart' as dom;

TextSpan parseContent(BuildContext context, dom.Element element,
    Future Function(String) urlOpen) {
  if (element.localName == 'a') {
    return TextSpan(
      text: element.text,
      style: TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          HapticFeedback.mediumImpact();

          final isHashTag = element.text.startsWith('#');

          if (!isHashTag) {
            final url = element.attributes['href'];
            if (url != null) {
              urlOpen(url);
            }
          }
        },
    );
  } else if (element.localName == 'br') {
    return TextSpan(text: '\n');
  } else if (element.children.length == 0) {
    return TextSpan(
      text: element.text,
      style: Theme.of(context).textTheme.bodyText1,
    );
  } else {
    return TextSpan(
      // children: element.children
      //     .map((e) => parseContent(context, e, urlOpen))
      //     .toList(),
      children: element.nodes
          .where((element) =>
              element.nodeType == dom.Node.TEXT_NODE ||
              element.nodeType == dom.Node.ELEMENT_NODE)
          .map((e) {
        if (e.nodeType == dom.Node.TEXT_NODE) {
          return TextSpan(
            text: e.text,
            style: Theme.of(context).textTheme.bodyText1,
          );
        } else {
          return parseContent(context, e as dom.Element, urlOpen);
        }
      }).toList(),
    );
  }
}
