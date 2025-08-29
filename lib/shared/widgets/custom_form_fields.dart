import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../l10n/app_localizations.dart';

/// Custom text form field with consistent styling
class CustomTextFormField extends ConsumerWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Custom dropdown form field
class CustomDropdownFormField<T> extends ConsumerWidget {
  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? label;
  final String? hint;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
      dropdownColor: colors.white,
    );
  }
}

/// Custom date picker form field
class CustomDateFormField extends ConsumerWidget {
  const CustomDateFormField({
    super.key,
    required this.controller,
    required this.onDateSelected,
    this.label,
    this.hint,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final TextEditingController controller;
  final void Function(DateTime) onDateSelected;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: enabled,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

/// Custom checkbox list tile
class CustomCheckboxListTile extends ConsumerWidget {
  const CustomCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.enabled = true,
  });

  final bool value;
  final void Function(bool?) onChanged;
  final String title;
  final String? subtitle;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    return CheckboxListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: colors.primary,
    );
  }
}

/// Custom chip input field for tags/skills
class CustomChipInputField extends ConsumerStatefulWidget {
  const CustomChipInputField({
    super.key,
    required this.chips,
    required this.onChipsChanged,
    this.label,
    this.hint,
    this.enabled = true,
  });

  final List<String> chips;
  final void Function(List<String>) onChipsChanged;
  final String? label;
  final String? hint;
  final bool enabled;

  @override
  ConsumerState<CustomChipInputField> createState() =>
      _CustomChipInputFieldState();
}

class _CustomChipInputFieldState extends ConsumerState<CustomChipInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addChip(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && !widget.chips.contains(trimmedValue)) {
      final newChips = List<String>.from(widget.chips);
      newChips.add(trimmedValue);
      widget.onChipsChanged(newChips);
      _controller.clear();
    }
  }

  void _removeChip(String chip) {
    final newChips = List<String>.from(widget.chips);
    newChips.remove(chip);
    widget.onChipsChanged(newChips);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppConstants.spacingS),
        ],
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Column(
            children: [
              if (widget.chips.isNotEmpty) ...[
                Wrap(
                  spacing: AppConstants.spacingS,
                  runSpacing: AppConstants.spacingS,
                  children: widget.chips.map((chip) {
                    return Chip(
                      label: Text(chip),
                      onDeleted: widget.enabled
                          ? () => _removeChip(chip)
                          : null,
                      backgroundColor: colors.primary.withOpacity(0.1),
                      labelStyle: TextStyle(color: colors.primary),
                      deleteIconColor: colors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppConstants.spacingS),
              ],
              TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  hintText:
                      widget.hint ??
                      AppLocalizations.of(context)!.chipInputHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onFieldSubmitted: widget.enabled ? _addChip : null,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom slider form field
class CustomSliderFormField extends ConsumerWidget {
  const CustomSliderFormField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    this.enabled = true,
  });

  final double value;
  final void Function(double) onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: Theme.of(context).textTheme.labelLarge),
              Text(
                '${value.round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
        ],
        Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: colors.primary,
          inactiveColor: colors.grey300,
        ),
      ],
    );
  }
}
