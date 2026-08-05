import 'package:flutter/material.dart';

class CreatePlanWizard extends StatefulWidget {
  const CreatePlanWizard({super.key});

  @override
  State<CreatePlanWizard> createState() => _CreatePlanWizardState();
}

class _CreatePlanWizardState extends State<CreatePlanWizard> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStepIndicator(),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildInformationStep(),
                  _buildPricingStep(),
                  _buildFeaturesStep(),
                  _buildLimitsStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Create New Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF6366F1)
                        : (isCompleted
                              ? const Color(0xFF22C55E)
                              : Colors.transparent),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isCurrent || isCompleted)
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: (isCurrent || isCompleted)
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted
                          ? const Color(0xFF22C55E)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInformationStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Plan Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField('Plan Name *', 'e.g. Premium Plan'),
        const SizedBox(height: 20),
        _buildTextField(
          'Plan Code *',
          'e.g. premium_plan',
          helper: 'Used for system reference',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Description',
          'Describe this plan and who it\'s for...',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        const Text(
          'Plan Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdown('Select status', ['Active', 'Draft', 'Archived']),
        const SizedBox(height: 24),
        const Text(
          'Billing Cycle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSelectableChip('Monthly', true)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectableChip('Yearly', false, suffix: 'Save 17%'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Pricing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set the price for this plan',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Monthly Price (UGX) *',
          '250,000',
          helper: 'Enter 0 for free plan',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Yearly Price (UGX)',
          '2,500,000',
          suffix: 'Save 17%',
          helper: 'Leave empty to auto-calculate (save 17%)',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Setup Fee (UGX)',
          '0',
          helper: 'One-time setup fee',
          optional: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Trial Period',
          '14',
          suffix: 'days',
          helper: 'Trial period for new schools',
        ),
        const SizedBox(height: 24),
        _buildSwitchRow(
          'Allow Custom Price',
          'Allow schools to request custom pricing',
          true,
        ),
      ],
    );
  }

  Widget _buildFeaturesStep() {
    return const Center(
      child: Text('Features selection', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLimitsStep() {
    return const Center(
      child: Text(
        'Limits configuration',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildReviewStep() {
    return const Center(
      child: Text('Review and create', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    int maxLines = 1,
    String? helper,
    String? suffix,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (optional)
              Text(
                ' (Optional)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            suffix,
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown(String hint, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
          dropdownColor: const Color(0xFF0F172A),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildSelectableChip(String label, bool isSelected, {String? suffix}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6366F1).withValues(alpha: 0.1)
            : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected)
            const Icon(Icons.check_circle, color: Color(0xFF6366F1), size: 16),
          if (isSelected) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            Text(
              suffix,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (v) {},
          activeColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: Color(0xFF6366F1), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _totalSteps - 1) {
                  setState(() => _currentStep++);
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep == _totalSteps - 1
                        ? 'Create Plan'
                        : 'Next: ${_getNextStepName()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextStepName() {
    switch (_currentStep) {
      case 0:
        return 'Pricing';
      case 1:
        return 'Features';
      case 2:
        return 'Limits';
      case 3:
        return 'Review';
      default:
        return '';
    }
  }
}
