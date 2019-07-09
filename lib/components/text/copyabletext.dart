import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  static const COPY_VALUE = 'copy';
  CopyableText({Key key, this.title, @required this.subtitle, this.enabled = true, this.trailingBuilder})
      : assert(subtitle != null),
        super(key: key);

  factory CopyableText.menu(
      {Key key,
      String title,
      String subtitle,
      bool enabled = true,
      List<PopupMenuEntry> menuEntries,
      PopupMenuItemSelected onMenuItemSelected}) {
    final trailingBuilder = (context, copyAction) {
      return PopupMenuButton(
        onSelected: (value) => (value == COPY_VALUE ? copyAction() : onMenuItemSelected(value)),
        itemBuilder: (_) => [
              menuItem(COPY_VALUE, Icon(Icons.content_copy), 'Copy to clipboard'),
              ...menuEntries,
            ],
      );
    };

    return CopyableText(
      key: key,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailingBuilder: trailingBuilder,
    );
  }

  final String title;
  final String subtitle;
  final bool enabled;
  final Function trailingBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title ?? ''),
      subtitle: SizedBox(
        height: 30, //TODO number of lines property
        child: Text(subtitle),
      ),
      trailing: _buildTrailing(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (!enabled) {
      return null;
    }

    if (trailingBuilder != null) {
      return trailingBuilder(context, () => _copyAction(context));
    }

    return IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () => _copyAction(context),
    );
  }

  void _copyAction(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: subtitle));
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied"),
      ),
    );
  }

  static PopupMenuItem menuItem(value, Icon icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }
}
