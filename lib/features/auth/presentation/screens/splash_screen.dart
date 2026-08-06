import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_state_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  double _progress = 0;
  String _statusMessage = 'Initializing modules, please wait...';

  static const List<String> _statusMessages = [
    'Initializing modules, please wait...',
    'Loading patient records engine...',
    'Preparing offline database...',
    'Setting up secure session...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _logoScale = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.7, curve: Curves.easeIn));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));

    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    for (var i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;

      setState(() {
        _progress = i / 20;
        final messageIndex = (i / 20 * (_statusMessages.length - 1)).floor();
        _statusMessage = _statusMessages[messageIndex];
      });
    }

    await ref.read(authProvider.notifier).restoreSession();

    if (!mounted) return;

    final alreadyLoggedIn = ref.read(isAuthenticatedProvider);

    if (!alreadyLoggedIn) {
      context.go('/role-selection');
      return;
    }

    final user = ref.read(currentUserProvider);

    context.go(user != null && user.mustChangePassword ? '/change-password' : '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3F6F8), Color(0xFFE8F1F0), Color(0xFFEFF7F5)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slideUp,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 640 : double.infinity),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.topRight,
                            child: _madeInIndiaBadge(),
                          ),
                          const SizedBox(height: 20),
                          ScaleTransition(
                            scale: _logoScale,
                            child: _LogoBlock(isDesktop: isDesktop),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'सेवा ही हमारा धर्म,',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE07A1F)),
                          ),
                          const Text(
                            'स्वास्थ्य ही हमारा कर्म।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                          ),
                          const SizedBox(height: 12),
                          Container(width: 140, height: 2, color: const Color(0xFF00695C).withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'हर डॉक्टर की मेहनत, हर मरीज की मुस्कान,\nएक स्वस्थ भारत का है यही अरमान।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF4A4A4A)),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: const [
                              _FeatureCard(icon: Icons.shield_outlined, label: 'Secure'),
                              _FeatureCard(icon: Icons.wifi_off, label: 'Offline First'),
                              _FeatureCard(icon: Icons.storage_outlined, label: 'Reliable'),
                              _FeatureCard(icon: Icons.groups_outlined, label: 'For Every Patient'),
                              _FeatureCard(icon: Icons.favorite_outline, label: 'For Every Doctor'),
                              _FeatureCard(icon: Icons.map_outlined, label: 'For Every Indian'),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Loading AKS MediCare Pro...',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B3A57)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: _progress,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFD8E2E4),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E6FE0)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E6FE0)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_statusMessage, style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B))),
                          const SizedBox(height: 24),
                          const _HeartbeatLine(),
                          const SizedBox(height: 24),
                          if (isDesktop) _bottomBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _madeInIndiaBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1B3A57).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🇮🇳', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text('MADE IN INDIA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B3A57))),
          SizedBox(width: 6),
          Text('🇮🇳', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF0D2B4E), borderRadius: BorderRadius.circular(10)),
      child: const Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 20,
        runSpacing: 10,
        children: [
          _BottomBarItem(icon: Icons.shield_outlined, label: 'Better Healthcare'),
          _BottomBarItem(icon: Icons.trending_up, label: 'Better Management'),
          _BottomBarItem(icon: Icons.settings_outlined, label: 'Better Technology'),
          _BottomBarItem(icon: Icons.map_outlined, label: 'Better India'),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isDesktop ? 100 : 84,
          height: isDesktop ? 100 : 84,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.local_hospital, size: isDesktop ? 54 : 46, color: const Color(0xFF1E6FE0)),
              Positioned(
                left: isDesktop ? 12 : 10,
                child: Icon(Icons.favorite, size: isDesktop ? 26 : 22, color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: isDesktop ? 34 : 26, fontWeight: FontWeight.w900, color: const Color(0xFF0D2B4E)),
            children: const [
              TextSpan(text: 'AKS\n'),
              TextSpan(text: 'MediCare ', style: TextStyle(color: Color(0xFF1E6FE0))),
              TextSpan(
                text: 'Pro',
                style: TextStyle(color: Colors.white, backgroundColor: Color(0xFF0D2B4E), fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enterprise Offline-First\nHospital & Clinic Management System',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF5A6B7A)),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE6E8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF1E6FE0), size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1B3A57)),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _HeartbeatLine extends StatelessWidget {
  const _HeartbeatLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 24,
      child: CustomPaint(painter: _HeartbeatPainter()),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E6FE0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;
    final path = Path()
      ..moveTo(0, midY)
      ..lineTo(size.width * 0.30, midY)
      ..lineTo(size.width * 0.38, 2)
      ..lineTo(size.width * 0.46, size.height - 2)
      ..lineTo(size.width * 0.54, midY)
      ..lineTo(size.width * 0.70, midY)
      ..lineTo(size.width, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
