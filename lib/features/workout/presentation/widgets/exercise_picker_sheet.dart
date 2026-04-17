import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/mock/mock_models.dart';
import '../cubit/workout_cubit.dart';

enum ExercisePickerFilter {
  all(null, 'All'),
  chest(ExerciseMuscleGroup.chest, 'Chest'),
  back(ExerciseMuscleGroup.back, 'Back'),
  legs(ExerciseMuscleGroup.legs, 'Legs'),
  shoulders(ExerciseMuscleGroup.shoulders, 'Shoulders'),
  arms(ExerciseMuscleGroup.arms, 'Arms'),
  core(ExerciseMuscleGroup.core, 'Core');

  const ExercisePickerFilter(this.group, this.label);

  final ExerciseMuscleGroup? group;
  final String label;
}

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  ExercisePickerFilter _selectedFilter = ExercisePickerFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseTemplate> _filteredExercises(List<ExerciseTemplate> exercises) {
    final normalizedQuery = _query.trim().toLowerCase();

    return exercises.where((exercise) {
      final matchesFilter =
          _selectedFilter.group == null ||
          exercise.muscleGroup == _selectedFilter.group;

      final matchesSearch =
          normalizedQuery.isEmpty ||
          exercise.name.toLowerCase().contains(normalizedQuery) ||
          exercise.focus.toLowerCase().contains(normalizedQuery) ||
          exercise.muscleGroup.label.toLowerCase().contains(normalizedQuery);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _selectExercise(ExerciseTemplate exercise) {
    context.read<WorkoutCubit>().addExerciseFromTemplate(exercise);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = context.select(
      (WorkoutCubit cubit) => cubit.state.exerciseLibrary,
    );
    final filtered = _filteredExercises(exercises);

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: FractionallySizedBox(
        heightFactor: 0.86,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                12,
                AppSpacing.page,
                AppSpacing.page,
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pick Exercise',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 44,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CupertinoSearchTextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    backgroundColor: AppColors.surface,
                    style: const TextStyle(color: CupertinoColors.white),
                    itemColor: AppColors.textSecondary,
                    placeholder: 'Search exercises',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ExercisePickerFilter.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = ExercisePickerFilter.values[index];
                        final isSelected = filter == _selectedFilter;

                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 36,
                          onPressed: () {
                            setState(() => _selectedFilter = filter);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surfaceMuted
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.gradientStart
                                    : AppColors.divider,
                              ),
                            ),
                            child: Text(
                              filter.label,
                              style: TextStyle(
                                color: isSelected
                                    ? CupertinoColors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No exercises match your search.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final exercise = filtered[index];

                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 56,
                                onPressed: () => _selectExercise(exercise),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMedium,
                                    ),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: exercise.thumbnailColor,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusSmall,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          exercise.thumbnailIcon,
                                          color: CupertinoColors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exercise.name,
                                              style: const TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: CupertinoColors.white
                                                    .withOpacity(0.06),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                exercise.muscleGroup.label,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        CupertinoIcons.add,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
