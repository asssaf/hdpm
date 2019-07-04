import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  CopyableText({Key key, this.title, @required this.subtitle, this.enabled = true})
      : assert(subtitle != null),
        super(key: key);

  final String title;
  final String subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title ?? ''),
      subtitle: Text(subtitle),
      trailing: _buildTrailing(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (!enabled) {
      return null;
    }

    return IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: subtitle));
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Copied"),
          ),
        );
      },
    );
  }
}
