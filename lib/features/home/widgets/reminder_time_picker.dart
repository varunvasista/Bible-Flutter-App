import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class ReminderTimePicker extends StatefulWidget {
  const ReminderTimePicker({
    super.key,
    required this.enabled,
    required this.selectedTime,
    required this.onChanged,
  });

  final bool enabled;
  final TimeOfDay selectedTime;
  final Future<void> Function(bool enabled, TimeOfDay time) onChanged;

  @override
  State<ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  late bool _enabled;
  late TimeOfDay _time;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
    _time = widget.selectedTime;
  }

  @override
  void didUpdateWidget(covariant ReminderTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.selectedTime != widget.selectedTime) {
      _enabled = widget.enabled;
      _time = widget.selectedTime;
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() {
      _enabled = value;
      _busy = true;
    });
    await widget.onChanged(_enabled, _time);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Choose daily reminder time',
    );
    if (picked == null) return;

    setState(() {
      _time = picked;
      _busy = true;
    });
    await widget.onChanged(_enabled, _time);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _time.format(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Daily Reminder',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: _enabled,
                onChanged: _busy ? null : _toggle,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _enabled
                ? 'Enabled at $timeText'
                : 'Disabled (last time: $timeText)',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _pickTime,
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('Choose Time'),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Includes scripture, prayer, and notes nudges.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
