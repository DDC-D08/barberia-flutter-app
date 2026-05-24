import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/cita_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _servicioCtrl = TextEditingController();

  final CitaService _citaService = CitaService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fechaCtrl.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _horaCtrl.text = _formatTime(picked);
      });
    }
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dateTime);
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFF0F172A).withValues(alpha: 0.92),
      labelStyle: const TextStyle(color: Color(0xFFE2E8F0)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x26FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x26FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.4),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona fecha y hora')));
      return;
    }

    setState(() => _submitting = true);

    try {
      await _citaService.agendarCita(
        nombreCliente: _nombreCtrl.text.trim(),
        fecha: _formatDate(_selectedDate!),
        hora: _formatTime(_selectedTime!),
        servicio: _servicioCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita agendada correctamente')));

      _formKey.currentState?.reset();
      _nombreCtrl.clear();
      _fechaCtrl.clear();
      _horaCtrl.clear();
      _servicioCtrl.clear();

      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo agendar: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _servicioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar cita'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A0E14),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E14), Color(0xFF111827), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -40,
                child: _buildGlow(
                    const Color(0xFFF59E0B).withValues(alpha: 0.18), 180),
              ),
              Positioned(
                bottom: -40,
                left: -60,
                child: _buildGlow(
                    const Color(0xFF38BDF8).withValues(alpha: 0.10), 220),
              ),
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Reserva tu cita',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Un diseño oscuro y elegante, alineado al panel web del proyecto.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF111827).withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.14)),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 28,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFF59E0B),
                                            Color(0xFFD97706)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.content_cut,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Agenda rápida',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Nombre, fecha, hora y servicio.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFFCBD5E1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _nombreCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _fieldDecoration(
                                      'Nombre', Icons.person_outline),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Ingresa tu nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _fechaCtrl,
                                  readOnly: true,
                                  onTap: _pickDate,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _fieldDecoration(
                                      'Fecha', Icons.calendar_month_outlined),
                                  validator: (value) {
                                    if (_selectedDate == null ||
                                        value == null ||
                                        value.trim().isEmpty) {
                                      return 'Selecciona una fecha';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _horaCtrl,
                                  readOnly: true,
                                  onTap: _pickTime,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _fieldDecoration(
                                      'Hora', Icons.schedule_outlined),
                                  validator: (value) {
                                    if (_selectedTime == null ||
                                        value == null ||
                                        value.trim().isEmpty) {
                                      return 'Selecciona una hora';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _servicioCtrl,
                                  textCapitalization: TextCapitalization.words,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _fieldDecoration(
                                      'Servicio', Icons.content_cut_outlined),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Escribe el servicio que deseas';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _submitting ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF59E0B),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _submitting
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const Text(
                                            'Agendar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
