import 'package:conport/models/amigo.dart';

class AmigoMock {
  static List<Amigo> amigos() => [
    const Amigo(
      id: 101,
      nome: 'Ana Beatriz',
      nivel: 14,
      xp: 1320,
      relacaoId: 11,
    ),
    const Amigo(
      id: 102,
      nome: 'Carlos Eduardo',
      nivel: 9,
      xp: 740,
      relacaoId: 12,
    ),
    const Amigo(
      id: 103,
      nome: 'Júlia Alves',
      nivel: 12,
      xp: 1023,
      relacaoId: 13,
    ),
    const Amigo(
      id: 104,
      nome: 'Marina Souza',
      nivel: 5,
      xp: 310,
      relacaoId: 14,
    ),
    const Amigo(
      id: 105,
      nome: 'Pedro Lima',
      nivel: 17,
      xp: 1850,
      relacaoId: 15,
    ),
    const Amigo(
      id: 106,
      nome: 'Rafael Costa',
      nivel: 3,
      xp: 120,
      relacaoId: 16,
    ),
  ];

  static List<Amigo> solicitacoes() => [
    const Amigo(
      id: 201,
      nome: 'Lucas Martins',
      nivel: 7,
      xp: 560,
      relacaoId: 21,
    ),
    const Amigo(
      id: 202,
      nome: 'Fernanda Rocha',
      nivel: 11,
      xp: 980,
      relacaoId: 22,
    ),
  ];
}
