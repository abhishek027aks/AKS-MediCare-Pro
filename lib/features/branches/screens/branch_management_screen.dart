import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/branch_model.dart';
import '../providers/branch_provider.dart';

class BranchManagementScreen extends ConsumerWidget {
  const BranchManagementScreen({super.key});

  Future<void> _showBranchDialog(BuildContext context, WidgetRef ref, {BranchModel? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    bool isActive = existing?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Branch' : 'Edit Branch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Branch Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address (optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone (optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final branch = BranchModel(
                  id: existing?.id,
                  name: nameController.text.trim(),
                  address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                  phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                );

                if (existing == null) {
                  await ref.read(branchProvider.notifier).addBranch(branch);
                } else {
                  await ref.read(branchProvider.notifier).updateBranch(branch);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, BranchModel branch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Delete "${branch.name}"? Users/patients already assigned to it keep the label but won\'t be reassignable to it anymore.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && branch.id != null) {
      await ref.read(branchProvider.notifier).deleteBranch(branch.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(branchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBranchDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Branch'),
      ),
      body: state.isLoading
          ? const LinearProgressIndicator()
          : state.branches.isEmpty
              ? const Center(child: Text('No branches yet. Add your first one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.branches.length,
                  itemBuilder: (context, index) {
                    final branch = state.branches[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (branch.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.15),
                          child: Icon(
                            Icons.storefront_outlined,
                            color: branch.isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text(branch.name),
                        subtitle: Text([
                          if (branch.address != null) branch.address!,
                          if (branch.phone != null) branch.phone!,
                        ].join('  •  ')),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _showBranchDialog(context, ref, existing: branch);
                            if (value == 'delete') _confirmDelete(context, ref, branch);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
