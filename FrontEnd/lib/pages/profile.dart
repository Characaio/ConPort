import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/services/usuarioService.dart';
/*
class ProfileData {
  final String username;
  final String estado;
  final String cidade;

  final int nivel;
  final int xp;
  final int missoesConcluidas;
  final int recompensas;

  final int reportsEnviados;
  final int reportsResolvidos;
  final int reportsRejeitados;
  final int reportsPendentes;

  ProfileData({
    required this.username,
    required this.estado,
    required this.cidade,

    required this.nivel,
    required this.xp,
    required this.missoesConcluidas,
    required this.recompensas,

    required this.reportsEnviados,
    required this.reportsResolvidos,
    required this.reportsRejeitados,
    required this.reportsPendentes,
  });
}

final ProfileData profileMock = ProfileData(
  username: "Jorge",
  estado: "Bahia",
  cidade: "Xique-Xique",
  nivel: 12,
  xp: 670,
  missoesConcluidas: 18,
  recompensas: 1,
  reportsEnviados: 5,
  reportsResolvidos: 3,
  reportsRejeitados: 1,
  reportsPendentes: 1,
);
*/

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.usuarioService,
    required this.usuarioId});
  
  final UsuarioService usuarioService;
  final int usuarioId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _ProfileState();

  Usuario? usuario;

  @override
  void initState(){
    super.initState();
    carregarUsuario();
  }

  Future<void> carregarUsuario() async {
    final dados = await widget.usuarioService.pegarDados(
      widget.usuarioId,
    );

    if (!mounted) return;

    setState(() {
      usuario = dados;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (usuario == null){
      return const Scaffold(
        body: Center(
          child:CircularProgressIndicator(),
        ),
      );
    }
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Topbar(hasLogo: false, hasReturn: true, text: 'Perfil'),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Perfil
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: colors.primaryContainer,
                            child: Icon(
                              Symbols.person,
                              size: 48,
                              color: colors.onPrimaryContainer,
                              fill: 1,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario!.nome,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${usuario!.estado} • ${usuario!.cidade}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Estatísticas
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Estatísticas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),

                      const SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.8,
                        children: [
                          _Stat('Nível', usuario!.level.toString()),
                          _Stat('XP', usuario!.xp.toString()),
                          _Stat(
                            'Missões concluídas',
                            usuario!.missoesConcluidas.toString(),
                          ),
                          _Stat('Recompensas', usuario!.moedas.toString()),
                          _Stat(
                            'Reports enviados',
                            usuario!.reportsEnviados.toString(),
                          ),
                          _Stat(
                            'Reports resolvidos',
                            usuario!.reportsResolvidos.toString(),
                          ),
                          _Stat(
                            'Reports rejeitados',
                            usuario!.reportsRejeitados.toString(),
                          ),
                          _Stat(
                            'Reports pendentes',
                            usuario!.reportsPendentes.toString(),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          PageLoader.go(context, PageLoader.myreports);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.surface,
                          elevation: 5,
                          padding: const EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Symbols.list, size: 28.0),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Ver meus reports",
                                  style: const TextStyle(fontSize: 16.0),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;

  const _Stat(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
