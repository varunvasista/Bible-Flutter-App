import 'package:flutter/material.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Text input + submit button for the Panic screen.
///
/// [controller] — manages the typed message.
/// [onSubmit]   — called when the user taps "Seek Kyrie".
/// [isLoading]  — disables interaction while the search runs.
class PanicInputField extends StatelessWidget {
  const PanicInputField({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.isLoading,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: !isLoading,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText:
                'Describe what you\'re going through…\n'
                'e.g. "I feel anxious about my future"',
            hintStyle: const TextStyle(
              color: AppColors.grey,
              height: 1.6,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.white,
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
              borderSide:
                  const BorderSide(color: AppColors.black, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: isLoading ? null : onSubmit,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(isLoading ? 'Preparing Kyrie support…' : 'Seek Kyrie'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.disabledGrey,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
