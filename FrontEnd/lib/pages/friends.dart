import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/pages/profile.dart';
import 'package:conport/services/usuarioService.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/amigo.dart';

// ============================================================
// PÁGINA
// ============================================================

enum _Aba { amigos, solicitacoes }

enum _AcaoAmigo { perfil, remover }

class Amigos extends StatefulWidget {
  const Amigos({
    super.key,
    required this.usuarioService,
    required this.usuarioId,
  });

  final UsuarioService usuarioService;
  final int usuarioId;

  @override
  State<Amigos> createState() => _AmigosState();
}

class _AmigosState extends State<Amigos> {
  // Já nascem vazias: o primeiro build() acontece antes da resposta da API.
  List<Amigo> amigos = [];
  List<Amigo> solicitacoes = [];

  bool carregando = true;
  String? erro;

  _Aba aba = _Aba.amigos;
  String busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final a = await widget.usuarioService.listarAmigos();
      final s = await widget.usuarioService.listarSolicitacoes();
      if (!mounted) return;
      setState(() {
        amigos = a;
        solicitacoes = s;
        carregando = false;
        _ordenar();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível carregar seus amigos.';
        carregando = false;
      });
    }
  }

  void _ordenar() {
    amigos.sort((a, b) => a.nome.compareTo(b.nome));
  }

  List<Amigo> get _amigosFiltrados {
    final termo = busca.trim().toLowerCase();

    if (termo.isEmpty) return amigos;

    return amigos.where((a) => a.nome.toLowerCase().contains(termo)).toList();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _verPerfil(Amigo amigo) {
    // Por enquanto o UsuarioService em modo mock devolve sempre o mesmo
    // usuário demo; com a API ligada, abre o perfil do amigo de verdade.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            Profile(usuarioId: amigo.id, usuarioService: widget.usuarioService),
      ),
    );
  }

  Future<void> _remover(Amigo amigo) async {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appColors.accentGreen,
        title: const Text(
          'Remover amigo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        content: Text(
          'Deseja remover ${amigo.nome} dos seus amigos?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;
    
    try {
      await widget.usuarioService.removerAmigo(amigo.id);
    } catch (e) {
      if (mounted) _mensagem('Não foi possível remover ${amigo.nome}.');
      return;
    }

    if (!mounted) return;
    setState(() => amigos.removeWhere((a) => a.id == amigo.id));
    _mensagem('${amigo.nome} foi removido dos seus amigos.');
  }

  Future<void> _aceitar(Amigo amigo) async {
    final relacaoId = amigo.relacaoId;
    if (relacaoId == null) {
      if (mounted) _mensagem('Não foi possível aceitar ${amigo.nome}.');
      return;
    }

    try {
      await widget.usuarioService.aceitar(relacaoId);
    } catch (e) {
      if (mounted) _mensagem('Não foi possível aceitar ${amigo.nome}.');
      return;
    }

    if (!mounted) return;
    setState(() {
      solicitacoes.removeWhere((a) => a.id == amigo.id);
      amigos.add(amigo);
      _ordenar();
    });
    _mensagem('Agora você e ${amigo.nome} são amigos!');
  }

  Future<void> _recusar(Amigo amigo) async {
    final relacaoId = amigo.relacaoId;
    if (relacaoId == null) {
      if (mounted) _mensagem('Não foi possível recusar ${amigo.nome}.');
      return;
    }

    try {
      await widget.usuarioService.recusar(relacaoId);
    } catch (e) {
      if (mounted) _mensagem('Não foi possível recusar ${amigo.nome}.');
      return;
    }

    if (!mounted) return;
    setState(() => solicitacoes.removeWhere((a) => a.id == amigo.id));
    _mensagem('Solicitação de ${amigo.nome} recusada.');
  }

  /// Buscar usuário: abre a folha com os resultados e, ao escolher um, abre
  /// o perfil — de lá saem os botões de seguir e adicionar amigo.
  Future<void> _buscar() async {
    final pessoa = await showDialog<Amigo>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _BuscarUsuarioDialog(
        usuarioService: widget.usuarioService,
      ),
    );

    if (pessoa == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Profile(
          usuarioId: pessoa.id,
          usuarioService: widget.usuarioService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    if (carregando) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (erro != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(erro!, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                _BotaoPilula(
                  texto: 'Tentar de novo',
                  cor: appColors.accentSalmon,
                  onPressed: () {
                    setState(() {
                      carregando = true;
                      erro = null;
                    });
                    _carregar();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtrados = _amigosFiltrados;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Topbar(hasLogo: false, hasReturn: true, text: 'Seus Amigos'),
                  const Divider(),
                  const SizedBox(height: 8),

                  _Abas(
                    aba: aba,
                    qtdAmigos: amigos.length,
                    qtdSolicitacoes: solicitacoes.length,
                    verde: appColors.accentGreen,
                    onChanged: (nova) => setState(() => aba = nova),
                  ),

                  const SizedBox(height: 14),

                  if (aba == _Aba.amigos) ...[
                    TextField(
                      onChanged: (v) => setState(() => busca = v),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Buscar amigo',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Symbols.search, size: 20),
                        filled: true,
                        fillColor: appColors.cardBackground,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Expanded(
                    child: aba == _Aba.amigos
                        ? _listaAmigos(filtrados)
                        : _listaSolicitacoes(),
                  ),

                  const SizedBox(height: 12),

                  _BotaoPilula(
                    icon: Symbols.person_search,
                    texto: 'Buscar usuário',
                    cor: appColors.accentSalmon,
                    onPressed: _buscar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listaAmigos(List<Amigo> filtrados) {
    if (amigos.isEmpty) {
      return const _Vazio(
        icon: Symbols.group,
        texto: 'Você ainda não tem amigos.\nQue tal adicionar o primeiro?',
      );
    }

    if (filtrados.isEmpty) {
      return const _Vazio(
        icon: Symbols.search_off,
        texto: 'Nenhum amigo encontrado.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final amigo = filtrados[index];

        return _CardAmigo(
          amigo: amigo,
          onTap: () => _verPerfil(amigo),
          onAcao: (acao) {
            switch (acao) {
              case _AcaoAmigo.perfil:
                _verPerfil(amigo);
                break;
              case _AcaoAmigo.remover:
                _remover(amigo);
                break;
            }
          },
        );
      },
    );
  }

  Widget _listaSolicitacoes() {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    if (solicitacoes.isEmpty) {
      return const _Vazio(
        icon: Symbols.inbox,
        texto: 'Nenhuma solicitação pendente.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: solicitacoes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final amigo = solicitacoes[index];

        return _CardSolicitacao(
          amigo: amigo,
          verde: appColors.accentGreen,
          marrom: appColors.accentBrown,
          onAceitar: () => _aceitar(amigo),
          onRecusar: () => _recusar(amigo),
        );
      },
    );
  }
}

// ============================================================
// ABAS
// ============================================================

class _Abas extends StatelessWidget {
  final _Aba aba;
  final int qtdAmigos;
  final int qtdSolicitacoes;
  final Color verde;
  final ValueChanged<_Aba> onChanged;

  const _Abas({
    required this.aba,
    required this.qtdAmigos,
    required this.qtdSolicitacoes,
    required this.verde,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ItemAba(
            texto: 'Amigos ($qtdAmigos)',
            selecionada: aba == _Aba.amigos,
            cor: verde,
            onTap: () => onChanged(_Aba.amigos),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ItemAba(
            texto: 'Solicitações',
            selecionada: aba == _Aba.solicitacoes,
            cor: verde,
            badge: qtdSolicitacoes,
            onTap: () => onChanged(_Aba.solicitacoes),
          ),
        ),
      ],
    );
  }
}

class _ItemAba extends StatelessWidget {
  final String texto;
  final bool selecionada;
  final Color cor;
  final int badge;
  final VoidCallback onTap;

  const _ItemAba({
    required this.texto,
    required this.selecionada,
    required this.cor,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionada ? cor : const Color(0xFFCFCFCF),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: SizedBox(
          height: 34,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  texto,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selecionada ? Colors.white : Colors.black87,
                  ),
                ),
                if (badge > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05555),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARDS
// ============================================================

BoxDecoration _decoracaoCard(Color cor) {
  return BoxDecoration(
    color: cor,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
    ],
  );
}

class _CardAmigo extends StatelessWidget {
  final Amigo amigo;
  final VoidCallback onTap;
  final ValueChanged<_AcaoAmigo> onAcao;

  const _CardAmigo({
    required this.amigo,
    required this.onTap,
    required this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: _decoracaoCard(appColors.cardBackground),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                _AvatarAmigo(amigo: amigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amigo.nome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nível ${amigo.nivel} • ${amigo.xp} XP',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_AcaoAmigo>(
                  icon: const Icon(Symbols.more_vert, size: 20),
                  onSelected: onAcao,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _AcaoAmigo.perfil,
                      child: Text('Ver perfil'),
                    ),
                    PopupMenuItem(
                      value: _AcaoAmigo.remover,
                      child: Text('Remover amigo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSolicitacao extends StatelessWidget {
  final Amigo amigo;
  final Color verde;
  final Color marrom;
  final VoidCallback onAceitar;
  final VoidCallback onRecusar;

  const _CardSolicitacao({
    required this.amigo,
    required this.verde,
    required this.marrom,
    required this.onAceitar,
    required this.onRecusar,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      decoration: _decoracaoCard(appColors.inputBackground),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarAmigo(amigo: amigo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amigo.nome,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Quer ser seu amigo',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _BotaoPilula(
                  texto: 'Aceitar',
                  cor: verde,
                  onPressed: onAceitar,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BotaoPilula(
                  texto: 'Recusar',
                  cor: marrom,
                  onPressed: onRecusar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ESTADO VAZIO
// ============================================================

class _Vazio extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Vazio({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: appColors.onAccent),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: appColors.onAccent),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTÃO
// ============================================================

class _BotaoPilula extends StatelessWidget {
  final String texto;
  final Color cor;
  final VoidCallback onPressed;
  final IconData? icon;

  const _BotaoPilula({
    required this.texto,
    required this.cor,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            Text(texto, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// POPUP: BUSCAR USUÁRIO
// ============================================================

/// Busca por nome ou username e mostra quem deu match.
///
/// Devolve a pessoa escolhida. O pedido de amizade não sai daqui: quem pede
/// é o botão "Adicionar amigo" no perfil, que fica mais perto de quem é
/// escolhido — e é lá que mora a diferença entre seguir e ser amigo.
class _BuscarUsuarioDialog extends StatefulWidget {
  final UsuarioService usuarioService;

  const _BuscarUsuarioDialog({required this.usuarioService});

  @override
  State<_BuscarUsuarioDialog> createState() => _BuscarUsuarioDialogState();
}

class _BuscarUsuarioDialogState extends State<_BuscarUsuarioDialog> {
  final TextEditingController _controller = TextEditingController();

  List<Amigo> resultados = [];
  bool buscando = false;
  bool buscou = false;
  String? _erro;

  /// Número da busca em curso: uma resposta lenta de um termo antigo não
  /// pode sobrescrever os resultados do termo novo.
  int _buscaAtual = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar(String termo) async {
    final id = ++_buscaAtual;

    if (termo.trim().length < 2) {
      setState(() {
        resultados = [];
        buscando = false;
        buscou = false;
        _erro = null;
      });
      return;
    }

    setState(() {
      buscando = true;
      buscou = true;
      _erro = null;
    });

    try {
      final lista = await widget.usuarioService.buscar(termo);

      if (!mounted || id != _buscaAtual) return;

      setState(() {
        resultados = lista;
        buscando = false;
      });
    } catch (_) {
      if (!mounted || id != _buscaAtual) return;

      setState(() {
        buscando = false;
        _erro = 'Não foi possível buscar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Dialog(
      backgroundColor: appColors.cardBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buscar usuário',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pelo nome ou pelo username. Toque para abrir o perfil.',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _buscar,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Nome ou username',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Symbols.person_search, size: 20),
                  filled: true,
                  fillColor: appColors.inputBackground,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _resultados(),
              const SizedBox(height: 8),
              _BotaoPilula(
                texto: 'Fechar',
                cor: const Color(0xFF6B5750),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultados() {
    if (_erro != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(_erro!, style: const TextStyle(fontSize: 12)),
      );
    }

    if (buscando) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!buscou) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Digite pelo menos duas letras.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      );
    }

    if (resultados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Nenhum usuário encontrado.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: resultados.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final pessoa = resultados[index];

          return _CardResultado(
            pessoa: pessoa,
            onTap: () => Navigator.pop(context, pessoa),
          );
        },
      ),
    );
  }
}

/// Linha da busca: nome, username e nível. Sem botão de ação — a pessoa
/// pediu uma lista para abrir perfis, não um botão de adicionar.
class _CardResultado extends StatelessWidget {
  final Amigo pessoa;
  final VoidCallback onTap;

  const _CardResultado({required this.pessoa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Material(
      color: appColors.inputBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              _AvatarResultado(pessoa: pessoa),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pessoa.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${pessoa.username ?? 'sem username'} • Nível ${pessoa.nivel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(Symbols.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarResultado extends StatelessWidget {
  final Amigo pessoa;

  const _AvatarResultado({required this.pessoa});

  @override
  Widget build(BuildContext context) {
    final url = pessoa.avatarUrl;

    return CircleAvatar(
      radius: 18,
      backgroundImage: url == null ? null : NetworkImage(url),
      onBackgroundImageError: url == null ? null : (error, stackTrace) {},
      child: url == null
          ? const Icon(Symbols.person, size: 22, color: Colors.black)
          : null,
    );
  }
}

// AVATAR DO AMIGO
//
// Usa a foto do usuário quando a API devolve uma; sem foto, cai no ícone.

class _AvatarAmigo extends StatelessWidget {
  final Amigo amigo;

  const _AvatarAmigo({required this.amigo});

  @override
  Widget build(BuildContext context) {
    final url = amigo.avatarUrl;

    return CircleAvatar(
      radius: 22,
      backgroundImage: url == null ? null : NetworkImage(url),
      onBackgroundImageError: url == null ? null : (error, stackTrace) {},
      child: url == null
          ? const Icon(Symbols.person, size: 28, color: Colors.black)
          : null,
    );
  }
}
