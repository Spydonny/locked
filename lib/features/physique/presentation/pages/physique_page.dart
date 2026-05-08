import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/metric_tile.dart';
import '../../../../shared/widgets/monochrome_chart.dart';
import '../../../../theme/app_colors.dart';

class PhysiquePage extends ConsumerWidget {
  const PhysiquePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final physique = ref.watch(physiqueProvider);

    return AppPageScaffold(
      child: physique.when(
        data: (data) {
          return ListView(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Physique',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final weightController = TextEditingController(text: data.currentWeight == 0 ? '' : '${data.currentWeight}');
                      final bodyFatController = TextEditingController(text: data.bodyFat == 0 ? '' : '${data.bodyFat}');
                      final chestController = TextEditingController(text: data.chest == 0 ? '' : '${data.chest}');
                      final waistController = TextEditingController(text: data.waist == 0 ? '' : '${data.waist}');

                      final shouldCreate = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Log body metric'),
                          content: Column(
                            children: [
                              const SizedBox(height: 12),
                              CupertinoTextField(
                                controller: weightController,
                                placeholder: 'Weight (kg)',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: bodyFatController,
                                placeholder: 'Body fat (%)',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: chestController,
                                placeholder: 'Chest (cm)',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: waistController,
                                placeholder: 'Waist (cm)',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );

                      final weight = double.tryParse(weightController.text.trim());
                      final bodyFat = double.tryParse(bodyFatController.text.trim());
                      final chest = double.tryParse(chestController.text.trim());
                      final waist = double.tryParse(waistController.text.trim());

                      weightController.dispose();
                      bodyFatController.dispose();
                      chestController.dispose();
                      waistController.dispose();

                      if (shouldCreate != true || weight == null || weight <= 0) return;

                      await ref.read(appApiProvider).createBodyMetric(
                            weight: weight,
                            bodyFat: bodyFat,
                            chest: chest,
                            waist: waist,
                          );
                      ref.invalidate(physiqueProvider);
                      ref.invalidate(dashboardProvider);
                    },
                    child: const Icon(
                      CupertinoIcons.add_circled_solid,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Bodyweight, measurements, body-fat trend and progress-photo timeline ready.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Weight',
                      value: '${data.currentWeight} kg',
                      delta: 'Current',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      label: 'Body Fat',
                      value: '${data.bodyFat}%',
                      delta: 'Estimated',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Chest',
                      value: '${data.chest} cm',
                      delta: 'Relaxed',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      label: 'Waist',
                      value: '${data.waist} cm',
                      delta: 'Morning',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              MonochromeChart(
                title: 'Bodyweight Trend',
                subtitle: 'Last five months',
                points: data.trend,
              ),
            ],
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
