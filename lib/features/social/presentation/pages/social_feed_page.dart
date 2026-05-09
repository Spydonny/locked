import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../theme/app_colors.dart';

class SocialFeedPage extends ConsumerStatefulWidget {
  const SocialFeedPage({super.key});

  @override
  ConsumerState<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends ConsumerState<SocialFeedPage> {
  SocialFeedScope _scope = SocialFeedScope.all;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(socialFeedProvider(_scope));
    final currentUser = ref.watch(authControllerProvider).snapshot.user;

    return AppPageScaffold(
      child: feed.when(
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(socialFeedProvider(_scope));
              await ref.read(socialFeedProvider(_scope).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Text(
                  'Community',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08),
                const SizedBox(height: 10),
                Text(
                  data.followingCount == 0
                      ? 'Share finished workouts with a progress photo, then build your friends feed.'
                      : 'Switch between everyone and the athletes you follow.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ).animate(delay: 80.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
                _FeedScopePicker(
                  scope: _scope,
                  onChanged: (value) {
                    if (value == null || value == _scope) {
                      return;
                    }
                    setState(() {
                      _scope = value;
                    });
                  },
                ),
                const SizedBox(height: 22),
                SectionTitle(
                  title: _scope == SocialFeedScope.all
                      ? 'All Posts'
                      : 'Friends Feed',
                  subtitle: _scope == SocialFeedScope.all
                      ? 'Fresh workout posts from the whole app.'
                      : 'Only the people you follow show up here.',
                ),
                const SizedBox(height: 14),
                if (data.items.isEmpty)
                  _EmptyFeedState(scope: _scope)
                else
                  ...data.items.asMap().entries.map((entry) {
                    final post = entry.value;
                    final isOwnPost = currentUser?.id == post.author.id;
                    return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _SocialPostCard(
                            post: post,
                            apiBaseUrl: ref.watch(apiBaseUrlProvider),
                            authHeader: ref
                                .watch(authControllerProvider)
                                .snapshot
                                .tokens
                                ?.accessToken,
                            isOwnPost: isOwnPost,
                            busy: _busy,
                            onToggleFollow: isOwnPost
                                ? null
                                : () => _toggleFollow(post.author),
                          ),
                        )
                        .animate(delay: (100 + (entry.key * 45)).ms)
                        .fadeIn(duration: 350.ms);
                  }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  Future<void> _toggleFollow(SocialAuthor author) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final api = ref.read(appApiProvider);
      if (author.isFollowing) {
        await api.unfollowUser(author.id);
      } else {
        await api.followUser(author.id);
      }
      ref.invalidate(socialFeedProvider(SocialFeedScope.all));
      ref.invalidate(socialFeedProvider(SocialFeedScope.following));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }
}

class _FeedScopePicker extends StatelessWidget {
  const _FeedScopePicker({required this.scope, required this.onChanged});

  final SocialFeedScope scope;
  final ValueChanged<SocialFeedScope?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CupertinoSlidingSegmentedControl<SocialFeedScope>(
          groupValue: scope,
          backgroundColor: Colors.transparent,
          thumbColor: colorScheme.surface,
          onValueChanged: onChanged,
          children: const {
            SocialFeedScope.all: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text('All'),
            ),
            SocialFeedScope.following: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text('Friends'),
            ),
          },
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState({required this.scope});

  final SocialFeedScope scope;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            scope == SocialFeedScope.all
                ? CupertinoIcons.person_2_fill
                : CupertinoIcons.heart_circle,
            size: 38,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 14),
          Text(
            scope == SocialFeedScope.all
                ? 'No posts yet'
                : 'No friend posts yet',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            scope == SocialFeedScope.all
                ? 'Finish a workout, attach a photo, and share it to start the feed.'
                : 'Follow a few athletes and their completed workout posts will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialPostCard extends StatelessWidget {
  const _SocialPostCard({
    required this.post,
    required this.apiBaseUrl,
    required this.authHeader,
    required this.isOwnPost,
    required this.busy,
    required this.onToggleFollow,
  });

  final SocialPost post;
  final String apiBaseUrl;
  final String? authHeader;
  final bool isOwnPost;
  final bool busy;
  final Future<void> Function()? onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrl = post.photo == null
        ? null
        : Uri.parse(apiBaseUrl).resolve(post.photo!.downloadUrl).toString();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.16),
                      colorScheme.primary.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(post.author.displayName),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPostTime(post.createdAt),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isOwnPost)
                CupertinoButton(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  color: post.author.isFollowing
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: busy ? null : onToggleFollow,
                  child: Text(
                    post.author.isFollowing ? 'Following' : 'Follow',
                    style: TextStyle(
                      color: post.author.isFollowing
                          ? colorScheme.onSurface
                          : colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          if (post.caption != null && post.caption!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              post.caption!,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
          ],
          if (photoUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 1.14,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  headers: authHeader == null
                      ? null
                      : {'Authorization': 'Bearer $authHeader'},
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Text(
                        'Photo unavailable',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          if (post.workout != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.flame_fill,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.workout!.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDuration(post.workout!.durationSeconds)} ? Completed session',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'U';
  }
  final first = parts.first.substring(0, 1).toUpperCase();
  final second = parts.length > 1 ? parts[1].substring(0, 1).toUpperCase() : '';
  return '$first$second';
}

String _formatPostTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month/$day at $hour:$minute';
}

String _formatDuration(int totalSeconds) {
  final safeTotal = totalSeconds < 0 ? 0 : totalSeconds;
  final hours = safeTotal ~/ 3600;
  final minutes = (safeTotal % 3600) ~/ 60;
  final seconds = safeTotal % 60;

  String two(int value) => value.toString().padLeft(2, '0');

  return '${two(hours)}:${two(minutes)}:${two(seconds)}';
}
