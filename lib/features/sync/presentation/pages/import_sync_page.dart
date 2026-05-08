import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../theme/app_colors.dart';

class ImportSyncPage extends ConsumerWidget {
  const ImportSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imports = ref.watch(syncImportsProvider);

    return AppPageScaffold(
      child: imports.when(
        data: (items) {
          return ListView(
            children: [
              const Text(
                'Import & Sync',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Apple Health sync, Hevy / Strong CSV migration and realtime conflict-aware sync pipeline.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 22),
              ...items.map((job) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x14FFFFFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                job.status,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
