import 'package:dately/app/constants/app_constants.dart';
import 'package:dately/app/theme/app_colors.dart';
import 'package:dately/features/discovery/providers/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdvancedFiltersScreen extends ConsumerStatefulWidget {
  const AdvancedFiltersScreen({super.key});

  @override
  ConsumerState<AdvancedFiltersScreen> createState() =>
      _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends ConsumerState<AdvancedFiltersScreen> {
  late RangeValues _ageRange;
  late List<String> _selectedMotherTongues;
  late String _gender;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(filterProvider);
    _ageRange = filters.ageRange;
    _selectedMotherTongues = List.from(filters.motherTongues);
    _gender = filters.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      // ... decoration ...
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // ... Header (Same) ...
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
                const Text(
                  'Advanced Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(filterProvider.notifier).reset();
                    setState(() {
                      final filters = ref.read(filterProvider);
                      _ageRange = filters.ageRange;
                      _selectedMotherTongues = List.from(filters.motherTongues);
                      _gender = filters.gender;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.1)),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Discovery Settings
                    _buildSectionContainer(
                      title: 'Discovery Settings',
                      child: Column(
                        children: [
                          _buildRangeSlider(
                            label: 'Age Range',
                            valueLabel:
                                '${_ageRange.start.round()} - ${_ageRange.end.round()}',
                            child: RangeSlider(
                              values: _ageRange,
                              min: 18,
                              max: 99,
                              activeColor: AppColors.primary,
                              inactiveColor: Colors.grey.withOpacity(0.2),
                              onChanged: (values) =>
                                  setState(() => _ageRange = values),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mother Tongue Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mother Tongue',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: AppConstants.languages.map((
                                  language,
                                ) {
                                  final isSelected = _selectedMotherTongues
                                      .contains(language);
                                  return FilterChip(
                                    label: Text(language),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedMotherTongues.add(language);
                                        } else {
                                          _selectedMotherTongues.remove(
                                            language,
                                          );
                                        }
                                      });
                                    },
                                    backgroundColor: Colors.transparent,
                                    selectedColor: AppColors.primary
                                        .withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    showCheckmark: false,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Gender Preference
                    _buildSectionContainer(
                      title: 'I\'m interested in',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: ['Men', 'Women', 'Everyone'].map((gender) {
                            final isSelected = _gender == gender;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _gender = gender),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.primary
                                              : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    gender,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color:
                                          isSelected &&
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                          ? Colors.white
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(filterProvider.notifier)
                    ..setAgeRange(_ageRange)
                    ..setMotherTongues(_selectedMotherTongues)
                    ..setGender(_gender);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildRangeSlider({
    required String label,
    required String valueLabel,
    required Widget child,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              valueLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
