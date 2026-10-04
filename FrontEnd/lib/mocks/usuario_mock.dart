import 'package:conport/models/usuario.dart';

import 'amigo_mock.dart';

/// Usuários do modo demonstração.
///
/// Cada id é uma pessoa diferente: antes o mock devolvia o mesmo "Usuário
/// Demo" para qualquer id, o que fazia o perfil de outra pessoa parecer o
/// seu. O estado social (amigo, seguindo) vem do [AmigoMock], que é quem
/// guarda o grafo.
class UsuarioMock {
  UsuarioMock._();

  static Usuario pegarDados(int id) {
    final social = AmigoMock.porId(id);
    final souEu = id == AmigoMock.eu;

    return Usuario(
      id: id,
      nome: social?.nome ?? 'Usuário $id',
      username: social?.username ?? 'usuario$id',
      visibilidade: visibilidade(id),
      datanasc: souEu
          ? DateTime(2005, 5, 15)
          : DateTime(1998, 3 + (id % 6), 1 + (id % 27)),
      estado: 'São Paulo',
      cidade: "Santa Bárbara d'Oeste",
      email: '${social?.username ?? 'usuario$id'}@conport.com',
      // O AuthMock compara esta senha no login mockado.
      senha: souEu ? '123456' : null,
      confiavel: (social?.nivel ?? 1) > 8,
      xp: social?.xp ?? 0,
      level: social?.nivel ?? 1,
      moedas: 150,
      avatar: null,
      datacadastro: DateTime(2025, 7, 6),
      seguidores: AmigoMock.totalSeguidores(id),
      seguindo: AmigoMock.totalSeguindo(id),
      reportsEnviados: 5,
      reportsResolvidos: 3,
      reportsRejeitados: 1,
      reportsPendentes: 1,
      missoesConcluidas: 18,
      amigo: AmigoMock.saoAmigos(AmigoMock.eu, id),
      euSigo: AmigoMock.sigo(AmigoMock.eu, id),
      segueMe: AmigoMock.meSegue(AmigoMock.eu, id),
    );
  }

  /// Troca a visibilidade das listas (usado pelos testes de Configurações).
  static final Map<int, VisibilidadeSeguidores> _visibilidades = {};

  static VisibilidadeSeguidores visibilidade(int id) =>
      _visibilidades[id] ?? VisibilidadeSeguidores.publico;

  static void definirVisibilidade(int id, VisibilidadeSeguidores valor) {
    _visibilidades[id] = valor;
  }

  static void reiniciar() => _visibilidades.clear();
}
