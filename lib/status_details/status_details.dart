import 'package:flutter/material.dart';
import 'package:pwviewer/models/status.dart';

class StatusDetailsArguments {
  final Status status;

  StatusDetailsArguments(this.status);
}

class StatusDetails extends StatelessWidget {
  static final String routeName = '/status_details';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as StatusDetailsArguments?;

    final appBar = AppBar(
      leading: BackButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text('詳細'),
    );

    if (args == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Text('The argument was null'),
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Text(args.status.id.toString()),
        ),
      );
    }
  }
}
