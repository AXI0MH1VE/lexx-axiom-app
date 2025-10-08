import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animations/animations.dart';
import '../providers/lex_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.1);
  }

  Future _sendMessage() async {
    if (_controller.text.isEmpty) return;
    await ref.read(chatHistoryProvider.notifier).sendMessage(_controller.text);
    _controller.clear();
    _speakLastResponse();
  }

  Future _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
    );
    if (result != null) {
      final bytes = result.files.first.bytes;
      final content = utf8.decode(bytes!);
      await ref.read(chatHistoryProvider.notifier).ingestFile(content, result.files.first.path!);
    }
  }

  Future _startListening() async {
    if (!_isListening) {
      await _speech.initialize();
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        _controller.text = result.recognizedWords;
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future _speakLastResponse() async {
    final history = ref.watch(chatHistoryProvider);
    if (history.isNotEmpty && history.last.role == 'assistant') {
      await _tts.speak(history.last.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(chatHistoryProvider);
    return Scaffold(
      body: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
        blur: 25,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.black.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(colors: [const Color(0xFFFF69B4), Colors.white.withOpacity(0.15)]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('LexX Axiom', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (domain) => ref.read(chatHistoryProvider.notifier).setDomain(domain),
                        itemBuilder: (context) => ['core', 'defi'].map((d) => PopupMenuItem(value: d, child: Text(d, style: const TextStyle(color: Colors.white)))).toList(),
                        icon: const Icon(Icons.filter_alt, color: Color(0xFFFF69B4)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.verified, color: Color(0xFFFF69B4)),
                        onPressed: () async {
                          final verified = await ref.read(chatHistoryProvider.notifier).verify();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(verified ? 'Integrity Verified' : 'Integrity Failed', style: const TextStyle(color: Colors.white))),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final msg = history[index];
                  return OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (context, _) => DetailScreen(content: msg.content, hash: msg.hash, sourcePath: msg.sourcePath),
                    closedBuilder: (context, open) => Align(
                      alignment: msg.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                      child: GlassmorphicContainer(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: null,
                        borderRadius: 20,
                        blur: 15,
                        alignment: Alignment.center,
                        border: 1,
                        linearGradient: LinearGradient(
                          colors: [
                            msg.role == 'user' ? const Color(0xFFFF69B4).withOpacity(0.4) : Colors.white.withOpacity(0.15),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                        borderGradient: LinearGradient(colors: [const Color(0xFFFF69B4), Colors.white.withOpacity(0.1)]),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              if (msg.hash != null)
                                Text('Hash: ${msg.hash!.substring(0, 8)}...', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                              if (msg.sourcePath != null)
                                Text('Source: ${msg.sourcePath}', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: const Color(0xFFFF69B4)),
                    onPressed: _startListening,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type or speak...',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Color(0xFFFF69B4)),
                    onPressed: _uploadFile,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFF69B4)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String content;
  final String? hash;
  final String? sourcePath;

  const DetailScreen({super.key, required this.content, this.hash, this.sourcePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
        blur: 25,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.black.withOpacity(0.85)],
        ),
        borderGradient: LinearGradient(colors: [const Color(0xFFFF69B4), Colors.white.withOpacity(0.15)]),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(content, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              if (hash != null) Text('Hash: $hash', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              if (sourcePath != null) Text('Source: $sourcePath', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
