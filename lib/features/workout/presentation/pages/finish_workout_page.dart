import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';

class FinishWorkoutPage extends StatelessWidget {
  const FinishWorkoutPage({super.key});

  void _completeAndReturn(BuildContext context) {
    context.read<WorkoutCubit>().completeFlow();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Finish')),
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            final summary =
                state.summary ??
                WorkoutSummary(
                  elapsedSeconds: state.elapsedSeconds,
                  volumeKg: state.totalVolumeKg,
                  completedSets: state.completedSetCount,
                  personalRecordHighlights: state.personalRecordHighlights,
                );

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                16,
                AppSpacing.page,
                120,
              ),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workout summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: 'Time',
                              value: formatWorkoutDuration(
                                summary.elapsedSeconds,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Volume',
                              value: '${summary.volumeKg} kg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Sets',
                              value: '${summary.completedSets}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PR highlights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (summary.personalRecordHighlights.isEmpty)
                        const Text(
                          'No new PRs today, but the session still counts.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        )
                      else
                        ...summary.personalRecordHighlights.map(
                          (highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.star_fill,
                                  size: 16,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    highlight,
                                    style: const TextStyle(height: 1.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Photo + caption',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          CupertinoSwitch(
                            value: state.attachPhoto,
                            onChanged: context
                                .read<WorkoutCubit>()
                                .togglePhotoAttachment,
                          ),
                        ],
                      ),
                      if (state.attachPhoto) ...[
                        const SizedBox(height: 16),
                        Container(
                          height: 170,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.surfaceMuted,
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMedium,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(AppSpacing.card),
                          child: const Text(
                            'Optional training photo',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _CaptionField(initialValue: state.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                AppGradientButton(
                  label: 'Post Workout',
                  subtitle: 'Share it with your circle',
                  icon: CupertinoIcons.paperplane,
                  onPressed: () => _completeAndReturn(context),
                ),
                const SizedBox(height: 12),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 44,
                  onPressed: () => _completeAndReturn(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMedium,
                      ),
                      border: Border.all(color: AppColors.divider),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Workout',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionField extends StatefulWidget {
  const _CaptionField({required this.initialValue});

  final String initialValue;

  @override
  State<_CaptionField> createState() => _CaptionFieldState();
}

class _CaptionFieldState extends State<_CaptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _CaptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _controller,
      padding: const EdgeInsets.all(16),
      placeholder: 'Add a caption for your post',
      minLines: 3,
      maxLines: 5,
      onChanged: context.read<WorkoutCubit>().updateCaption,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
    );
  }
}
