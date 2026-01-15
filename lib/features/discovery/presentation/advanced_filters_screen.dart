import 'package:dately/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdvancedFiltersScreen extends StatefulWidget {
  const AdvancedFiltersScreen({super.key});

  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen> {
  RangeValues _ageRange = const RangeValues(18, 35);
  double _distance = 50;
  String _gender = 'Everyone';
  bool _drink = true;
  bool _smoke = false;
  bool _verifiedOnly = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                const Text(
                  'Advanced Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Reset logic
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
          Divider(color: Colors.grey.withValues(alpha: 0.1)),

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
                              inactiveColor: Colors.grey.withValues(alpha: 0.2),
                              onChanged: (values) =>
                                  setState(() => _ageRange = values),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSlider(
                            label: 'Distance Radius',
                            valueLabel: '${_distance.round()} miles',
                            child: Slider(
                              value: _distance,
                              min: 1,
                              max: 100,
                              activeColor: AppColors.primary,
                              inactiveColor: Colors.grey.withValues(alpha: 0.2),
                              onChanged: (value) =>
                                  setState(() => _distance = value),
                            ),
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
                          color: Colors.grey.withValues(alpha: 0.1),
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
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
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

                    const SizedBox(height: 16),

                    // Lifestyle
                    _buildSectionContainer(
                      title: 'Lifestyle',
                      child: Column(
                        children: [
                          _buildToggleRow(
                            'Drinking',
                            Icons.local_bar,
                            _drink,
                            (v) => setState(() => _drink = v),
                          ),
                          const SizedBox(height: 16),
                          _buildToggleRow(
                            'Smoking',
                            Icons.smoking_rooms,
                            _smoke,
                            (v) => setState(() => _smoke = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Education & Religion (Mock Dropdowns)
                    _buildSectionContainer(
                      title: null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropdown('EDUCATION', 'Bachelors Degree'),
                          const SizedBox(height: 16),
                          _buildDropdown('RELIGION', 'Spiritual'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Premium Filter
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Verified Profiles Only',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'PRO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Only see users who have verified their identity',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _verifiedOnly,
                            onChanged: (v) => setState(() => _verifiedOnly = v),
                            activeColor: AppColors.gold,
                          ),
                        ],
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
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
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

  Widget _buildSlider({
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

  Widget _buildToggleRow(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Icon(Icons.expand_more, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
