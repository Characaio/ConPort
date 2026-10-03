import 'package:conport/config/app_config.dart';

class Amigo {
  final int id;
  final String nome;
  final String? apelido;
  final String? avatar;
  final int nivel;
  final int xp;
  final int? relacaoId;

  const Amigo({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.xp,
    this.relacaoId,
    this.apelido,
    this.avatar,
  });

  factory Amigo.fromJson(Map<String, dynamic> json) => Amigo(
    id: json['Id'] ?? json['id'] ?? 0,
    nome: json['Nome'] ?? json['nome'] ?? 'Nome',
    apelido: json['Apelido'] ?? json['apelido'],
    avatar: json['Avatar'] ?? json['avatar'],
    nivel: json['Level'] ?? json['level'] ?? 0,
    xp: json['XP'] ?? json['xp'] ?? 0,
    relacaoId: json['RelacaoId'] ?? json['relacaoId'],
  );

  String? get avatarUrl {
    final a = avatar;
    if (a == null || a.isEmpty) return null;
    return '${AppConfig.apiUrl}/imagens/$a';
  }
}
