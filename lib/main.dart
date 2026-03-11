import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:libro/core/router/app_router.dart';
import 'package:libro/core/theme/app_theme.dart';
import 'package:libro/core/theme/theme_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libro/data/models/book.dart';
import 'package:libro/data/models/reading_progress.dart';
import 'package:libro/data/models/bookmark.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive local storage
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(BookStatusAdapter());
  Hive.registerAdapter(ReadingProgressAdapter());
  Hive.registerAdapter(BookmarkAdapter());

  // Open the books box eagerly so it's ready for the provider
  await Hive.openBox<Book>('books_box');

  runApp(
    const ProviderScope(
      child: LibroApp(),
    ),
  );
}

class LibroApp extends ConsumerWidget {
  const LibroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Libro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
