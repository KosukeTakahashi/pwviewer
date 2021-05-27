import 'package:flutter/material.dart';
import 'package:pwviewer/models/attachment.dart';
import 'package:pwviewer/models/media_type.dart';

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
      final type = args.attachment.type;
      if (type == MediaType.image || type == MediaType.gifv) {
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
                child: Image.network(args.attachment.url),
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
