import 'dart:async';

import 'package:flutter/material.dart';

import '../data/sync_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncService _service = SyncService.instance;
  final TextEditingController _portController = TextEditingController(text: '8888');
  final TextEditingController _hostIpController = TextEditingController();
  final TextEditingController _clientPortController = TextEditingController(text: '8888');

  final List<String> _log = [];
  StreamSubscription<String>? _logSubscription;

  bool _isConnecting = false;
  List<String> _localIps = [];

  @override
  void initState() {
    super.initState();

    _logSubscription = _service.logs.listen((line) {
      if (!mounted) return;
      setState(() => _log.insert(0, line));
    });

    _loadLocalIps();
  }

  Future<void> _loadLocalIps() async {
    final ips = await SyncService.getLocalIpAddresses();
    if (!mounted) return;
    setState(() => _localIps = ips);
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _portController.dispose();
    _hostIpController.dispose();
    _clientPortController.dispose();
    super.dispose();
  }

  Future<void> _toggleHosting() async {
    if (_service.isHosting) {
      await _service.stopHosting();
      setState(() {});
      return;
    }

    final port = int.tryParse(_portController.text.trim()) ?? 8888;

    try {
      await _service.startHosting(port: port);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start hosting: $e')),
      );
    }

    setState(() {});
  }

  Future<void> _connect() async {
    final host = _hostIpController.text.trim();
    final port = int.tryParse(_clientPortController.text.trim()) ?? 8888;

    if (host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the host device\'s IP address')),
      );
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final summary = await _service.connectAndSync(host: host, port: port);

      if (!mounted) return;

      final lines = summary.tables.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
          title: const Text('Sync Complete'),
          content: SingleChildScrollView(
            child: Text(
              'Inserted: ${summary.totalInserted}   '
              'Updated: ${summary.totalUpdated}   '
              'Skipped: ${summary.totalSkipped}\n\n$lines',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAN Sync'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Both devices must be on the same Wi-Fi / LAN. One device hosts, the other '
                'connects using the host\'s IP address. Only clinical/operational records '
                '(patients, OPD, IPD, billing, pharmacy, lab) are synced — user accounts and '
                'staff logins stay local to each device.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Host This Device', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_localIps.isEmpty)
                    const Text('Detecting local IP address...')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _localIps
                          .map((ip) => Chip(avatar: const Icon(Icons.wifi, size: 18), label: Text(ip)))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _portController,
                          enabled: !_service.isHosting,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _toggleHosting,
                        style: FilledButton.styleFrom(
                          backgroundColor: _service.isHosting ? Colors.red : null,
                        ),
                        icon: Icon(_service.isHosting ? Icons.stop : Icons.wifi_tethering),
                        label: Text(_service.isHosting ? 'Stop Hosting' : 'Start Hosting'),
                      ),
                    ],
                  ),
                  if (_service.isHosting) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Hosting on port ${_service.hostingPort} — waiting for other devices to connect.',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Connect to Another Device', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _hostIpController,
                    enabled: !_isConnecting,
                    decoration: const InputDecoration(
                      labelText: 'Host IP Address',
                      hintText: 'e.g. 192.168.1.42',
                      prefixIcon: Icon(Icons.dns_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clientPortController,
                    enabled: !_isConnecting,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isConnecting ? null : _connect,
                      icon: _isConnecting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_isConnecting ? 'Syncing...' : 'Sync Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Activity Log', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _log.isEmpty
                  ? const Text('No activity yet.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _log
                          .take(30)
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Text(line, style: const TextStyle(fontSize: 13)),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
