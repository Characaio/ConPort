import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/mission.dart';
import 'package:conport/widgets/topbar.dart';

class Missions extends StatelessWidget {
  const Missions({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final missions = Mission.mock;
    final activeMissions = missions
        .where((mission) => mission.status == MissionStatus.inProgress)
        .toList();
    final availableMissions = missions
        .where((mission) => mission.status == MissionStatus.available)
        .toList();

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Topbar(hasLogo: false, hasReturn: true, text: 'Missões'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MissionSummary(
                        activeCount: activeMissions.length,
                        onRewards: () {
                          PageLoader.go(context, PageLoader.rewards);
                        },
                      ),
                      const SizedBox(height: 24),
                      if (activeMissions.isNotEmpty) ...[
                        const _SectionTitle(
                          icon: Symbols.autorenew,
                          title: 'Em andamento',
                        ),
                        const SizedBox(height: 10),
                        for (final mission in activeMissions) ...[
                          _MissionCard(mission: mission),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (availableMissions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const _SectionTitle(
                          icon: Symbols.flag,
                          title: 'Disponíveis',
                        ),
                        const SizedBox(height: 10),
                        for (final mission in availableMissions) ...[
                          _MissionCard(mission: mission),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 8),
                      _RewardsShortcut(
                        onTap: () {
                          PageLoader.go(context, PageLoader.rewards);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionSummary extends StatelessWidget {
  final int activeCount;
  final VoidCallback onRewards;

  const _MissionSummary({required this.activeCount, required this.onRewards});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
      decoration: BoxDecoration(
        color: appColors.accentGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faça a diferença',
                  style: TextStyle(
                    color: appColors.onAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Complete missões e ajude a cuidar do meio ambiente.',
                  style: TextStyle(
                    color: appColors.onAccent.withValues(alpha: 0.7),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Symbols.flag, color: appColors.onAccent, size: 17),
                  const SizedBox(width: 4),
                  Text(
                    '$activeCount ativas',
                    style: TextStyle(
                      color: appColors.onAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 31,
                child: OutlinedButton.icon(
                  onPressed: onRewards,
                  icon: Icon(Symbols.redeem, size: 15),
                  label: const Text(
                    'Recompensas',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appColors.onAccent,
                    side: BorderSide(
                      color: appColors.onAccent.withValues(alpha: 0.7),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Mission mission;

  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final isAvailable = mission.status == MissionStatus.available;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAvailable
            ? colors.primaryContainer
            : appColors.mutedBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.16),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MissionIcon(type: mission.type),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: mission.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
              Text(
                '${mission.progress}/${mission.goal}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mission.progressPercentage,
              minHeight: 7,
              backgroundColor: appColors.onAccent.withValues(alpha: 0.7),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RewardPill(
                icon: Symbols.toll,
                text: '${mission.coinReward} moedas',
              ),
              const SizedBox(width: 7),
              _RewardPill(icon: Symbols.stars, text: '${mission.xpReward} XP'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  PageLoader.go(context, PageLoader.rewards);
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver recompensas',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionIcon extends StatelessWidget {
  final String type;

  const _MissionIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = switch (type.toUpperCase()) {
      'PLANTAR' => Symbols.park,
      'RECICLAR' => Symbols.recycling,
      'REUTILIZAR' => Symbols.rebase_edit,
      _ => Symbols.flag,
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 24),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MissionStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final label = switch (status) {
      MissionStatus.inProgress => 'Em andamento',
      MissionStatus.available => 'Disponível',
      MissionStatus.completed => 'Concluída',
      MissionStatus.expired => 'Expirada',
      MissionStatus.unknown => 'Status desconhecido',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: appColors.cardBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RewardPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: appColors.cardBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}

class _RewardsShortcut extends StatelessWidget {
  final VoidCallback onTap;

  const _RewardsShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: appColors.accentBrown,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Symbols.redeem, color: appColors.onAccent, size: 21),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Veja como usar suas recompensas',
                style: TextStyle(
                  color: appColors.onAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Symbols.chevron_right, color: appColors.onAccent, size: 21),
          ],
        ),
      ),
    );
  }
}
