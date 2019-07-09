import 'package:flutter/material.dart';
import 'package:hdpm/components/text/copyabletext.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';

class DerivedSecretItemFieldTypePreview extends StatelessWidget {
  DerivedSecretItemFieldTypePreview({Key key, this.title, this.fieldType, this.secretValue, this.onCustomize})
      : super(key: key);

  final String title;
  final DerivedSecretItemFieldType fieldType;
  final Future<String> secretValue;
  final PopupMenuItemSelected<dynamic> onCustomize;

  @override
  Widget build(BuildContext context) {
    if (secretValue == null) {
      return _buildCalculating();
    }

    return FutureBuilder(
      future: secretValue,
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return _buildCalculating();
        }

        if (onCustomize == null) {
          return CopyableText(
            title: title,
            subtitle: fieldType.deriveFinalValue(snapshot.data),
          );
        }

        return CopyableText.menu(
          title: title,
          subtitle: fieldType.deriveFinalValue(snapshot.data),
          menuEntries: [
            CopyableText.menuItem('customize', Icon(Icons.settings), 'Customize'),
          ],
          onMenuItemSelected: onCustomize,
        );
      },
    );
  }

  Widget _buildCalculating() {
    return CopyableText(
      title: title,
      subtitle: 'Calculating...',
      enabled: false,
    );
  }
}
