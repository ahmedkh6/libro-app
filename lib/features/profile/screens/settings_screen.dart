import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    const Expanded(
                      child: Text('Settings', textAlign: TextAlign.center, style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                      )),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── User Profile Card (Orange Gradient) ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(-0.5, -1),
                      end: Alignment(0.5, 1),
                      colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.ctaShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(color: Color(0x4DFFFFFF), width: 3.24)),
                          boxShadow: [
                            BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 4)),
                          ],
                        ),
                        child: ClipOval(
                          child: user?.photoURL != null
                              ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                              : const Icon(Icons.person, size: 28, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.displayName ?? 'Reader', style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white,
                            )),
                            const SizedBox(height: 4),
                            Text(user?.email ?? '', style: const TextStyle(
                              fontSize: 14, color: Color(0xCCFFFFFF),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 29),

              // ─── Account Section ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Account'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      _SettingsRow(
                        icon: Icons.person_outline,
                        label: 'Profile Settings',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                        onTap: () => context.push('/profile'),
                        showDivider: true,
                      ),
                      _SettingsRow(
                        icon: Icons.bookmark_outline,
                        label: 'Bookmarks',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                        onTap: () => context.push('/bookmarks'),
                        showDivider: true,
                      ),
                      _SettingsRow(
                        icon: Icons.lock_outline,
                        label: 'Privacy & Security',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                        onTap: () {},
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 29),

              // ─── Preferences Section ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Preferences'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      _SettingsRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        trailing: Switch(
                          value: _notifications,
                          onChanged: (v) => setState(() => _notifications = v),
                        ),
                        showDivider: true,
                      ),
                      _SettingsRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (v) => ref.read(themeModeProvider.notifier).toggleTheme(),
                        ),
                        showDivider: true,
                      ),
                      _SettingsRow(
                        icon: Icons.language,
                        label: 'Language',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('English', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                          ],
                        ),
                        onTap: () {},
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 29),

              // ─── Support Section ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Support'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      _SettingsRow(
                        icon: Icons.help_outline,
                        label: 'Help Center',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                        onTap: () {},
                        showDivider: true,
                      ),
                      _SettingsRow(
                        icon: Icons.info_outline,
                        label: 'About',
                        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                        onTap: () {},
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 29),

              // ─── Sign Out ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () async {
                    await authService.signOut();
                    if (context.mounted) context.go('/auth');
                  },
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppTheme.signOutBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.signOutBorder, width: 0.81),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20, color: AppTheme.deleteRed),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.deleteRed,
                        )),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version
              const Text('Reader App v1.0.0', style: TextStyle(
                fontSize: 14, color: AppTheme.textMuted,
              )),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Title ───
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(title, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary,
      )),
    );
  }
}

// ─── Settings Card Container ───
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.81),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

// ─── Settings Row ───
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGray,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.textPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: const TextStyle(
                    fontSize: 16, color: AppTheme.textPrimary,
                  )),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 68, color: AppTheme.border),
      ],
    );
  }
}
