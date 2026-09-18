import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/services/service_locator.dart';
import 'reminder_time_picker_screen.dart';
import 'package:bible_app/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _customDaysController;
  late String _translation;
  late String _readingPlan;
  late double _fontScale;
  late bool _highContrast;
  late bool _largeVerseText;

  bool _bibleReminderEnabled = true;
  TimeOfDay _bibleReminderTime = const TimeOfDay(hour: 7, minute: 0);
  bool _prayerReminderEnabled = true;
  TimeOfDay _prayerReminderTime = const TimeOfDay(hour: 7, minute: 40);

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _customDaysController = TextEditingController();
    _translation = settingsService.preferredTranslation;
    _readingPlan = readingPlanService
        .getPlanByName(settingsService.selectedReadingPlan)
        .name;
    _fontScale = accessibilityService.fontScale;
    _highContrast = accessibilityService.highContrast;
    _largeVerseText = accessibilityService.largeVerseText;
    _loadReminderSettings();
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final reminderSettings = await reminderService.loadSettings();
      if (!mounted) return;
      setState(() {
        _bibleReminderEnabled = reminderSettings.bibleReadingEnabled;
        _bibleReminderTime = reminderSettings.bibleReadingTime;
        _prayerReminderEnabled = reminderSettings.prayerEnabled;
        _prayerReminderTime = reminderSettings.prayerTime;
      });
    } catch (_) {
      // Keep defaults when local reminder settings cannot be loaded.
    }
  }

  Future<void> _saveTranslation(String value) async {
    setState(() => _translation = value);
    await settingsService.savePreferredTranslation(value);
    await bibleRepo.ensureLoaded(value);
    appPreferencesNotifier.value++;
  }

  Future<void> _savePlan(String planName) async {
    await settingsService.saveSelectedReadingPlan(planName);
    if (!mounted) return;
    setState(() => _readingPlan = planName);
  }

  void _showReadingPlanUpdatedMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Reading plan updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _durationLabelFromPlanName(String planName) {
    final lower = planName.toLowerCase();
    if (lower.contains('custom')) return 'Custom';
    final match = RegExp(r'(\d+)').firstMatch(planName);
    final days = int.tryParse(match?.group(1) ?? '');
    if (days == null) return '30 days';
    return '$days days';
  }

  Future<void> _onDurationChanged(String label) async {
    if (label == 'Custom') {
      final existing = await readingPlanService.getCustomPlanDays();
      if (!mounted) return;
      final customDays = await _pickCustomPlanDays(existing);
      if (!mounted) return;
      if (customDays == null) return;

      final changed =
          await readingPlanService.selectPlanByDays(customDays, custom: true);
      final planName = readingPlanService.getPlanByName('Custom Plan').name;
      await _savePlan(planName);
      if (!mounted) return;
      if (changed) {
        await readingProgressService.clearAll();
        appPreferencesNotifier.value++;
        _showReadingPlanUpdatedMessage();
      }
      return;
    }

    final days = int.tryParse(label.split(' ').first);
    if (days == null) return;
    final changed = await readingPlanService.selectPlanByDays(days);
    if (!mounted) return;
    final planName = readingPlanService.getPlanByName('$days Day Plan').name;
    await _savePlan(planName);
    if (!mounted) return;
    if (changed) {
      await readingProgressService.clearAll();
      appPreferencesNotifier.value++;
      _showReadingPlanUpdatedMessage();
    }
  }

  Future<int?> _pickCustomPlanDays(int initialDays) async {
    _customDaysController.text = initialDays.toString();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom Plan Duration'),
        content: TextField(
          controller: _customDaysController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of days',
            hintText: 'e.g. 120',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(_customDaysController.text.trim());
              if (value == null || value < 7 || value > 1500) {
                Navigator.of(dialogContext).pop();
                return;
              }
              Navigator.of(dialogContext).pop(value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted) return null;
    return result;
  }

  Future<void> _saveFontScale(double value) async {
    setState(() => _fontScale = value);
    await accessibilityService.saveFontScale(value);
    appPreferencesNotifier.value++;
  }

  Future<void> _saveHighContrast(bool value) async {
    setState(() => _highContrast = value);
    await accessibilityService.saveHighContrast(value);
    appPreferencesNotifier.value++;
  }

  Future<void> _saveLargeVerseText(bool value) async {
    setState(() => _largeVerseText = value);
    await accessibilityService.saveLargeVerseText(value);
    appPreferencesNotifier.value++;
  }

  Future<void> _toggleBibleReminder(bool enabled) async {
    setState(() => _bibleReminderEnabled = enabled);
    await reminderService.updateBibleReadingReminder(
      enabled: enabled,
      time: _bibleReminderTime,
    );
  }

  Future<void> _togglePrayerReminder(bool enabled) async {
    setState(() => _prayerReminderEnabled = enabled);
    await reminderService.updatePrayerReminder(
      enabled: enabled,
      time: _prayerReminderTime,
    );
  }

  void _pickBibleReminderTime() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReminderTimePickerScreen(
          initialTime: _bibleReminderTime,
          title: 'Bible Reading Reminder',
          description: 'Start your day with God\'s Word.',
          onSave: (pickedTime) async {
            setState(() => _bibleReminderTime = pickedTime);
            await reminderService.updateBibleReadingReminder(
              enabled: _bibleReminderEnabled,
              time: pickedTime,
            );
          },
        ),
      ),
    );
  }

  void _pickPrayerReminderTime() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReminderTimePickerScreen(
          initialTime: _prayerReminderTime,
          title: 'Prayer Reminder',
          description: 'Take a moment to pray.',
          onSave: (pickedTime) async {
            setState(() => _prayerReminderTime = pickedTime);
            await reminderService.updatePrayerReminder(
              enabled: _prayerReminderEnabled,
              time: pickedTime,
            );
          },
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _busy = true);
    try {
      final path = await dataExportService.exportUserData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export saved at $path'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset app data?'),
        content: const Text(
          'This will clear local preferences, notes, bookmarks, highlights, and progress data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.redShade700),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await dataExportService.resetAllData();
      await settingsService.init();
      await accessibilityService.init();
      await streakService.loadCurrentStreak();
      await _loadReminderSettings();
      appPreferencesNotifier.value++;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App data has been reset.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      appResetNotifier.value++;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showTranslationPicker() async {
    final translations = bibleRepo.getTranslations();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Translation'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          children: translations.map((t) {
            final isSelected = t == _translation;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, t),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
    if (result != null) {
      _saveTranslation(result);
    }
  }

  Future<void> _showActivePlanPicker() async {
    final durationOptions = readingPlanService.durationOptions;
    final resolvedDuration = _durationLabelFromPlanName(_readingPlan);
    final selectedDuration = durationOptions.contains(resolvedDuration)
        ? resolvedDuration
        : '30 days';

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Plan Duration'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          children: durationOptions.map((opt) {
            final isSelected = opt == selectedDuration;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, opt),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      opt,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
    if (result != null) {
      _onDurationChanged(result);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required Widget leading,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? leadingBgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: leadingBgColor ??
                    (isDark ? AppColors.darkGray : AppColors.borderLight),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: leading,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ??
                          (isDark ? AppColors.white : AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip({
    required BuildContext context,
    required bool enabled,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 68, top: 4, bottom: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.kyrieDarkGrey
                      : AppColors.border),
            ),
            child: Text(
              enabled ? time.format(context) : '${time.format(context)} (off)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: enabled ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durationOptions = readingPlanService.durationOptions;
    final resolvedDuration = _durationLabelFromPlanName(_readingPlan);
    final selectedDuration = durationOptions.contains(resolvedDuration)
        ? resolvedDuration
        : '30 days';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile & Settings',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: IgnorePointer(
          ignoring: _busy,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // 1. ACCOUNT Section
              _buildSectionHeader('Account'),
              const SizedBox(height: 4),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                      color: isDark ? AppColors.transparent : AppColors.border,
                      width: 1),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        leading: const Icon(Icons.translate_rounded,
                            color: AppColors.primary),
                        title: 'Translation',
                        subtitle: _translation,
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                        onTap: _showTranslationPicker,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _buildSettingsTile(
                        leading: const Icon(Icons.menu_book_rounded,
                            color: AppColors.primary),
                        title: 'Active Plan',
                        subtitle: 'Plan: $selectedDuration',
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                        onTap: _showActivePlanPicker,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. REMINDERS Section
              _buildSectionHeader('Reminders'),
              const SizedBox(height: 4),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                      color: isDark ? AppColors.transparent : AppColors.border,
                      width: 1),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSettingsTile(
                            leading: const Icon(Icons.auto_stories_rounded,
                                color: AppColors.primary),
                            title: 'Bible Reading Reminder',
                            subtitle: 'Start your day with God\'s Word.',
                            trailing: Switch(
                              value: _bibleReminderEnabled,
                              activeColor: AppColors.primary,
                              onChanged: _toggleBibleReminder,
                            ),
                          ),
                          _buildTimeChip(
                            context: context,
                            enabled: _bibleReminderEnabled,
                            time: _bibleReminderTime,
                            onTap: _pickBibleReminderTime,
                          ),
                        ],
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSettingsTile(
                            leading: const FaIcon(
                                FontAwesomeIcons.personPraying,
                                color: AppColors.primary,
                                size: 22),
                            leadingBgColor: AppColors.borderLight,
                            title: 'Prayer Reminder',
                            subtitle: 'Take a moment to pray.',
                            trailing: Switch(
                              value: _prayerReminderEnabled,
                              activeColor: AppColors.primary,
                              onChanged: _togglePrayerReminder,
                            ),
                          ),
                          _buildTimeChip(
                            context: context,
                            enabled: _prayerReminderEnabled,
                            time: _prayerReminderTime,
                            onTap: _pickPrayerReminderTime,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4. ACCESSIBILITY Section
              _buildSectionHeader('Accessibility'),
              const SizedBox(height: 4),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                      color: isDark ? AppColors.transparent : AppColors.border,
                      width: 1),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Font Size',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.primary,
                              ),
                            ),
                            Text(
                              '${_fontScale.toStringAsFixed(2)}x',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('A',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          Expanded(
                            child: Slider(
                              value: _fontScale,
                              min: 0.8,
                              max: 1.4,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.border,
                              onChanged: _saveFontScale,
                            ),
                          ),
                          const Text('A',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _buildSettingsTile(
                        leading: const Icon(Icons.visibility_rounded,
                            color: AppColors.primary),
                        title: 'High Contrast Mode',
                        subtitle: 'Enhance visual clarity for better focus.',
                        trailing: Switch(
                          value: _highContrast,
                          activeColor: AppColors.primary,
                          onChanged: _saveHighContrast,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _buildSettingsTile(
                        leading: const Icon(Icons.format_size_rounded,
                            color: AppColors.primary),
                        title: 'Larger Verse Text',
                        subtitle:
                            'Increase scripture readability in reader view.',
                        trailing: Switch(
                          value: _largeVerseText,
                          activeColor: AppColors.primary,
                          onChanged: _saveLargeVerseText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. DATA Section
              _buildSectionHeader('Data'),
              const SizedBox(height: 4),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                      color: isDark ? AppColors.transparent : AppColors.border,
                      width: 1),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        leading: const Icon(Icons.download_rounded,
                            color: AppColors.primary),
                        title: 'Export User Data (JSON)',
                        subtitle:
                            'Notes, bookmarks, highlights, progress, streak',
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                        onTap: _exportData,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _buildSettingsTile(
                        leading: const Icon(Icons.delete_forever_rounded,
                            color: AppColors.materialRed),
                        leadingBgColor: AppColors.panicBannerBackground,
                        title: 'Reset App Data',
                        titleColor: AppColors.materialRed,
                        subtitle: 'Clear local data and settings',
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.materialRed),
                        onTap: _resetData,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom clearance spacing for floating navigation bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
