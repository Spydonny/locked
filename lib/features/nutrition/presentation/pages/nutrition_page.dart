import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/metric_tile.dart';
import '../../../../theme/app_colors.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(nutritionProvider);

    return AppPageScaffold(
      child: nutrition.when(
        data: (data) {
          return ListView(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nutrition',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final mealTypeController = TextEditingController(text: 'Dinner');
                      final titleController = TextEditingController();
                      final caloriesController = TextEditingController(text: '600');
                      final proteinController = TextEditingController(text: '40');
                      final carbsController = TextEditingController(text: '60');
                      final fatController = TextEditingController(text: '20');

                      final shouldCreate = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Log meal'),
                          content: Column(
                            children: [
                              const SizedBox(height: 12),
                              CupertinoTextField(
                                controller: mealTypeController,
                                placeholder: 'Meal type (e.g. Lunch)',
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: titleController,
                                placeholder: 'Title (e.g. Chicken bowl)',
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: caloriesController,
                                placeholder: 'Calories',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: proteinController,
                                placeholder: 'Protein (g)',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: carbsController,
                                placeholder: 'Carbs (g)',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: fatController,
                                placeholder: 'Fat (g)',
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

                      final mealType = mealTypeController.text.trim();
                      final title = titleController.text.trim();
                      final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
                      final protein = int.tryParse(proteinController.text.trim()) ?? 0;
                      final carbs = int.tryParse(carbsController.text.trim()) ?? 0;
                      final fat = int.tryParse(fatController.text.trim()) ?? 0;

                      mealTypeController.dispose();
                      titleController.dispose();
                      caloriesController.dispose();
                      proteinController.dispose();
                      carbsController.dispose();
                      fatController.dispose();

                      if (shouldCreate != true) return;

                      await ref.read(appApiProvider).createNutritionEntry(
                            mealType: mealType.isEmpty ? 'Meal' : mealType,
                            title: title.isEmpty ? 'Untitled' : title,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                          );
                      ref.invalidate(nutritionProvider);
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
                'Calories, macros, hydration and meal logging with barcode and database-ready architecture.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 22),
              MetricTile(
                label: 'Calories',
                value: '${data.calories}',
                delta: 'Target 2,450 kcal',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Protein',
                      value: '${data.protein}g',
                      delta: 'On target',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      label: 'Carbs',
                      value: '${data.carbs}g',
                      delta: 'Pre-workout heavy',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Fat',
                      value: '${data.fat}g',
                      delta: 'Stable',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      label: 'Hydration',
                      value: '${data.hydrationLiters}L',
                      delta: 'Today',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...data.meals.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    meal.subtitle,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_right),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
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
