import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat_screen.dart';
import 'themes/lex_theme.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'LexX Axiom',
        theme: lexTheme,
        home: const ChatScreen(),
      ),
    ),
  );
}
