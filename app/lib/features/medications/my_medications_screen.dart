import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/settings.dart';
import '../today/today_screen.dart';
import 'medication_setup_screen.dart';

/// More → My medications. Changing the dose, starting a new vial and pausing come with step 3.
class MyMedicationsScreen extends ConsumerWidget {
  const MyMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(medicationsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('My medications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          for (final detail in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MedicationCard(detail: detail),
            ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.add),
            label: Text(list.isEmpty ? 'Add medication' : 'Add another medication'),
            onPressed: () => startAddMedication(context),
          ),
        ],
      ),
    );
  }
}
