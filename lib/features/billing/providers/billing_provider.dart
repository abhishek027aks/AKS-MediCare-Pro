import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/billing_repository.dart';
import '../models/bill_model.dart';

/// ===============================
/// Billing State
/// ===============================
class BillingState {
  final bool isLoading;
  final List<BillModel> bills;
  final String? errorMessage;

  const BillingState({
    this.isLoading = false,
    this.bills = const [],
    this.errorMessage,
  });

  BillingState copyWith({
    bool? isLoading,
    List<BillModel>? bills,
    String? errorMessage,
  }) {
    return BillingState(
      isLoading: isLoading ?? this.isLoading,
      bills: bills ?? this.bills,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Billing Provider
/// ===============================
class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier() : super(const BillingState()) {
    loadBills();
  }

  final BillingRepository _repository = BillingRepository.instance;

  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bills = await _repository.getAllBills();

      state = state.copyWith(isLoading: false, bills: bills);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addBill(BillModel bill) async {
    try {
      await _repository.createBill(bill);
      await loadBills();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateBill(BillModel bill) async {
    try {
      await _repository.updateBill(bill);
      await loadBills();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteBill(int id) async {
    try {
      await _repository.deleteBill(id);
      await loadBills();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadBills();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>(
  (ref) => BillingNotifier(),
);
