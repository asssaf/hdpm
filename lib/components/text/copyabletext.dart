import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  CopyableText({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: IconButton(
        icon: Icon(Icons.content_copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: title));
          Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text("Copied"),
              )
          );
        },
      ),
    );
  }
}