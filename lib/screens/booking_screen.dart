import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/servicio.dart';
import 'package:dio/dio.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Servicio> servicios = [];
  List<Map<String, dynamic>> barberos = [];
  List<Map<String, dynamic>> availableSlots = [];
  Servicio? selectedServicio;
  Map<String, dynamic>? selectedBarbero;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() => loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final respS = await auth.api.get('/api/servicios');
      final dataS = respS.data;
      final listS = (dataS['data'] as List<dynamic>?) ?? [];
      servicios = listS.map((e) => Servicio.fromMap(e as Map<String, dynamic>)).toList();

      final respB = await auth.api.get('/api/barberos');
      final dataB = respB.data;
      final listB = (dataB['data'] as List<dynamic>?) ?? [];
      barberos = listB.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando opciones: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
    await _loadSlotsIfNeeded();
  }

  Future<void> _loadSlotsIfNeeded() async {
    if (selectedBarbero == null || selectedDate == null || selectedServicio == null) return;
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final resp = await auth.api.get('/api/citas/slots-disponibles', queryParameters: {
        'barberId': selectedBarbero!['id'].toString(),
        'date': _formatDate(selectedDate!),
        'duration': selectedServicio!.duracionMinutos.toString(),
      });
      final data = resp.data;
      // data expected: list of {hora: '09:00:00', disponible: true, razon: null}
      final list = (data as List<dynamic>?) ?? [];
      availableSlots = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando horarios: $e')));
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) setState(() => selectedTime = picked);
  }

  String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  
  String _to24(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _submit() async {
    if (selectedServicio == null || selectedBarbero == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona servicio, barbero, fecha y hora')));
      return;
    }
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y teléfono son obligatorios')));
      return;
    }

    final payload = {
      'barberId': (selectedBarbero!['id'] is num) ? (selectedBarbero!['id'] as num).toInt() : int.parse('${selectedBarbero!['id']}'),
      'date': _formatDate(selectedDate!),
      'startTime': _to24(selectedTime!),
      'duration': selectedServicio!.duracionMinutos,
      'clientName': _nameCtrl.text.trim(),
      'clientPhone': _phoneCtrl.text.trim(),
      'service': selectedServicio!.nombre,
    };

    setState(() => submitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final resp = await auth.api.post('/api/citas', payload);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cita creada'),
            content: const Text('La cita fue creada correctamente.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
            ],
          ),
        );
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horario ocupado (409): elige otra hora')));
      } else if (status == 400) {
        final msg = e.response?.data is Map ? (e.response!.data['mensaje'] ?? 'Error de validación') : 'Error de validación';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('400: $msg')));
      } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sin conexión')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar cita')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      DropdownButtonFormField<Servicio>(
                        items: servicios.map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
                        initialValue: selectedServicio,
                        onChanged: (v) async {
                          setState(() {
                            selectedServicio = v;
                            // clear previous time selection when service changes
                            selectedTime = null;
                            availableSlots = [];
                          });
                          await _loadSlotsIfNeeded();
                        },
                        decoration: const InputDecoration(labelText: 'Servicio'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        items: barberos.map((b) => DropdownMenuItem(value: b, child: Text(b['nombre'] ?? ''))).toList(),
                        initialValue: selectedBarbero,
                        onChanged: (v) async {
                          setState(() {
                            selectedBarbero = v;
                            // clear previous time selection when barbero changes
                            selectedTime = null;
                            availableSlots = [];
                          });
                          await _loadSlotsIfNeeded();
                        },
                        decoration: const InputDecoration(labelText: 'Barbero'),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(selectedDate == null ? 'Seleccionar fecha' : _formatDate(selectedDate!))),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(selectedTime == null ? 'Seleccionar hora' : _to24(selectedTime!))),
                        ),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                const SizedBox(height: 8),
                TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                // available slots
                if (availableSlots.isNotEmpty) ...[
                  const Align(alignment: Alignment.centerLeft, child: Text('Horarios disponibles:', style: TextStyle(fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSlots.map((s) {
                      final hora = (s['hora'] ?? '').toString();
                      final disponible = s['disponible'] == true;
                      final display = hora.length >= 5 ? hora.substring(0,5) : hora;
                      return ChoiceChip(
                        label: Text(display),
                        selected: selectedTime != null && selectedTime!.format(context) == display,
                        onSelected: disponible
                            ? (sel) {
                                if (sel) {
                                  // parse display 'HH:mm' into TimeOfDay
                                  final parts = display.split(':');
                                  final t = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                                  setState(() => selectedTime = t);
                                }
                              }
                            : null,
                        selectedColor: Theme.of(context).colorScheme.secondary,
                        disabledColor: Colors.grey.shade300,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                submitting
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _submit, child: const Text('Reservar')),
                      ),
              ]),
            ),
    );
  }
}
