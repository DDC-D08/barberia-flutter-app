import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../models/servicio.dart';
import 'booking_screen.dart';
import 'citas_screen.dart';
import '../services/api_client.dart' as api_client;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Servicio> servicios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedOrRemote();
  }

  Future<void> _loadCachedOrRemote() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cache_servicios');
    if (cached != null) {
      try {
        final decoded = json.decode(cached) as List<dynamic>;
        servicios = decoded
            .map((e) => Servicio.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    // then refresh remote
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final resp = await auth.api.get('/api/servicios/activos');
      final list = api_client.normalizeArrayResponse<dynamic>(resp.data);
      servicios =
          list.map((e) => Servicio.fromMap(e as Map<String, dynamic>)).toList();
      // cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_servicios', json.encode(list));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error cargando servicios: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios'), actions: [
        IconButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CitasScreen())),
            icon: const Icon(Icons.list_alt),
            tooltip: 'Mis citas'),
      ]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: servicios.length,
                itemBuilder: (_, i) {
                  final s = servicios[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      title: Text(s.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(s.descripcion,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('${s.duracionMinutos} min')]),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const BookingScreen())),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const BookingScreen())),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text('Reservar cita')
          ]),
          style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
