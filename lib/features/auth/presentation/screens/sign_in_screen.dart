import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      if (mounted) context.go('/library');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Orange gradient icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppTheme.orangeGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.ctaShadow,
                ),
                child: const Icon(Icons.auto_stories, size: 40, color: Colors.white),
              ),

              const SizedBox(height: 40),

              // Welcome title
              const Text('Welcome to Lumina', textAlign: TextAlign.center, style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
              )),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Sign in to access your personal library',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
              ),

              const Spacer(flex: 2),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google G icon (simplified)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('G', textAlign: TextAlign.center, style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700,
                                color: Color(0xFF4285F4),
                              )),
                            ),
                            const SizedBox(width: 12),
                            const Text('Continue with Google', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                            )),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Legal text
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
