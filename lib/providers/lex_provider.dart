import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/axiom.dart';

final lexDatabaseProvider = Provider((ref) => LexDatabase());

final chatHistoryProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref.watch(lexDatabaseProvider));
});

class ChatMessage {
  final String role;
  final String content;
  final String? hash;
  final String? sourcePath;

  ChatMessage({required this.role, required this.content, this.hash, this.sourcePath});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final LexDatabase db;
  String currentDomain = 'core';

  ChatNotifier(this.db) : super([]);

  Future sendMessage(String input) async {
    state = [...state, ChatMessage(role: 'user', content: input)];
    final response = await db.generateResponse(input, currentDomain);
    final hash = await _ingestAndHash(input);
    state = [...state, ChatMessage(role: 'assistant', content: response, hash: hash)];
  }

  Future ingestFile(String content, String sourcePath) async {
    const chunkSize = 500;
    const overlap = 50;
    for (var i = 0; i < content.length; i += chunkSize - overlap) {
      final chunk = content.substring(i, (i + chunkSize).clamp(0, content.length));
      final hash = await _ingestAndHash(chunk, sourcePath: sourcePath);
      state = [...state, ChatMessage(role: 'assistant', content: 'Chunk ingested', hash: hash, sourcePath: sourcePath)];
    }
  }

  Future setDomain(String domain) async {
    currentDomain = domain;
  }

  Future<String> _ingestAndHash(String input, {String? sourcePath}) async {
    await db.ingestAxiom(input, currentDomain, sourcePath: sourcePath);
    final hashBytes = utf8.encode(input);
    return sha256.convert(hashBytes).toString();
  }

  Future<bool> verify() async => await db.verifyIntegrity(currentDomain);
}
