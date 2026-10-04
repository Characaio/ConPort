import 'package:flutter_test/flutter_test.dart';

import 'package:conport/models/notificacao.dart';

/// Confere que o JSON devolvido pelo `NotificacaoResponseDTO` do backend é
/// lido certinho pelo model do app.
///
/// Se alguém renomear um campo no DTO (Java) ou no fromJson (Dart) sem ajustar
/// o outro lado, é este teste que quebra.
void main() {
  // Exatamente o que o Jackson serializa a partir do record
  // NotificacaoResponseDTO (id, usuarioId, titulo, texto, data, lida).
  final jsonDaApi = <String, dynamic>{
    'id': 7,
    'usuarioId': 3,
    'titulo': 'Conquista desbloqueada!',
    'texto': 'Você enviou o seu primeiro report.',
    'data': '2026-10-03T22:30:15.123456',
    'lida': false,
  };

  group('Notificacao.fromJson', () {
    test('lê todos os campos que a API devolve', () {
      final n = Notificacao.fromJson(jsonDaApi);

      expect(n.id, 7);
      expect(n.usuarioId, 3);
      expect(n.titulo, 'Conquista desbloqueada!');
      expect(n.texto, 'Você enviou o seu primeiro report.');
      expect(n.lida, isFalse);
      expect(n.naoLida, isTrue);
    });

    test('converte a data para DateTime', () {
      final n = Notificacao.fromJson(jsonDaApi);

      expect(n.data, isA<DateTime>());
      expect(n.data.year, 2026);
      expect(n.data.month, 10);
      expect(n.data.day, 3);
    });

    test('aceita data sem fração de segundo', () {
      final n = Notificacao.fromJson({...jsonDaApi, 'data': '2026-01-02T03:04:05'});

      expect(n.data, DateTime(2026, 1, 2, 3, 4, 5));
    });

    test('aceita o backend devolvendo PascalCase', () {
      final n = Notificacao.fromJson({
        'Id': 9,
        'UsuarioId': 3,
        'Titulo': 'Aviso',
        'Texto': 'Chuva forte na unidade.',
        'Data': '2026-10-01T10:00:00',
        'Lida': true,
      });

      expect(n.id, 9);
      expect(n.usuarioId, 3);
      expect(n.titulo, 'Aviso');
      expect(n.texto, 'Chuva forte na unidade.');
      expect(n.lida, isTrue);
      expect(n.naoLida, isFalse);
    });

    test('não quebra com campo faltando ou vazio', () {
      final n = Notificacao.fromJson({'id': 1});

      expect(n.id, 1);
      expect(n.usuarioId, 0);
      expect(n.titulo, isEmpty);
      expect(n.texto, isEmpty);
      expect(n.lida, isFalse);
      expect(n.data, isA<DateTime>());
    });

    test('entende lida vindo de string ou número', () {
      expect(Notificacao.fromJson({...jsonDaApi, 'lida': 'true'}).lida, isTrue);
      expect(Notificacao.fromJson({...jsonDaApi, 'lida': 1}).lida, isTrue);
      expect(Notificacao.fromJson({...jsonDaApi, 'lida': 'false'}).lida, isFalse);
      expect(Notificacao.fromJson({...jsonDaApi, 'lida': 0}).lida, isFalse);
    });
  });

  group('copyWith', () {
    test('marca como lida sem mexer no resto', () {
      final original = Notificacao.fromJson(jsonDaApi);
      final lida = original.copyWith(lida: true);

      expect(lida.lida, isTrue);
      expect(lida.id, original.id);
      expect(lida.titulo, original.titulo);
      expect(lida.texto, original.texto);
      expect(lida.data, original.data);
    });
  });
}
