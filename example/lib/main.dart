import 'package:apex_dropdown/apex_dropdown.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Dropdown Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const ApexDropdownExamplePage(),
    );
  }
}

class Benefit {
  Benefit({required this.id, required this.title});

  final int id;
  final String title;

  @override
  String toString() => title;

  bool filter(String query) =>
      title.toLowerCase().contains(query.trim().toLowerCase());
}

class ApexDropdownExamplePage extends StatefulWidget {
  const ApexDropdownExamplePage({super.key});

  @override
  State<ApexDropdownExamplePage> createState() => _ApexDropdownExamplePageState();
}

class _ApexDropdownExamplePageState extends State<ApexDropdownExamplePage> {
  final _formKey = GlobalKey<FormState>();

  String? _country;
  Benefit? _selectedBenefit;
  List<String> _tags = const ['Dart'];
  List<Benefit> _benefits = const [];
  Benefit? _asyncBenefit;
  List<Benefit> _asyncBenefits = const [];

  final _countries = const ['UAE', 'Saudi Arabia', 'Qatar', 'Kuwait', 'Bahrain'];
  final _allTags = const ['Dart', 'Flutter', 'Android', 'iOS', 'Web'];
  final _allBenefits = <Benefit>[
    Benefit(id: 1, title: 'Accommodation'),
    Benefit(id: 2, title: 'Flight'),
    Benefit(id: 3, title: 'Visa'),
    Benefit(id: 4, title: 'Medical'),
    Benefit(id: 5, title: 'Overtime'),
  ];

  Future<List<Benefit>> _queryBenefits(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _allBenefits
        : _allBenefits.where((b) => b.title.toLowerCase().contains(q)).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apex Dropdown Examples')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: 'Single-select (String) + search',
                child: ApexDropdown<String>(
                  items: _countries,
                  value: _country,
                  itemLabel: (s) => s,
                  hintText: 'Country',
                  searchEnabled: true,
                  onChanged: (v) => setState(() => _country = v),
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Single-select (model) + compareFn',
                subtitle: 'Uses Benefit.toString() for display.',
                child: ApexDropdown<Benefit>(
                  items: _allBenefits,
                  value: _selectedBenefit,
                  itemLabel: (b) => b.title,
                  compareFn: (a, b) => a.id == b.id,
                  hintText: 'Benefit',
                  searchEnabled: true,
                  onChanged: (v) => setState(() => _selectedBenefit = v),
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Multi-select (String) + chips',
                child: ApexMultiDropdown<String>(
                  items: _allTags,
                  values: _tags,
                  itemLabel: (s) => s,
                  hintText: 'Tags',
                  chipDisplay: ApexDropdownChipDisplay.chips,
                  maxSelection: 4,
                  searchEnabled: true,
                  onChanged: (v) => setState(() => _tags = v),
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Multi-select (model) + filter(query)',
                subtitle:
                    'Search uses Benefit.filter(query) automatically when present.',
                child: ApexMultiDropdown<Benefit>(
                  items: _allBenefits,
                  values: _benefits,
                  itemLabel: (b) => b.title,
                  compareFn: (a, b) => a.id == b.id,
                  hintText: 'Benefits',
                  chipDisplay: ApexDropdownChipDisplay.count,
                  searchEnabled: true,
                  onChanged: (v) => setState(() => _benefits = v),
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Async single-select (model)',
                subtitle: 'Loads results from a Future-backed query function.',
                child: ApexAsyncDropdown<Benefit>(
                  queryFn: _queryBenefits,
                  value: _asyncBenefit,
                  itemLabel: (b) => b.title,
                  compareFn: (a, b) => a.id == b.id,
                  hintText: 'Search benefit',
                  minQueryLength: 0,
                  initialItems: _allBenefits,
                  onChanged: (v) => setState(() => _asyncBenefit = v),
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'Async multi-select (model) + chips',
                child: ApexAsyncMultiDropdown<Benefit>(
                  queryFn: _queryBenefits,
                  values: _asyncBenefits,
                  itemLabel: (b) => b.title,
                  compareFn: (a, b) => a.id == b.id,
                  hintText: 'Search benefits',
                  chipDisplay: ApexDropdownChipDisplay.chips,
                  initialItems: _allBenefits,
                  onChanged: (v) => setState(() => _asyncBenefits = v),
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: 'FormField examples',
                child: Column(
                  children: [
                    ApexDropdownFormField<String>(
                      items: _countries,
                      value: _country,
                      itemLabel: (s) => s,
                      hintText: 'Country (required)',
                      validator: (v) =>
                          v == null ? 'Please select a country' : null,
                      onChanged: (v) => setState(() => _country = v),
                    ),
                    const SizedBox(height: 12),
                    ApexMultiDropdownFormField<String>(
                      items: _allTags,
                      values: _tags,
                      itemLabel: (s) => s,
                      hintText: 'Tags (pick at least 1)',
                      chipDisplay: ApexDropdownChipDisplay.count,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Pick at least one tag'
                          : null,
                      onChanged: (v) => setState(() => _tags = v),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final ok =
                              _formKey.currentState?.validate() ?? false;
                          if (!ok) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Form valid')),
                          );
                        },
                        child: const Text('Validate form'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
              ),
            ],
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
