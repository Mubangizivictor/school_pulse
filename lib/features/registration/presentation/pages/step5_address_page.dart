import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/registration_reference_data.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class Step5AddressPage extends StatefulWidget {
  const Step5AddressPage({super.key});

  @override
  State<Step5AddressPage> createState() => _Step5AddressPageState();
}

class _Step5AddressPageState extends State<Step5AddressPage> {
  late TextEditingController _districtSearch;
  late TextEditingController _address;
  late TextEditingController _subdomain;
  bool _districtMenuOpen = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<RegistrationBloc>().state;
    _districtSearch = TextEditingController(text: s.district);
    _address = TextEditingController(text: s.address);
    _subdomain = TextEditingController(text: s.subdomain);
  }

  @override
  void dispose() {
    _districtSearch.dispose();
    _address.dispose();
    _subdomain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final allDistricts = kDistrictsByRegion.values.expand((d) => d).toList()..sort();
        final query = _districtSearch.text.trim().toLowerCase();
        final matches = query.isEmpty
            ? allDistricts
            : allDistricts.where((d) => d.toLowerCase().contains(query)).toList();

        final canContinue = state.district.isNotEmpty &&
            state.address.trim().isNotEmpty &&
            state.subdomain.length >= 3 &&
            state.slugAvailable == true;

        return RegStepScaffold(
          step: 5,
          title: 'Address & subdomain',
          onBack: () => context.read<RegistrationBloc>().add(const RegistrationStepBack()),
          continueEnabled: canContinue,
          onContinue: () => context.read<RegistrationBloc>().add(const AddressStepSubmitted()),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RegFieldLabel('District'),
              TextField(
                controller: _districtSearch,
                style: const TextStyle(color: RegColors.textPrimary),
                onTap: () => setState(() => _districtMenuOpen = true),
                onChanged: (v) => setState(() => _districtMenuOpen = true),
                decoration: InputDecoration(
                  hintText: 'Search district',
                  prefixIcon: const Icon(Icons.search, color: RegColors.textMuted, size: 19),
                  suffixIcon: _districtSearch.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 17, color: RegColors.textMuted),
                          onPressed: () => setState(() {
                            _districtSearch.clear();
                            _districtMenuOpen = false;
                          }),
                        )
                      : null,
                ),
              ),
              if (_districtMenuOpen && matches.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: RegColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RegColors.border),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: matches.length,
                    itemBuilder: (context, i) {
                      final d = matches[i];
                      final region = kDistrictsByRegion.entries.firstWhere((e) => e.value.contains(d)).key;
                      return ListTile(
                        dense: true,
                        title: Text(d, style: const TextStyle(color: RegColors.textPrimary, fontSize: 13.5)),
                        onTap: () {
                          context.read<RegistrationBloc>().add(RegionSelected(region));
                          context.read<RegistrationBloc>().add(DistrictSelected(d));
                          setState(() {
                            _districtSearch.text = d;
                            _districtMenuOpen = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              const RegFieldLabel('School address'),
              TextField(
                controller: _address,
                maxLines: 2,
                style: const TextStyle(color: RegColors.textPrimary),
                onChanged: (v) => context.read<RegistrationBloc>().add(AddressChanged(v)),
                decoration: const InputDecoration(hintText: 'Plot 12, Old Port Bell Road, Kawempe Division, Kampala'),
              ),
              const RegFieldLabel('Your School Pulse URL'),
              TextField(
                controller: _subdomain,
                style: const TextStyle(color: RegColors.textPrimary),
                onChanged: (v) => context.read<RegistrationBloc>().add(SubdomainChanged(v)),
                decoration: InputDecoration(
                  hintText: 'kawempe-primary',
                  suffixIcon: state.checkingSlug
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : (state.slugAvailable == true
                          ? const Icon(Icons.check_circle, color: RegColors.green, size: 19)
                          : (state.slugAvailable == false ? const Icon(Icons.cancel, color: RegColors.red, size: 19) : null)),
                ),
              ),
              const SizedBox(height: 4),
              if (state.subdomain.isNotEmpty)
                Text(
                  '${state.subdomain}.schoolpulseapp.com',
                  style: const TextStyle(fontSize: 12, color: RegColors.textMuted),
                ),
              if (state.slugMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.slugMessage!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: state.slugAvailable == true ? RegColors.green : RegColors.red,
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('This will be your unique school portal URL.', style: TextStyle(fontSize: 11, color: RegColors.textMuted)),
              ),
            ],
          ),
        );
      },
    );
  }
}
