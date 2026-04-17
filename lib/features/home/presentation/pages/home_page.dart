import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/avatar_row.dart';
import '../widgets/streak_card.dart';
import '../widgets/workout_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: [
              const CupertinoSliverNavigationBar(largeTitle: Text('Home')),
              SliverSafeArea(
                top: false,
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      FadeSlideIn(
                        child: StreakCard(streak: state.dashboard.streak),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 40),
                        child: AppSectionHeader(
                          title: 'Crew',
                          subtitle: 'Who is training with you today',
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 90),
                        child: AvatarRow(avatars: state.dashboard.crew),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 120),
                        child: AppSectionHeader(
                          title: 'Feed',
                          subtitle: 'Fresh sessions from the people you follow',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.dashboard.feed.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FadeSlideIn(
                            delay: Duration(milliseconds: 140 + (entry.key * 40)),
                            child: WorkoutCard(workout: entry.value),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
