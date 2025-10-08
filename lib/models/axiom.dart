import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class Axioms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get hash => text()();
  TextColumn get timestamp => text()();
  TextColumn get signature => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourcePath => text().nullable()();
  TextColumn get domain => text()();
}

@DriftDatabase(tables: [Axioms])
class LexDatabase extends _$LexDatabase {
  LexDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  Future ingestAxiom(String content, String domain, {String? sourcePath}) async {
    final hashBytes = utf8.encode(content);
    final digest = sha256.convert(hashBytes);
    final timestamp = DateTime.now().toIso8601String();
    final signature = 'mock_signature_${digest.toString().substring(0, 16)}'; // Replace with ECDSA

    await into(axioms).insert(AxiomsCompanion.insert(
      content: content,
      hash: digest.toString(),
      timestamp: timestamp,
      signature: signature,
      sourceType: sourcePath != null ? 'file' : 'text',
      sourcePath: sourcePath,
      domain: domain,
    ));
  }

  Future<String> generateResponse(String input, String domain) async {
    final query = select(axioms)..where((t) => t.content.like('%$input%') & t.domain.equals(domain));
    query.orderBy([(t) => OrderingTerm.desc(t.timestamp)]);
    final match = await query.getSingleOrNull();
    return match?.content ?? 'No axiom found in $domain domain. Add to Lex Library.';
  }

  Future<bool> verifyIntegrity(String domain) async {
    final query = select(axioms)..where((t) => t.domain.equals(domain));
    final rows = await query.get();
    for (final row in rows) {
      final computed = sha256.convert(utf8.encode(row.content)).toString();
      if (computed != row.hash) return false;
    }
    return true;
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'lexicon.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
