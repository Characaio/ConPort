import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/widgets/topbar.dart';

class Rewards extends StatelessWidget {
  const Rewards({super.key});

  static const _rewards = [
    _MockReward(
      title: 'Muda nativa',
      description: 'Resgate uma muda para plantar na sua região.',
      cost: 80,
      icon: Symbols.park,
      available: true,
    ),
    _MockReward(
      title: 'Caneca reutilizável',
      description:
          'Uma lembrança para levar seus hábitos sustentáveis adiante.',
      cost: 120,
      icon: Symbols.local_cafe,
      available: true,
    ),
    _MockReward(
      title: 'Kit de sementes',
      description: 'Sementes selecionadas para começar seu próprio cultivo.',
      cost: 180,
      icon: Symbols.eco,
      available: false,
    ),
    _MockReward(
      title: 'Guardião da natureza',
      description: 'Conquista especial para quem completa 10 missões.',
      cost: 0,
      icon: Symbols.workspace_premium,
      available: true,
      isAchievement: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final redeemable = _rewards
        .where((reward) => !reward.isAchievement)
        .toList();
    final achievements = _rewards
        .where((reward) => reward.isAchievement)
        .toList();

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Topbar(hasLogo: false, hasReturn: true, text: 'Recompensas'),
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
                      const _BalanceCard(),
                      const SizedBox(height: 24),
                      const _SectionTitle(
                        icon: Symbols.redeem,
                        title: 'Troque suas moedas',
                      ),
                      const SizedBox(height: 10),
                      for (final reward in redeemable) ...[
                        _RewardCard(reward: reward),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      const _SectionTitle(
                        icon: Symbols.workspace_premium,
                        title: 'Conquistas',
                      ),
                      const SizedBox(height: 10),
                      for (final reward in achievements) ...[
                        _RewardCard(reward: reward),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            PageLoader.go(context, PageLoader.missions);
                          },
                          icon: Icon(Symbols.flag, size: 16),
                          label: Text(
                            'Voltar para missões',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu saldo',
            style: TextStyle(color: appColors.onAccent.withValues(alpha: 0.7), fontSize: 11),
          ),
          SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Symbols.toll, color: appColors.onAccent, size: 28),
              SizedBox(width: 7),
              Text(
                '150',
                style: TextStyle(
                  color: appColors.onAccent,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 7),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'moedas',
                  style: TextStyle(color: appColors.onAccent, fontSize: 11),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Icon(Symbols.stars, color: appColors.onAccent, size: 17),
              SizedBox(width: 5),
              Text(
                '670 XP acumulados',
                style: TextStyle(color: appColors.onAccent, fontSize: 11),
              ),
              Spacer(),
              Text(
                'Nível 12',
                style: TextStyle(
                  color: appColors.onAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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

class _RewardCard extends StatelessWidget {
  final _MockReward reward;

  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final isLocked = !reward.available;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: reward.isAchievement
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: reward.isAchievement
                  ? appColors.statusDenied
                  : colors.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reward.icon,
              size: 27,
              color: reward.isAchievement ? appColors.onAccent : colors.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reward.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (reward.isAchievement)
            Text(
              'Desbloqueada',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.toll, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${reward.cost}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 27,
                  child: ElevatedButton(
                    onPressed: isLocked
                        ? null
                        : () => _showMockMessage(context, reward.title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: appColors.onAccent,
                      disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
                      disabledForegroundColor: colors.onSurface.withValues(alpha: 0.45),
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isLocked ? 'Em breve' : 'Resgatar',
                      style: TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showMockMessage(BuildContext context, String rewardTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$rewardTitle selecionada (demonstração).'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _MockReward {
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final bool available;
  final bool isAchievement;

  const _MockReward({
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.available,
    this.isAchievement = false,
  });
}
