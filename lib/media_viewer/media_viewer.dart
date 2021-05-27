import 'package:flutter/material.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/media_type.dart';
import 'package:pwviewer/utils/maybe.dart';

class MediaViewerArguments {
  final Maybe<Attachment> attachment;
  final Maybe<String> imageUrl;

  MediaViewerArguments(Attachment attachment)
      : this.attachment = Maybe.some(attachment),
        this.imageUrl = Maybe.nothing();

  MediaViewerArguments.imageUrl(String url)
      : this.attachment = Maybe.nothing(),
        this.imageUrl = Maybe.some(url);
}

class MediaViewer extends StatefulWidget {
  static final String routeName = '/media_viewer';

  @override
  _MediaViewerState createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  bool _showBackButton = true;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as MediaViewerArguments?;

    if (args == null) {
      return Container(
        child: Center(
          child: Text('The argument was null'),
        ),
      );
    } else {
      // final type = args.attachment.unwrapOrNull()?.type;
      final isImage = args.attachment
              .map((v) => v.type == MediaType.image || v.type == MediaType.gifv)
              .unwrapOrNull() ??
          true;
      // if (type == null || type == MediaType.image || type == MediaType.gifv) {
      if (isImage) {
        return Scaffold(
          backgroundColor: Colors.blueGrey,
          body: Container(
            height: double.infinity,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showBackButton = !_showBackButton;
                });
              },
              child: InteractiveViewer(
                child: Image.network(args.imageUrl.unwrapOrNull() ??
                    args.attachment.unwrap().url),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back),
          ),
        );
      } else {
        return Container(
            child: Center(
          child: Text('Not an image or gifv'),
        ));
      }
    }
  }
}
