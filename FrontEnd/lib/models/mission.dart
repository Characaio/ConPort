// tecnicamente parte do keirrisson mas meu tempo tá sobrando. mude quaisquer partes que julgar necessárias. se quiser deletar tudo deleta, seja feliz
// para valores eu tentei ser o mais case insensitive o possivel, pq to indo de memoria e eu n quero ler o código do caio. dnv, se necessario mudar, mude
// e corrijam quaisquer erros tbm, eu sou burra animal e usei majoritariamente o chat pra isso

enum MissionStatus { available, inProgress, completed, expired, unknown }

class Mission {
  final int id;
  final String title;
  final String description;
  final String type;
  final MissionStatus status;

  final int goal;
  final int progress;

  final int coinReward;
  final int xpReward;

  final DateTime? startTime;
  final DateTime? closingTime;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.goal,
    required this.progress,
    required this.coinReward,
    required this.xpReward,
    this.startTime,
    this.closingTime,
  });

  double get progressPercentage {
    if (goal <= 0) return 0;
    return (progress / goal).clamp(0.0, 1.0);
  }

  bool get isCompleted => status == MissionStatus.completed;

  factory Mission.fromJson(Map<String, dynamic> json) {
    MissionStatus parseStatus(String? value) {
      switch (value?.toUpperCase()) {
        case 'DISPONIVEL':
          return MissionStatus.available;
        case 'EM_ANDAMENTO':
          return MissionStatus.inProgress;
        case 'CONCLUIDA':
          return MissionStatus.completed;
        case 'EXPIRADA':
          return MissionStatus.expired;
        default:
          return MissionStatus.unknown;
      }
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return Mission(
      id: json['Id'] ?? json['id'] ?? 0,

      title: json['Nome'] ?? json['nome'] ?? 'Missão',

      // o DTO do backend nao possui Descricao
      // quando passar a enviar, ela será utilizada automaticamente
      // atualmente, é utilizada mock
      description:
          json['Descricao'] ??
          json['descricao'] ??
          _fallbackDescription(
            json['Nome'] ?? json['nome'] ?? '',
            json['TipoDeMissao'] ?? json['tipoDeMissao'],
          ),

      type:
          json['TipoDeMissao']?.toString() ??
          json['tipoDeMissao']?.toString() ??
          '',

      status: parseStatus(
        json['StatusDeMissao']?.toString() ??
            json['statusDeMissao']?.toString(),
      ),

      goal: json['Meta'] ?? json['meta'] ?? 1,
      progress: json['Progresso'] ?? json['progresso'] ?? 0,

      coinReward: json['MoedaRecompensa'] ?? json['moedaRecompensa'] ?? 0,

      xpReward: json['XpRecompensa'] ?? json['xpRecompensa'] ?? 0,

      startTime: parseDate(json['TempoDeInicio'] ?? json['tempoDeInicio']),

      closingTime: parseDate(
        json['TempoFechamento'] ?? json['tempoFechamento'],
      ),
    );
  }

  static String _fallbackDescription(String title, dynamic type) {
    switch (type?.toString().toUpperCase()) {
      case 'PLANTAR':
        return 'Plante uma muda e contribua para a preservação ambiental.';
      case 'RECICLAR':
        return 'Recicle materiais e envie para análise.';
      case 'REUTILIZAR':
        return 'Reutilize materiais que seriam descartados.';
      default:
        return 'Complete esta missão para receber sua recompensa.';
    }
  }

  static List<Mission> get mock {
    return const [
      Mission(
        id: 1,
        title: 'Plantar 2 mudas',
        description: 'Plante 2 mudas de sua escolha e envie para análise.',
        type: 'PLANTAR',
        status: MissionStatus.inProgress,
        goal: 2,
        progress: 1,
        coinReward: 25,
        xpReward: 40,
      ),
      Mission(
        id: 2,
        title: 'Recicle 3 garrafas',
        description: 'Plante 3 garrafas PET e envie para análise.',
        type: 'RECICLAR',
        status: MissionStatus.inProgress,
        goal: 3,
        progress: 2,
        coinReward: 20,
        xpReward: 35,
      ),
      Mission(
        id: 3,
        title: 'Pote de planta',
        description:
            'Crie um pote de planta utilizando materiais reutilizáveis e envie para análise.',
        type: 'REUTILIZAR',
        status: MissionStatus.available,
        goal: 1,
        progress: 0,
        coinReward: 30,
        xpReward: 50,
      ),
    ];
  }
}
