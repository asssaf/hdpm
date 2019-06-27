class SecretItem {
  String title;
  bool hasManualPath = false;
  String path;

  @override
  String toString() {
    return 'SecretItem{title: $title, hasManualPath: $hasManualPath, path: $path}';
  }
}
