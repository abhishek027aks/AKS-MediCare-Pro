import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../branches/data/repositories/branch_repository.dart';
import '../../../branches/models/branch_model.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.selectedRole});

  /// The role picked on the Role Selection screen, if the person
  /// came from there. When set, the account that logs in must
  /// actually have this role — otherwise the login is reverted and
  /// an error shown, rather than silently letting anyone in under
  /// whatever role they clicked.
  final String? selectedRole;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  List<BranchModel> _branches = [];
  int? _selectedBranchId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSession();
    });

    _loadBranches();
  }

  Future<void> _loadBranches() async {
    final branches = await BranchRepository.instance.getActiveBranches();
    if (!mounted) return;
    setState(() => _branches = branches);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    await ref
        .read(authProvider.notifier)
        .restoreSession();

    if (!mounted) return;

    final authenticated =
        ref.read(isAuthenticatedProvider);

    if (authenticated) {
      context.go('/dashboard');
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < 3) {
      return 'Enter valid username';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Minimum 6 characters required';
    }

    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success =
        await ref.read(authProvider.notifier).login(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            );

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error),
        ),
      );
      return;
    }

    // A role was picked before login — the account has to actually
    // hold that role, or this isn't the right account for this door.
    if (widget.selectedRole != null) {
      final loggedInUser = ref.read(authProvider).user;

      if (loggedInUser != null && loggedInUser.role != widget.selectedRole) {
        await ref.read(authProvider.notifier).logout();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'This account is registered as ${loggedInUser.role}, not ${widget.selectedRole}.',
            ),
          ),
        );
        return;
      }
    }

    final loggedInUser = ref.read(authProvider).user;

    if (loggedInUser != null && loggedInUser.mustChangePassword) {
      context.go('/change-password');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login Successful'),
      ),
    );
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authLoadingProvider);

    final bool isDesktop =
        MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450 : double.infinity,
              ),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),

                        CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.local_hospital,
                            size: 46,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'AKS MediCare Pro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Hospital & Clinic Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        if (widget.selectedRole != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.center,
                            child: Chip(
                              avatar: const Icon(Icons.badge_outlined, size: 18),
                              label: Text('Logging in as ${widget.selectedRole}'),
                              onDeleted: () => context.go('/role-selection'),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        TextFormField(
                          controller: _usernameController,
                          keyboardType:
                              TextInputType.text,
                          validator: _validateUsername,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon:
                                Icon(Icons.person_outline),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_branches.isNotEmpty)
                          DropdownButtonFormField<int>(
                            initialValue: _selectedBranchId,
                            decoration: const InputDecoration(
                              labelText: 'Branch (optional)',
                              prefixIcon: Icon(Icons.storefront_outlined),
                            ),
                            items: _branches
                                .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedBranchId = value),
                          ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Forgot Password feature coming soon.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        AppButton(
                          text: 'Login',
                          icon: Icons.login,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _login,
                        ),

                        const SizedBox(height: 24),

                        const Divider(),

                        const SizedBox(height: 12),

                        Text(
                          '© 2026 AKS MediCare Pro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Hospital & Clinic Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
}
