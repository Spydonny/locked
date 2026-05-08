import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../theme/app_colors.dart';

class ExerciseLibraryPage extends ConsumerWidget {
  const ExerciseLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exerciseLibraryProvider);

    return AppPageScaffold(
      child: exercises.when(
        data: (items) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exercise Library',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const SectionTitle(
                title: 'Search & Filter',
                subtitle: 'Chest, back, legs, shoulders, arms, core and equipment categories',
              ),
              const SizedBox(height: 14),
              const CupertinoSearchTextField(
                backgroundColor: Color(0x14FFFFFF),
                style: TextStyle(color: AppColors.white),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.category}  •  ${item.equipment}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'PR ${item.personalRecord}',
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
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
