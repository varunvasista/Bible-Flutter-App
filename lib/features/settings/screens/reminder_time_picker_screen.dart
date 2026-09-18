import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class ReminderTimePickerScreen extends StatefulWidget {
  const ReminderTimePickerScreen({
    super.key,
    required this.initialTime,
    required this.title,
    required this.description,
    required this.onSave,
  });

  final TimeOfDay initialTime;
  final String title;
  final String description;
  final Future<void> Function(TimeOfDay pickedTime) onSave;

  @override
  State<ReminderTimePickerScreen> createState() => _ReminderTimePickerScreenState();
}

class _ReminderTimePickerScreenState extends State<ReminderTimePickerScreen> {
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hourOfPeriod == 0 ? 12 : widget.initialTime.hourOfPeriod;
    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = widget.initialTime.period == DayPeriod.am ? 'AM' : 'PM';
  }

  void _saveReminderTime() async {
    int hour24 = _selectedHour;
    if (_selectedPeriod == 'PM' && _selectedHour != 12) {
      hour24 += 12;
    } else if (_selectedPeriod == 'AM' && _selectedHour == 12) {
      hour24 = 0;
    }

    final finalTime = TimeOfDay(hour: hour24, minute: _selectedMinute);
    await widget.onSave(finalTime);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildHourPicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: _selectedHour - 1),
      itemExtent: 44,
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedHour = index + 1;
        });
      },
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: AppColors.transparent),
      children: List.generate(12, (i) {
        final val = i + 1;
        final isSelected = val == _selectedHour;
        return Center(
          child: Text(
            '$val',
            style: TextStyle(
              fontSize: 22,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMinutePicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: _selectedMinute),
      itemExtent: 44,
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedMinute = index;
        });
      },
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: AppColors.transparent),
      children: List.generate(60, (i) {
        final isSelected = i == _selectedMinute;
        final label = i.toString().padLeft(2, '0');
        return Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPeriodPicker() {
    final initialIndex = _selectedPeriod == 'AM' ? 0 : 1;
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: initialIndex),
      itemExtent: 44,
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedPeriod = index == 0 ? 'AM' : 'PM';
        });
      },
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: AppColors.transparent),
      children: ['AM', 'PM'].map((p) {
        final isSelected = p == _selectedPeriod;
        return Center(
          child: Text(
            p,
            style: TextStyle(
              fontSize: 22,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePickerWheel() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Selected row highlight
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // CupertinoPickers
          Row(
            children: [
              Expanded(child: _buildHourPicker()),
              Expanded(child: _buildMinutePicker()),
              Expanded(child: _buildPeriodPicker()),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                        const Spacer(),

                        // Centered Reminder Card
                        Center(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Time Picker
                                _buildTimePickerWheel(),

                                const SizedBox(height: 24),

                                // Primary Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: FilledButton(
                                    onPressed: _saveReminderTime,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Save Reminder',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Secondary Action
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Scripture Quote
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(
                              '"Be still, and know that I am God."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
