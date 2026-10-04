import 'package:conport/models/amigo.dart';

/// Grafo social em memória para quando `AppConfig.usarApi` for `false`.
///
/// Dono único do estado de relações do modo demonstração: quem busca, quem
/// segue, quem é amigo e as listas de seguidores. O [UsuarioMock] consulta
/// aqui para montar o perfil.
class AmigoMock {
  AmigoMock._();

  /// Quem representa "eu" nos dados mockados.
  static const int eu = 2;

  static const List<Amigo> _catalogo = [
    Amigo(id: 1, nome: 'Carlos Silva', username: 'carlos', nivel: 2, xp: 150),
    Amigo(id: eu, nome: 'Usuário Demo', username: 'demo', nivel: 12, xp: 670),
    Amigo(id: 3, nome: 'Lucas Santos', username: 'lucas', nivel: 1, xp: 70),
    Amigo(id: 101, nome: 'Ana Beatriz', username: 'anabeatriz', nivel: 14, xp: 1320),
    Amigo(id: 102, nome: 'Carlos Eduardo', username: 'carlos.edu', nivel: 9, xp: 740),
    Amigo(id: 103, nome: 'Júlia Alves', username: 'julia', nivel: 12, xp: 1023),
    Amigo(id: 104, nome: 'Marina Souza', username: 'marina', nivel: 5, xp: 310),
    Amigo(id: 105, nome: 'Pedro Lima', username: 'pedro', nivel: 17, xp: 1850),
    Amigo(id: 106, nome: 'Rafael Costa', username: 'rafa', nivel: 3, xp: 120),
    Amigo(id: 201, nome: 'Lucas Martins', username: 'lucas.m', nivel: 7, xp: 560),
    Amigo(id: 202, nome: 'Fernanda Rocha', username: 'fernan', nivel: 11, xp: 980),
  ];

  static final Map<int, Set<int>> _seguindo = {};
  static final Map<int, Set<int>> _seguidores = {};
  static final Map<int, Set<int>> _amigos = {};

  static Set<int> _s(Map<int, Set<int>> mapa, int id) =>
      mapa.putIfAbsent(id, () => {});

  // ============================================================
  // CONSULTA
  // ============================================================

  static Amigo? porId(int id) {
    for (final usuario in _catalogo) {
      if (usuario.id == id) return usuario;
    }

    return null;
  }

  static List<Amigo> amigos() => _ordenar(_amigos[eu] ?? {});

  static List<Amigo> solicitacoes() => const [
    Amigo(id: 201, nome: 'Lucas Martins', nivel: 7, xp: 560, relacaoId: 21),
    Amigo(id: 202, nome: 'Fernanda Rocha', nivel: 11, xp: 980, relacaoId: 22),
  ];

  /// Busca por nome ou username, como o backend faz.
  ///
  /// [ignorar] é quem está logado: achar a si mesmo na busca é ruído.
  static List<Amigo> buscar(String termo, {int? ignorar}) {
    final alvo = termo.trim().toLowerCase();

    if (alvo.length < 2) return [];

    return _catalogo.where((u) {
      if (ignorar != null && u.id == ignorar) return false;
      if (_amigos[ignorar ?? eu]?.contains(u.id) ?? false) return false;

      return u.nome.toLowerCase().contains(alvo) ||
          (u.username ?? '').toLowerCase().contains(alvo);
    }).toList();
  }

  static List<Amigo> seguindo(int usuarioId) => _ordenar(_seguindo[usuarioId] ?? {});

  static List<Amigo> seguidores(int usuarioId) =>
      _ordenar(_seguidores[usuarioId] ?? {});

  /// Totais sem passar pelo catálogo: um id fora dele não pode fazer o
  /// contador do perfil mentir.
  static int totalSeguindo(int usuarioId) => _seguindo[usuarioId]?.length ?? 0;

  static int totalSeguidores(int usuarioId) => _seguidores[usuarioId]?.length ?? 0;

  static List<Amigo> _ordenar(Set<int> ids) {
    final lista = <Amigo>[];

    for (final id in ids) {
      final usuario = porId(id);
      if (usuario != null) lista.add(usuario);
    }

    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }

  /// [de] segue [para]?
  static bool sigo(int de, int para) => _seguindo[de]?.contains(para) ?? false;

  /// [por] segue [alvo]?
  static bool meSegue(int por, int alvo) =>
      _seguindo[alvo]?.contains(por) ?? false;

  static bool saoAmigos(int a, int b) => _amigos[a]?.contains(b) ?? false;

  // ============================================================
  // MUDANÇA
  // ============================================================

  static void seguir(int de, int para) {
    _s(_seguindo, de).add(para);
    _s(_seguidores, para).add(de);
  }

  static void deixarDeSeguir(int de, int para) {
    _s(_seguindo, de).remove(para);
    _s(_seguidores, para).remove(de);
  }

  /// Amigo vira seguidor mútuo, como o backend faz ao aceitar a amizade.
  static void serAmigos(int a, int b) {
    _s(_amigos, a).add(b);
    _s(_amigos, b).add(a);
    seguir(a, b);
    seguir(b, a);
  }

  /// Desfaz a amizade. O follow fica, como no backend: só a relação some.
  static void removerAmigo(int de, int outro) {
    _s(_amigos, de).remove(outro);
    _s(_amigos, outro).remove(de);
  }

  static void reiniciar() {
    _seguindo.clear();
    _seguidores.clear();
    _amigos.clear();
  }
}
