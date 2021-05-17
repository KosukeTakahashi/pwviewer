import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:html/dom.dart' as dom;
import 'package:pwviewer/models/emoji.dart';
import 'split_with_delimiter.dart';

TextSpan parseContent(BuildContext context, dom.Element element,
    List<Emoji> emojis, Future Function(String) urlOpen) {
  if (element.localName == 'a') {
    return TextSpan(
      text: element.text,
      style: TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          HapticFeedback.mediumImpact();

          final isHashTag = element.text.startsWith('#');
          final isUser = element.text.startsWith('@');

          if (!(isHashTag || isUser)) {
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
    final emojiPatterns =
        emojis.map((emoji) => ':${emoji.shortcode}:').join('|');
    final textParts = element.text.splitWithDelimiters(RegExp(emojiPatterns));
    final spanChildren = textParts.map(
      (text) {
        if (emojis.indexWhere((element) => text == ':${element.shortcode}:') !=
            -1) {
          final emoji =
              emojis.firstWhere((element) => ':${element.shortcode}:' == text);
          return WidgetSpan(
            child: Container(
              height: 16,
              child: Image.network(emoji.url),
            ),
          );
        } else {
          return TextSpan(text: text);
        }
      },
    );

    return TextSpan(
      // text: e.text,
      children: spanChildren.toList(),
      style: Theme.of(context).textTheme.bodyText1,
    );
    // return TextSpan(
    //   text: element.text,
    //   style: Theme.of(context).textTheme.bodyText1,
    // );
  } else {
    final emojiPatterns =
        emojis.map((emoji) => ':${emoji.shortcode}:').join('|');
    return TextSpan(
      // children: element.children
      //     .map((e) => parseContent(context, e, urlOpen))
      //     .toList(),
      children: element.nodes
          .where((element) =>
              element.nodeType == dom.Node.TEXT_NODE ||
              element.nodeType == dom.Node.ELEMENT_NODE)
          .map(
        (e) {
          if (e.nodeType == dom.Node.TEXT_NODE) {
            final textParts =
                e.text?.splitWithDelimiters(RegExp(emojiPatterns));
            final spanChildren = textParts?.map(
              (text) {
                if (emojis.indexWhere(
                        (element) => text == ':${element.shortcode}:') !=
                    -1) {
                  final emoji = emojis.firstWhere(
                      (element) => ':${element.shortcode}:' == text);
                  return WidgetSpan(
                    child: Container(
                      height: 16,
                      child: Image.network(emoji.url),
                    ),
                  );
                } else {
                  return TextSpan(text: text);
                }
              },
            );

            return TextSpan(
              // text: e.text,
              children: spanChildren?.toList(),
              style: Theme.of(context).textTheme.bodyText1,
            );
          } else {
            return parseContent(context, e as dom.Element, emojis, urlOpen);
          }
        },
      ).toList(),
    );
  }
}
