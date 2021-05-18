import 'package:flutter/material.dart';
import 'package:pwviewer/models/tag.dart';
import 'package:pwviewer/utils/maybe.dart';

class HashtagList extends StatefulWidget {
  final List<Tag> tags;
  final Maybe<void Function()> readMoreCallback;

  HashtagList(this.tags) : readMoreCallback = Maybe.nothing();

  HashtagList.withReadMore(this.tags, void Function() readMoreCallback)
      : readMoreCallback = Maybe.some(readMoreCallback);

  @override
  _HashtagListState createState() => _HashtagListState();
}

class _HashtagListState extends State<HashtagList> {
  Widget _buildHashtagItem(BuildContext context, int index) {
    if (index == widget.tags.length) {
      widget.readMoreCallback.unwrap()();
      return Container(
        padding: EdgeInsets.all(8),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.tag),
        title: Text(widget.tags[index].name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: _buildHashtagItem,
      separatorBuilder: (ctx, idx) => Divider(),
      itemCount:
          widget.tags.length + (widget.readMoreCallback.isNothing() ? 0 : 1),
    );
  }
}
