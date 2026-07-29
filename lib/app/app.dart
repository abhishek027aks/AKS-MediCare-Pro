import 'package:flutter/material.dart';

import '../shared/services/snackbar_service.dart';
import 'router.dart';
import 'theme.dart';

class AKSMediCareProApp extends StatelessWidget {
  const AKSMediCareProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AKS MediCare Pro',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      scaffoldMessengerKey: SnackbarService.messengerKey,
    );
  }
}