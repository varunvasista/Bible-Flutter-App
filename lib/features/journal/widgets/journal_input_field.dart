import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Multi-line text field used in the Journal entry screen.
class JournalInputField extends StatelessWidget {
  const JournalInputField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: null,
      minLines: 5,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 15, height: 1.6),
      decoration: InputDecoration(
        hintText:
            'How are you feeling today? Share what is on your heart…',
        hintStyle: const TextStyle(
          color: AppColors.grey,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.black, width: 1.5),
        ),
      ),
    );
  }
}
