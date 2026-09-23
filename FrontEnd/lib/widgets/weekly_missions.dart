import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/models/mission.dart';
import 'package:conport/services/missaoService.dart';

class WeeklyMissions extends StatefulWidget {
  final int userLevel;
  final VoidCallback onRewardsTap;

  const WeeklyMissions({
    super.key,
    required this.userLevel,
    required this.onRewardsTap,
  });

  @override
  State<WeeklyMissions> createState() => _WeeklyMissionsState();
}

class _WeeklyMissionsState extends State<WeeklyMissions> {
  final MissaoService _service = MissaoService();

  late Future<List<Mission>> _missionsFuture;

  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _missionsFuture = _service.buscarMissoesDeUsuario([1,2,3]);
  }

  void _reload() {
    setState(() {
      _missionsFuture = _service.buscarMissoesDeUsuario([1,2,3]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<List<Mission>>(
      future: _missionsFuture,
      builder: (context, snapshot) {
        final missions = snapshot.data ?? Mission.mock;

        return AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: colors.tertiary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Missões Semanais',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Recompensas
                      IconButton(
                        tooltip: 'Recompensas',
                        onPressed: widget.onRewardsTap,
                        icon: Icon(
                          Symbols.card_giftcard,
                          color: colors.onPrimary,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 2),

                      // Nível
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.onPrimary.withValues(alpha: 0.75),
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.userLevel}',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Column(
                      children: [
                        for (int i = 0; i < missions.length; i++) ...[
                          _MissionTile(
                            mission: missions[i],
                            onRefresh: _reload,
                          ),

                          if (i != missions.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                color: colors.onPrimary.withValues(alpha: 0.12),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MissionTile extends StatelessWidget {
  final Mission mission;
  final VoidCallback onRefresh;

  const _MissionTile({required this.mission, required this.onRefresh});

  String get statusText {
    if (mission.isCompleted) {
      return 'Concluída';
    }

    if (mission.progress > 0) {
      return 'Em andamento';
    }

    return 'Disponível';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final progressText = '${mission.progress}/${mission.goal}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mission.title,
          style: TextStyle(
            color: colors.onPrimary,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          mission.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onPrimary.withValues(alpha: 0.68),
            fontSize: 12.5,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 9),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 5,
            value: mission.progressPercentage,
            backgroundColor: colors.onPrimary.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(
              colors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Expanded(
              child: Text(
                '$statusText  •  $progressText',
                style: TextStyle(
                  color: colors.onPrimary.withValues(alpha: 0.68),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (mission.xpReward > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.bolt,
                    size: 15,
                    color: colors.onPrimary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '+${mission.xpReward} XP',
                    style: TextStyle(
                      color: colors.onPrimary.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class WeeklyMissionsDropup extends StatefulWidget {
  final Widget child;

  const WeeklyMissionsDropup({super.key, required this.child});

  @override
  State<WeeklyMissionsDropup> createState() => _WeeklyMissionsDropupState();
}

class _WeeklyMissionsDropupState extends State<WeeklyMissionsDropup> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 160,
            height: 34,
            decoration: BoxDecoration(
              color: colors.tertiary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Icon(
              expanded
                  ? Symbols.keyboard_arrow_down
                  : Symbols.keyboard_arrow_up,
              color: colors.onPrimary,
              size: 24,
            ),
          ),

          if (expanded) widget.child,
        ],
      ),
    );
  }
}
