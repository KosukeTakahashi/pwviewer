import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:html/dom.dart' as dom;

TextSpan parseContent(dom.Element element, Future Function(String) urlOpen) {
  if (element.children.length == 0) {
    return TextSpan(text: element.text);
  } else {
    return TextSpan(
      children: element.children.map((e) {
        if (e.localName == 'a') {
          return TextSpan(
            text: e.text,
            // <a></a>に子要素はないものの仮定する
            // children: e.children.map((f) => parseContent(f)).toList(),
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                HapticFeedback.mediumImpact();
                // とりあえず '#' で始まるか否かでハッシュタグかを判定
                final isHashTag = e.text.startsWith('#');

                if (!isHashTag) {
                  final url = e.attributes['href'];
                  if (url != null) {
                    // open URL
                    urlOpen(url);
                  }
                }
              },
          );
        } else {
          return TextSpan(
              children:
                  e.children.map((f) => parseContent(f, urlOpen)).toList());
        }
      }).toList(),
    );
  }
}
