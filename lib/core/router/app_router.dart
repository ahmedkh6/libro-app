import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/library/screens/search_screen.dart';
import '../../features/library/screens/book_detail_screen.dart';
import '../../features/library/screens/import_book_screen.dart';
import '../../features/library/screens/edit_book_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/reader/screens/pdf_reader_screen.dart';
import '../../features/library/screens/bookmarks_screen.dart';
import '../../data/models/book.dart';
import '../widgets/shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const SignInScreen(),
      ),
      // Full-screen overlays (no bottom nav)
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/reader',
        builder: (context, state) {
          final book = state.extra as Book;
          return PdfReaderScreen(book: book);
        },
      ),
      GoRoute(
        path: '/book-detail',
        builder: (context, state) {
          final book = state.extra as Book;
          return BookDetailScreen(book: book);
        },
      ),
      GoRoute(
        path: '/import-book',
        builder: (context, state) => const ImportBookScreen(),
      ),
      GoRoute(
        path: '/edit-book',
        builder: (context, state) {
          final book = state.extra as Book;
          return EditBookScreen(book: book);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),

      // Shell routes (with bottom nav)
      ShellRoute(
        builder: (context, state, child) {
          return ShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
