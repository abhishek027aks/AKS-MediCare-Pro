import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Animate a progress bar while the app does its real startup work
    // (DB init happens lazily on first query, so this is mostly a
    // deliberate branding pause plus the session check below).
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }

    final alreadyLoggedIn = await AuthRepository.instance.restoreSession();

    if (!mounted) return;

    context.go(alreadyLoggedIn ? '/dashboard' : '/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF003B36), Color(0xFF00695C), Color(0xFF00897B)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('MADE IN INDIA', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                      SizedBox(width: 6),
                      Text('🇮🇳', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.local_hospital, size: 62, color: Color(0xFF00695C)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'AKS MediCare Pro',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enterprise Offline-First Hospital & Clinic Management System',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                const Text(
                  'सेवा ही हमारा धर्म, स्वास्थ्य ही हमारा कर्म',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const Spacer(flex: 2),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeatureBadge(icon: Icons.wifi_off, label: 'Offline First'),
                    _FeatureBadge(icon: Icons.shield_outlined, label: 'Secure'),
                    _FeatureBadge(icon: Icons.verified_outlined, label: 'Reliable'),
                    _FeatureBadge(icon: Icons.business_outlined, label: 'Enterprise'),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Initializing System, Please Wait...', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Spacer(),
                const Text(
                  '© 2026 AKS MediCare Pro. All Rights Reserved.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
