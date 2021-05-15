import 'package:flutter/material.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/type.dart';

class MediaViewerArguments {
  final Attachment attachment;

  MediaViewerArguments(this.attachment);
}

class MediaViewer extends StatefulWidget {
  static final String routeName = '/media_viewer';

  @override
  _MediaViewerState createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
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
      final type = args.attachment.type;
      if (type == Type.image || type == Type.gifv) {
        return Container(
          color: Colors.blueGrey,
          child: Center(
            child: Image.network(args.attachment.url),
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
