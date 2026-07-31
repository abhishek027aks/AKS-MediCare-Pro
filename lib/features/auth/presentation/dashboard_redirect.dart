import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/authentication_service.dart';

class DashboardRedirect extends StatefulWidget {
  const DashboardRedirect({
    super.key,
  });

  @override
  State<DashboardRedirect> createState() =>
      _DashboardRedirectState();
}

class _DashboardRedirectState
    extends State<DashboardRedirect> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final auth =
        AuthenticationService.instance;

    final loggedIn =
        await auth.restoreSession();

    if (!mounted) return;

    if (loggedIn) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
