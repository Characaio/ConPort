import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/services/usuarioService.dart';
import 'package:conport/widgets/lista_de_pessoas.dart';
import 'package:conport/widgets/topbar.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.usuarioService,
    required this.usuarioId,
  });

  final UsuarioService usuarioService;
  final int usuarioId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Usuario? usuario;

  /// Progresso do usuário *observado*. Só existe quando [ _observoOutraPessoa]
  /// é verdadeiro; no resto quem manda é [Conquistas.instance].
  Set<TipoConquista>? conquistasDeOutro;

  bool _ocupado = false;

  bool get _eMeuPerfil => AuthSession.instance.usuario?.id == widget.usuarioId;

  /// A tela só é de "outra pessoa" quando há alguém logado que não seja ela.
  ///
  /// Sem sessão não existe "eu" para confundir: o progresso da sessão é a
  /// única coisa conhecida, e é o que esta tela sempre mostrou.
  bool get _observoOutraPessoa {
    final meuId = AuthSession.instance.usuario?.id;

    return meuId != null && meuId != widget.usuarioId;
  }

  /// Seguir e pedir amizade só fazem sentido com alguém logado: sem sessão os
  /// botões sumem em vez de aparecerem e não fazerem nada.
  bool get _mostraAcoes => _observoOutraPessoa;

  int? get _visorId => AuthSession.instance.usuario?.id;

  @override
  void initState() {
    super.initState();
    Conquistas.instance.addListener(_conquistasMudaram);
    carregarUsuario();
  }

  @override
  void dispose() {
    Conquistas.instance.removeListener(_conquistasMudaram);
    super.dispose();
  }

  void _conquistasMudaram() {
    if (mounted) setState(() {});
  }

  Future<void> _carregarConquistas() async {
    final tipos = await Conquistas.deUsuario(widget.usuarioId);

    if (!mounted) return;

    setState(() {
      conquistasDeOutro = tipos;
    });
  }

  Future<void> carregarUsuario() async {
    try {
      final dados = await widget.usuarioService.pegarDados(
        widget.usuarioId,
        visorId: _visorId,
      );

      if (!mounted) return;

      setState(() {
        usuario = dados;
      });

      // Conquistas de outra pessoa: o singleton da sessão é o meu, não o
      // dele. Sem isso todo perfil mostrava as minhas conquistas.
      if (_observoOutraPessoa) await _carregarConquistas();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        usuario = null;
      });
    }
  }

  // ============================================================
  // AÇÕES
  // ============================================================

  Future<void> _alternarSeguimento() async {
    final u = usuario;
    if (u == null || _visorId == null || _ocupado) return;

    final estavaSeguindo = u.euSigo;

    // Atualiza na hora: o botão responde ao toque, não à latência.
    setState(() => _ocupado = true);

    try {
      if (estavaSeguindo) {
        await widget.usuarioService.deixarDeSeguir(_visorId!, u.id);
      } else {
        await widget.usuarioService.seguir(_visorId!, u.id);
      }

      if (!mounted) return;

      await carregarUsuario();

      if (!mounted) return;

      _mensagem(
        estavaSeguindo
            ? 'Você deixou de seguir ${u.nome}.'
            : 'Agora você segue ${u.nome}.',
      );
    } catch (e) {
      if (!mounted) return;
      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _pedirAmizade() async {
    final u = usuario;
    if (u == null || _visorId == null || _ocupado) return;

    setState(() => _ocupado = true);

    try {
      await widget.usuarioService.enviarSolicitacao(_visorId!, u.id);

      if (!mounted) return;

      await carregarUsuario();

      if (!mounted) return;

      _mensagem('Solicitação enviada para ${u.nome}.');
      await registrarConquista(context, TipoConquista.amigoAdicionado);
    } catch (e) {
      if (!mounted) return;
      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirLista({required bool seguindo}) async {
    final u = usuario;
    if (u == null) return;

    final pessoa = await mostrarListaDePessoas(
      context,
      titulo: seguindo ? 'Seguindo' : 'Seguidores',
      usuarioId: u.id,
      visorId: _visorId,
      carregar: seguindo
          ? widget.usuarioService.listarSeguindo
          : widget.usuarioService.listarSeguidores,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (usuario == null) {
      return Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final u = usuario!;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    final ownProfile = _eMeuPerfil;
    final desbloqueadas = _observoOutraPessoa
        ? (conquistasDeOutro ?? const <TipoConquista>{})
        : Conquistas.instance.desbloqueadas;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Topbar(
                hasLogo: false,
                hasReturn: true,
                showSettings: ownProfile,
                text: ownProfile ? 'Perfil' : u.nome,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Center(child: _Avatar(url: u.avatarUrl)),

                        const SizedBox(height: 18),

                        // Nome e contadores
                        Text(
                          u.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (u.username != null && u.username!.isNotEmpty)
                          Text(
                            '@${u.username}',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _Contador(
                              valor: u.seguindo ?? 0,
                              rotulo: 'Seguindo',
                              // Clicável nas duas casas: o meu e o de quem
                              // estou vendo.
                              aoTocar: () => _abrirLista(seguindo: true),
                            ),
                            const SizedBox(width: 14),
                            _Contador(
                              valor: u.seguidores ?? 0,
                              rotulo: 'Seguidores',
                              aoTocar: () => _abrirLista(seguindo: false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          u.datacadastro != null
                              ? 'Entrou em ${_dataPorExtenso(u.datacadastro!)}'
                              : 'Entrou há pouco tempo',
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text(
                          'Em ${u.estado}',
                          style: const TextStyle(fontSize: 10),
                        ),

                        if (_mostraAcoes) ...[
                          const SizedBox(height: 16),
                          _AcoesDoPerfil(
                            euSigo: u.euSigo,
                            amigo: u.amigo,
                            ocupado: _ocupado,
                            corSeguir: appColors.accentSalmon,
                            corSeguindo: colors.surfaceContainerHighest,
                            corAmigo: appColors.accentBrown,
                            aoSeguir: _alternarSeguimento,
                            aoPedirAmizade: _pedirAmizade,
                          ),
                        ],

                        const SizedBox(height: 18),
                        const Center(
                          child: SizedBox(width: 200, child: Divider()),
                        ),
                        const SizedBox(height: 10),

                        // Visão geral
                        const Text(
                          'Visão geral',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _Dado(
                                    icon: Symbols.stars,
                                    rotulo: 'Nível: ',
                                    valor: '${u.level}',
                                  ),
                                  _Dado(
                                    icon: Symbols.keyboard_double_arrow_up,
                                    rotulo: 'Experiência: ',
                                    valor: '${u.xp}',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  _Dado(
                                    icon: Symbols.redeem,
                                    rotulo: 'Recompensas: ',
                                    valor: '${u.moedas}',
                                  ),
                                  _Dado(
                                    icon: Symbols.flag,
                                    rotulo: 'Reports: ',
                                    valor: '${u.reportsEnviados ?? 0}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Conquistas
                        Row(
                          children: [
                            const Text(
                              'Conquistas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_observoOutraPessoa && conquistasDeOutro == null)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            for (final conquista in Conquistas.instance.todas)
                              _Conquista(
                                conquista: conquista,
                                desbloqueada: desbloqueadas.contains(
                                  conquista.tipo,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${desbloqueadas.length} de '
                          '${Conquistas.instance.total} desbloqueadas',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        if (ownProfile) ...[
                          const SizedBox(height: 32),

                          // Seus reports
                          _BotaoPilula(
                            icon: Symbols.flag_2,
                            texto: 'Seus Reports',
                            cor: appColors.accentBrown,
                            onPressed: () {
                              PageLoader.go(context, PageLoader.myreports);
                            },
                          ),
                        ] else if (_mostraAcoes) ...[
                          const SizedBox(height: 32),
                          _BotaoPilula(
                            icon: Symbols.group,
                            texto: 'Seus Amigos',
                            cor: appColors.accentSalmon,
                            onPressed: () {
                              PageLoader.go(context, PageLoader.friends);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

/// Seguir e adicionar amigo, lado a lado, no perfil de outra pessoa.
class _AcoesDoPerfil extends StatelessWidget {
  final bool euSigo;
  final bool amigo;
  final bool ocupado;
  final Color corSeguir;
  final Color corSeguindo;
  final Color corAmigo;
  final VoidCallback aoSeguir;
  final VoidCallback aoPedirAmizade;

  const _AcoesDoPerfil({
    required this.euSigo,
    required this.amigo,
    required this.ocupado,
    required this.corSeguir,
    required this.corSeguindo,
    required this.corAmigo,
    required this.aoSeguir,
    required this.aoPedirAmizade,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Botao(
            // Seguir e adicionar amigo são ações diferentes: o follow é
            // imediato e silencioso, a amizade pede aprovação.
            rotulo: euSigo ? 'Seguindo' : 'Seguir',
            icone: euSigo ? Symbols.check : Symbols.person_add,
            fundo: euSigo ? corSeguindo : corSeguir,
            onPressed: ocupado ? null : aoSeguir,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Botao(
            rotulo: amigo ? 'Amigos' : 'Adicionar amigo',
            icone: amigo ? Symbols.group : Symbols.person_add_alt,
            fundo: amigo ? corSeguindo : corAmigo,
            onPressed: amigo || ocupado ? null : aoPedirAmizade,
          ),
        ),
      ],
    );
  }
}

class _Botao extends StatelessWidget {
  final String rotulo;
  final IconData icone;
  final Color fundo;
  final VoidCallback? onPressed;

  const _Botao({
    required this.rotulo,
    required this.icone,
    required this.fundo,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final desativado = onPressed == null;

    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icone, size: 16),
        label: Text(
          rotulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: desativado
              ? colors.onSurfaceVariant
              : appColors.onAccent,
          elevation: desativado ? 0 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;

  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return CircleAvatar(
      radius: 44,
      backgroundColor: appColors.accentSalmon,
      backgroundImage: url == null ? null : NetworkImage(url!),
      onBackgroundImageError: url == null ? null : (error, stackTrace) {},
      child: url == null
          ? Icon(
              Symbols.person,
              size: 64,
              color: appColors.onAccent,
              weight: 600,
            )
          : null,
    );
  }
}

class _Contador extends StatelessWidget {
  final int valor;
  final String rotulo;
  final VoidCallback? aoTocar;

  const _Contador({required this.valor, required this.rotulo, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$valor',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        Text(rotulo, style: const TextStyle(fontSize: 7)),
      ],
    );

    if (aoTocar == null) return conteudo;

    // Fica com aparência de link: o número é o alvo, mas a área toda
    // responde, porque 11px é pequeno para o dedo.
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(4), child: conteudo),
    );
  }
}

class _Dado extends StatelessWidget {
  final IconData icon;
  final String rotulo;
  final String valor;

  const _Dado({required this.icon, required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, fill: 1),
          const SizedBox(width: 6),
          Flexible(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 12, color: cor),
                children: [
                  TextSpan(text: rotulo),
                  TextSpan(text: valor),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Conquista extends StatelessWidget {
  final Conquista conquista;
  final bool desbloqueada;

  const _Conquista({required this.conquista, required this.desbloqueada});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Column(
      children: [
        Tooltip(
          message: conquista.descricao,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: desbloqueada
                  ? appColors.accentGreen
                  : colors.surfaceContainerHighest,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              desbloqueada ? conquista.icone : Symbols.lock,
              size: 22,
              color: desbloqueada
                  ? appColors.onAccent
                  : colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            conquista.titulo,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              fontWeight: desbloqueada ? FontWeight.w700 : FontWeight.w500,
              color: desbloqueada ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoPilula extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color cor;
  final VoidCallback onPressed;

  const _BotaoPilula({
    required this.icon,
    required this.texto,
    required this.cor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(texto, style: const TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: appColors.onAccent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FORMATADORES
// ============================================================

String _dataPorExtenso(DateTime data) {
  const meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  final dia = data.day.toString().padLeft(2, '0');

  return '$dia de ${meses[data.month - 1]}, ${data.year}';
}
