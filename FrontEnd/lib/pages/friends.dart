import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/pages/profile.dart';
import 'package:conport/services/usuarioService.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/core/theme/app_theme.dart';

// ============================================================
// MODELO + MOCK (temporário, até existir na API)
// Quando o backend tiver o endpoint, mova Amigo para
// lib/models/amigo.dart e crie um AmigoService no padrão dos outros.
// ============================================================

class Amigo {
  final int id;
  final String nome;
  final int nivel;
  final int xp;

  const Amigo({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.xp,
  });
}

class _AmigosMock {
  static List<Amigo> amigos() => [
    const Amigo(id: 101, nome: 'Ana Beatriz', nivel: 14, xp: 1320),
    const Amigo(id: 102, nome: 'Carlos Eduardo', nivel: 9, xp: 740),
    const Amigo(id: 103, nome: 'Júlia Alves', nivel: 12, xp: 1023),
    const Amigo(id: 104, nome: 'Marina Souza', nivel: 5, xp: 310),
    const Amigo(id: 105, nome: 'Pedro Lima', nivel: 17, xp: 1850),
    const Amigo(id: 106, nome: 'Rafael Costa', nivel: 3, xp: 120),
  ];

  static List<Amigo> solicitacoes() => [
    const Amigo(id: 201, nome: 'Lucas Martins', nivel: 7, xp: 560),
    const Amigo(id: 202, nome: 'Fernanda Rocha', nivel: 11, xp: 980),
  ];
}

// ============================================================
// PÁGINA
// ============================================================

enum _Aba { amigos, solicitacoes }

enum _AcaoAmigo { perfil, remover }

class Amigos extends StatefulWidget {
  const Amigos({super.key});

  @override
  State<Amigos> createState() => _AmigosState();
}

class _AmigosState extends State<Amigos> {
  late List<Amigo> amigos;
  late List<Amigo> solicitacoes;

  _Aba aba = _Aba.amigos;
  String busca = '';

  @override
  void initState() {
    super.initState();

    amigos = _AmigosMock.amigos();
    solicitacoes = _AmigosMock.solicitacoes();
    _ordenar();
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
        builder: (_) => SafeArea(
          child: Profile(
            usuarioId: amigo.id,
            usuarioService: const UsuarioService(),
          ),
        ),
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

    // TODO: chamar a API para remover a amizade.
    setState(() => amigos.removeWhere((a) => a.id == amigo.id));
    _mensagem('${amigo.nome} foi removido dos seus amigos.');
  }

  void _aceitar(Amigo amigo) {
    // TODO: chamar a API para aceitar a solicitação.
    setState(() {
      solicitacoes.removeWhere((a) => a.id == amigo.id);
      amigos.add(amigo);
      _ordenar();
    });
    _mensagem('Agora você e ${amigo.nome} são amigos!');
  }

  void _recusar(Amigo amigo) {
    // TODO: chamar a API para recusar a solicitação.
    setState(() => solicitacoes.removeWhere((a) => a.id == amigo.id));
    _mensagem('Solicitação de ${amigo.nome} recusada.');
  }

  Future<void> _adicionar() async {
    final usuario = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const _AdicionarAmigoDialog(),
    );

    if (usuario == null || !mounted) return;

    // TODO: chamar a API para enviar a solicitação.
    _mensagem('Solicitação enviada para $usuario.');
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _amigosFiltrados;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    icon: Symbols.person_add,
                    texto: 'Adicionar Amigos',
                    cor: appColors.accentSalmon,
                    onPressed: _adicionar,
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final amigo = filtrados[index];

        return _CardAmigo(
          amigo: amigo,
          onTap: () => _verPerfil(amigo),
          onAcao: (acao) {
            switch (acao) {
              case _AcaoAmigo.perfil:
                _verPerfil(amigo);
              case _AcaoAmigo.remover:
                _remover(amigo);
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                _AvatarAmigo(id: amigo.id),
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
              _AvatarAmigo(id: amigo.id),
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

class _AvatarAmigo extends StatelessWidget {
  final int id;

  const _AvatarAmigo({required this.id});

  static const List<Color> _paleta = [
    Color(0xFF6A4FA3),
    Color(0xFFC3917C),
    Color(0xFF5E7654),
    Color(0xFF766057),
    Color(0xFFC25B5B),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: trocar pela foto do usuário quando existir.
    return CircleAvatar(
      radius: 22,
      backgroundColor: _paleta[id % _paleta.length],
      child: const Icon(Symbols.person, size: 28, color: Colors.black),
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
// POPUP: ADICIONAR AMIGO
// ============================================================

class _AdicionarAmigoDialog extends StatefulWidget {
  const _AdicionarAmigoDialog();

  @override
  State<_AdicionarAmigoDialog> createState() => _AdicionarAmigoDialogState();
}

class _AdicionarAmigoDialogState extends State<_AdicionarAmigoDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _controller.text.trim();

    if (texto.isEmpty) {
      setState(() => _erro = 'Digite o nome de usuário.');
      return;
    }

    Navigator.pop(context, texto);
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
                'Adicionar Amigos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Envie uma solicitação pelo nome de usuário.',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (_) {
                  if (_erro != null) setState(() => _erro = null);
                },
                onSubmitted: (_) => _enviar(),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Nome de usuário',
                  hintStyle: const TextStyle(fontSize: 13),
                  errorText: _erro,
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _BotaoPilula(
                      texto: 'Enviar',
                      cor: const Color(0xFF5E7654),
                      onPressed: _enviar,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BotaoPilula(
                      texto: 'Cancelar',
                      cor: const Color(0xFF6B5750),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
