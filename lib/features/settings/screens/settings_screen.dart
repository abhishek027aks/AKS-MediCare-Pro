import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../sync/screens/sync_screen.dart';
import '../data/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBackingUp = false;
  bool _isBusyWithBackup = false;
  List<BackupFileInfo> _backups = [];
  bool _loadingBackups = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _loadingBackups = true);
    final backups = await BackupService.listBackups();
    if (!mounted) return;
    setState(() {
      _backups = backups;
      _loadingBackups = false;
    });
  }

  Future<void> _backup() async {
    setState(() => _isBackingUp = true);

    final result = await BackupService.backupDatabase();

    if (!mounted) return;
    setState(() => _isBackingUp = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) {
      await _loadBackups();
    }
  }

  Future<void> _restore(BackupFileInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
        title: const Text('Restore Database'),
        content: Text(
          'This will replace all current data with the contents of "${backup.fileName}". '
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBusyWithBackup = true);

    final result = await BackupService.restoreDatabase(backup.path);

    if (!mounted) return;
    setState(() => _isBusyWithBackup = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _delete(BackupFileInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Delete "${backup.fileName}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await BackupService.deleteBackup(backup.path);
    await _loadBackups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.local_hospital, size: 52),
                  SizedBox(height: 12),
                  Text(
                    'AKS MediCare Pro',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text('Offline-first Hospital Management System'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Database Backups', style: Theme.of(context).textTheme.titleLarge),
              FilledButton.icon(
                onPressed: _isBackingUp ? null : _backup,
                icon: _isBackingUp
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup_outlined, size: 18),
                label: const Text('Backup Now'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Backups are saved inside the app\'s own data folder — tap one below to restore it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (_loadingBackups)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_backups.isEmpty)
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No backups yet. Tap "Backup Now" to create one.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            Card(
              elevation: 0,
              child: Column(
                children: _backups.map((backup) {
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(backup.fileName),
                        subtitle: Text(
                          '${DateFormat('dd/MM/yyyy hh:mm a').format(backup.createdAt)}  •  ${backup.sizeLabel}',
                        ),
                        trailing: PopupMenuButton<String>(
                          enabled: !_isBusyWithBackup,
                          onSelected: (value) {
                            if (value == 'restore') _restore(backup);
                            if (value == 'delete') _delete(backup);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'restore', child: Text('Restore')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        onTap: _isBusyWithBackup ? null : () => _restore(backup),
                      ),
                      if (backup != _backups.last) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),
          Text('Network', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.sync_outlined),
              title: const Text('LAN Sync'),
              subtitle: const Text('Share data with another device on the same network'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SyncScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
