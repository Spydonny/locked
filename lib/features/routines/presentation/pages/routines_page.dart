import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../theme/app_colors.dart';

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);

    return AppPageScaffold(
      child: routines.when(
        data: (items) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Routines',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final titleController = TextEditingController();
                      final subtitleController = TextEditingController();
                      final scheduleController = TextEditingController(text: 'Mon,Wed,Fri');

                      final shouldCreate = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('New routine'),
                          content: Column(
                            children: [
                              const SizedBox(height: 12),
                              CupertinoTextField(
                                controller: titleController,
                                placeholder: 'Title',
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: subtitleController,
                                placeholder: 'Subtitle',
                              ),
                              const SizedBox(height: 8),
                              CupertinoTextField(
                                controller: scheduleController,
                                placeholder: 'Schedule days (comma separated)',
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
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      );

                      final title = titleController.text.trim();
                      final subtitle = subtitleController.text.trim();
                      final scheduleRaw = scheduleController.text;

                      titleController.dispose();
                      subtitleController.dispose();
                      scheduleController.dispose();

                      if (shouldCreate != true) return;

                      final scheduleDays = scheduleRaw
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      await ref.read(appApiProvider).createRoutine(
                            title: title.isEmpty ? 'New routine' : title,
                            subtitle: subtitle.isEmpty ? 'Custom split' : subtitle,
                            scheduleDays: scheduleDays.isEmpty ? const ['Mon', 'Wed', 'Fri'] : scheduleDays,
                          );

                      ref.invalidate(routinesProvider);
                    },
                    child: const Icon(
                      CupertinoIcons.add_circled_solid,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Custom splits, duplicated blocks, scheduling and recurring plans.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final routine = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              routine.subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _RoutineTag('${routine.daysPerWeek} days / week'),
                                const SizedBox(width: 10),
                                const _RoutineTag('Recurring'),
                                const SizedBox(width: 10),
                                const _RoutineTag('Template'),
                              ],
                            ),
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

class _RoutineTag extends StatelessWidget {
  const _RoutineTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}
