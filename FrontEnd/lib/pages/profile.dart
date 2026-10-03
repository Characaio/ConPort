import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/services/usuarioService.dart';
import 'package:conport/widgets/topbar.dart';

// ============================================================
// MOCK dos dados que ainda não existem no model Usuario / na API.
// Quando o backend expor esses campos, adicione-os ao Usuario
// e apague esta classe.
// ============================================================

class _PerfilMock {
  static const int seguindo = 12;
  static const int seguidores = 11;
  static final DateTime dataCadastro = DateTime(2025, 7, 6);
}

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

  @override
  void initState() {
    super.initState();
    Conquistas.instance.addListener(_conquistasMudaram);
    Conquistas.instance.carregar();
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

  Future<void> carregarUsuario() async {
    final dados = await widget.usuarioService.pegarDados(widget.usuarioId);

    if (!mounted) return;

    setState(() {
      usuario = dados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final u = usuario!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Topbar(
                hasLogo: false,
                hasReturn: true,
                showSettings: true,
                text: 'Perfil',
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
                        const Center(child: _Avatar()),

                        const SizedBox(height: 18),

                        // Nome e seguidores
                        Text(
                          u.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            _Contador(
                              valor: _PerfilMock.seguindo,
                              rotulo: 'Seguindo',
                            ),
                            SizedBox(width: 14),
                            _Contador(
                              valor: _PerfilMock.seguidores,
                              rotulo: 'Seguidores',
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'Entrou em ${_dataPorExtenso(_PerfilMock.dataCadastro)}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text(
                          'Em ${u.estado}',
                          style: const TextStyle(fontSize: 10),
                        ),

                        const SizedBox(height: 12),

                        // Adicionar amigos
                        _BotaoPilula(
                          icon: Symbols.group,
                          texto: 'Adicionar Amigos',
                          cor: appColors.accentSalmon,
                          onPressed: () {
                            PageLoader.go(context, PageLoader.friends);
                          },
                        ),

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
                        const Text(
                          'Conquistas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            for (final conquista in Conquistas.instance.todas)
                              _Conquista(
                                conquista: conquista,
                                desbloqueada: Conquistas.instance
                                    .estaDesbloqueada(conquista.tipo),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${Conquistas.instance.quantidadeDesbloqueadas} de '
                          '${Conquistas.instance.total} desbloqueadas',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

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

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    // TODO: trocar pela foto do usuário quando existir.
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return CircleAvatar(
      radius: 44,
      backgroundColor: appColors.accentSalmon,
      child: Icon(
        Symbols.person,
        size: 64,
        color: appColors.onAccent,
        weight: 600,
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  final int valor;
  final String rotulo;

  const _Contador({required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$valor',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        Text(rotulo, style: const TextStyle(fontSize: 7)),
      ],
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
