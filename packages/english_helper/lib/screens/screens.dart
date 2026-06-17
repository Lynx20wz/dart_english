import 'package:flutter/material.dart' show BuildContext, Navigator;
import 'package:toastification/toastification.dart' show toastification;

export 'homepage.dart';
export 'search_screen.dart';
export 'words_list.dart';

enum Screen {
  homepage('/homepage'),
  search('/search'),
  words('/words');

  final String path;

  const Screen(this.path);
}

void openScreen(BuildContext context, Screen screen, [dynamic arg]) {
  toastification.dismissAll();
  Navigator.pushNamed(context, screen.path, arguments: arg);
}
