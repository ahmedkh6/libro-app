import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../library/providers/book_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final books = ref.watch(bookListProvider);

    final totalBooks = books.length;
    final inProgress = books.where((b) {
      final p = b.readingProgress;
      if (p == null) return false;
      final total = b.totalPages ?? 0;
      if (total == 0) return false;
      final pct = (p.currentPage ?? 0) / total;
      return pct > 0 && pct < 1.0;
    }).length;
    final completed = books.where((b) {
      final p = b.readingProgress;
      if (p == null) return false;
      final total = b.totalPages ?? 0;
      if (total == 0) return false;
      return (p.currentPage ?? 0) / total >= 1.0;
    }).length;
    final pagesRead = books.fold<int>(0, (sum, b) => sum + (b.readingProgress?.currentPage ?? 0));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // ─── Header ───
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceGray,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, size: 20, color: AppTheme.textPrimary),
                        ),
                      ),
                      const Expanded(
                        child: Text('Profile', textAlign: TextAlign.center, style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                        )),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                ),

                // ─── Avatar ───
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border, width: 2),
                  ),
                  child: ClipOval(
                    child: user?.photoURL != null
                        ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 40, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Email
                Text(user?.displayName ?? 'Reader', style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                )),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(
                  fontSize: 16, color: AppTheme.textSecondary,
                )),
                const SizedBox(height: 32),

                // ─── Stats Grid ───
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    _StatCard(
                      icon: Icons.auto_stories,
                      iconColor: AppTheme.accent,
                      value: '$totalBooks',
                      label: 'Total Books',
                    ),
                    _StatCard(
                      icon: Icons.play_circle_outline,
                      iconColor: const Color(0xFF3B82F6),
                      value: '$inProgress',
                      label: 'In Progress',
                    ),
                    _StatCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF22C55E),
                      value: '$completed',
                      label: 'Completed',
                    ),
                    _StatCard(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      value: '$pagesRead',
                      label: 'Pages Read',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ─── Recent Activity ───
                if (books.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Recent Activity', style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                    )),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border, width: 0.81),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: List.generate(
                        books.length > 5 ? 5 : books.length,
                        (index) {
                          final book = books[index];
                          final p = book.readingProgress;
                          final total = book.totalPages ?? 1;
                          final pct = p != null && total > 0
                              ? (((p.currentPage ?? 0) / total) * 100).toStringAsFixed(0)
                              : '0';
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Thumbnail
                                    Container(
                                      width: 40,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppTheme.surfaceGray,
                                      ),
                                      child: book.coverPath != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.file(
                                                File(book.coverPath!),
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(child: Text(
                                              book.title.substring(0, 1),
                                              style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textMuted),
                                            )),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                                          const SizedBox(height: 2),
                                          Text(book.author, maxLines: 1,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Text('$pct%', style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.accent,
                                    )),
                                  ],
                                ),
                              ),
                              if (index < (books.length > 5 ? 4 : books.length - 1))
                                const Divider(height: 1, indent: 68, color: AppTheme.border),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Text('Member since March 2026', style: TextStyle(
                  fontSize: 14, color: AppTheme.textMuted,
                )),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.iconColor, required this.value, required this.label});
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.81),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            fontSize: 14, color: AppTheme.textSecondary,
          )),
        ],
      ),
    );
  }
}
