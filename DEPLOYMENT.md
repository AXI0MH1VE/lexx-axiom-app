1	Setup:
◦	Install Flutter 3.24+: flutter upgrade.
◦	Create project: flutter create lexx_axiom_app && cd lexx_axiom_app.
◦	Replace files with above.
2	Dependencies:flutter pub get
3	
4	Build:
◦	Android: flutter build apk --release
◦	iOS: flutter build ios --release (Xcode, Apple Developer account required).
◦	Windows: flutter build windows --release.
5	Run:
◦	Development: flutter run (hot reload on emulator/device).
◦	First launch: Select domain (core/defi), type/speak/upload TXT/PDF.
◦	Voice: Grant mic permissions; TTS auto-plays responses with pitch 1.1.
◦	File: Upload TX logs, validate via DeFi schema.
6	Audit:flutter run -t test/audit_test.dart
7	
◦	Verifies Lex Library integrity for selected domain.
8	Rollback:
◦	Delete app data: flutter clean && rm -rf ~/lexicon.sqlite.
◦	Rebuild: flutter pub get && flutter build.
