import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  List<Map<String, dynamic>> citas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final resp = await auth.api.get('/api/citas');
      final data = resp.data;
      final list = (data['data'] as List<dynamic>?) ?? [];
      citas = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando citas: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCitas,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: citas.length,
                itemBuilder: (_, i) {
                  final c = citas[i];
                  final service = c['service'] ?? c['servicio'] ?? '-';
                  final date = c['date'] ?? c['fecha'] ?? '-';
                  final time = c['startTime'] ?? c['hora'] ?? c['start_time'] ?? '-';
                  final barber = c['barberName'] ?? c['barbero'] ?? c['barber'] ?? '-';
                  final client = c['clientName'] ?? c['cliente'] ?? '-';
                  final status = c['status'] ?? c['estado'] ?? '-';
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('$date $time\nBarbero: $barber\nCliente: $client', maxLines: 3, overflow: TextOverflow.ellipsis),
                      isThreeLine: true,
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(status.toString())]),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
