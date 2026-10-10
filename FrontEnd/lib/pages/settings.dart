import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/notificacoes/notificacao_controller.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/settings/app_settings.dart';
import 'package:conport/core/settings/preferencias_conta.dart';
import 'package:conport/models/preferencias.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/services/usuarioService.dart';
import 'package:conport/widgets/topbar.dart';

/// Menu de configurações.
///
/// Duas famílias de opção, e a diferença é deliberada: o que pertence à
/// **tela** ([AppSettings]) é salvo no aparelho, e o que pertence à **conta**
/// ([PreferenciasConta]) vai para o banco. Por isso só o segundo grupo mostra
/// o botão de "salvando" e pode voltar atrás sozinho se o servidor recusar.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final settings = AppSettings.instance;
  final conta = PreferenciasConta.instance;
  final usuarioService = const UsuarioService();

  @override
  void initState() {
    super.initState();

    settings.addListener(_mudou);
    conta.addListener(_mudou);

    // Só busca se ainda não tem o que mostrar: voltar para as configurações
    // não deve custar uma chamada à rede a cada visita.
    if (conta.atual == null && AuthSession.instance.temSessao) {
      conta.carregar();
    }
  }

  @override
  void dispose() {
    settings.removeListener(_mudou);
    conta.removeListener(_mudou);
    super.dispose();
  }

  void _mudou() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Topbar(
                hasLogo: false,
                hasReturn: true,
                text: 'Configurações',
                showActions: false,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        _aparencia(),
                        const SizedBox(height: 12),
                        _mapa(),
                        const SizedBox(height: 12),
                        _notificacoes(),
                        const SizedBox(height: 12),
                        _privacidade(),
                        const SizedBox(height: 12),
                        _contaUi(),
                        const SizedBox(height: 12),
                        _sobre(),
                        const SizedBox(height: 8),
                        _LegalLinks(onMessage: _showMessage),
                        const SizedBox(height: 10),
                        Text(
                          'ConPort ${_versao()}',
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.55),
                            fontSize: 9,
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
      ),
    );
  }

  // ============================================================
  // SEÇÕES
  // ============================================================

  Widget _aparencia() => _SettingsSection(
    icon: Icons.palette_outlined,
    title: 'Aparência',
    subtitle: 'Cores, texto e movimento — salvo neste aparelho',
    initiallyExpanded: true,
    children: [
      _SettingsSwitch(
        title: 'Seguir tema do sistema',
        subtitle: 'Usa claro ou escuro automático do aparelho.',
        value: settings.seguirTemaSistema,
        onChanged: settings.setSeguirTemaSistema,
      ),
      if (!settings.seguirTemaSistema)
        _ThemeSelector(
          value: settings.themeMode,
          onChanged: settings.setThemeMode,
        ),
      if (!settings.seguirTemaSistema) const SizedBox(height: 12),
      _SettingsSwitch(
        title: 'Usar Material 3',
        subtitle: 'Ativa os componentes mais recentes do Material.',
        value: settings.useMaterial3,
        onChanged: settings.setUseMaterial3,
      ),
      _SettingsSwitch(
        title: 'Alto contraste',
        subtitle: 'Aumenta a diferença entre textos e fundos.',
        value: settings.highContrast,
        onChanged: settings.setHighContrast,
      ),
      _SettingsSwitch(
        title: 'Reduzir animações',
        subtitle: 'Troca de página e abre gaveta sem deslizar.',
        value: settings.reduceMotion,
        onChanged: settings.setReduceMotion,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Pequena', style: TextStyle(fontSize: 10)),
          Text(
            '${(settings.fontScale * 100).round()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const Text('Grande', style: TextStyle(fontSize: 14)),
        ],
      ),
      Slider(
        value: settings.fontScale,
        min: 0.85,
        max: 1.3,
        divisions: 9,
        label: '${(settings.fontScale * 100).round()}%',
        onChanged: settings.setFontScale,
      ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (final (label, escala) in AppSettings.tamanhosFonte)
            _FontSizePreset(
              label: label,
              escala: escala,
              selecionado: settings.fontScale == escala,
              onSelect: () => settings.setFontScale(escala),
            ),
        ],
      ),
    ],
  );

  Widget _mapa() => _SettingsSection(
    icon: Icons.map_outlined,
    title: 'Mapa',
    subtitle: 'Como as distâncias e o fundo do mapa aparecem',
    children: [
      const _Subtitulo('Unidade de distância'),
      _OpcoesEscolha<UnidadeDistancia>(
        rotulos: [for (final u in UnidadeDistancia.values) u.rotulo],
        selecionado: settings.unidadeDistancia,
        indiceDe: (u) => u == UnidadeDistancia.quilometros ? 0 : 1,
        aoTocar: (i) =>
            settings.setUnidadeDistancia(UnidadeDistancia.values[i]),
      ),
      const SizedBox(height: 4),
      Text(
        settings.unidadeDistancia.descricao,
        style: const TextStyle(fontSize: 9),
      ),
      const SizedBox(height: 16),
      const _Subtitulo('Estilo do mapa'),
      for (final estilo in EstiloMapa.values)
        _EscolhaUnica(
          titulo: estilo.rotulo,
          descricao: estilo.descricao,
          selecionado: estilo == settings.estiloMapa,
          onTap: () => settings.setEstiloMapa(estilo),
        ),
    ],
  );

  Widget _notificacoes() => _SettingsSection(
    icon: Icons.notifications_none,
    title: 'Notificações',
    subtitle: 'Salvo na conta — vale em qualquer aparelho',
    children: [
      _Preferencia(
        chave: PreferenciasChave.notificarNoApp,
        prefs: conta,
        titulo: 'Notificações no aplicativo',
        descricao: 'Alertas no sino sobre missões, reports e conquistas.',
      ),
      _SettingsSwitch(
        title: 'Notificações push',
        subtitle:
            'Push via FCM ainda não está configurado — o toggle salva a '
            'preferência e servirá quando o serviço de push for adicionado.',
        value: settings.notificarPush,
        onChanged: settings.setNotificarPush,
      ),
      _Preferencia(
        chave: PreferenciasChave.notificarEmail,
        prefs: conta,
        titulo: 'Notificações por e-mail',
        descricao:
            'A preferência fica gravada e o app respeita, mas nenhum e-mail '
            'é enviado ainda: não há serviço de e-mail ligado ao servidor.',
      ),
      if (conta.erro != null) _AvisoErro(conta.erro!),
    ],
  );

  Widget _privacidade() => _SettingsSection(
    icon: Icons.lock_outline,
    title: 'Privacidade',
    subtitle: 'Quem te vê e o que é usado',
    children: [
      _Preferencia(
        chave: PreferenciasChave.perfilPublico,
        prefs: conta,
        titulo: 'Perfil público',
        descricao:
            'Desligado, outras pessoas não veem seu e-mail, cidade nem '
            'data de nascimento.',
      ),
      _Preferencia(
        chave: PreferenciasChave.permiteSolicitacoes,
        prefs: conta,
        titulo: 'Permitir solicitações de amizade',
        descricao: 'Desligado, ninguém consegue te mandar um convite.',
      ),
      _Preferencia(
        chave: PreferenciasChave.compartilharLocalizacao,
        prefs: conta,
        titulo: 'Compartilhar localização',
        descricao: 'Desligado, o mapa não pede o GPS sozinho ao abrir.',
      ),
      _Preferencia(
        chave: PreferenciasChave.dadosDeUsoAnonimo,
        prefs: conta,
        titulo: 'Dados de uso anônimos',
        descricao: 'Ajuda a melhorar o aplicativo sem identificar você.',
      ),
      const SizedBox(height: 12),
      const Divider(height: 1),
      const SizedBox(height: 12),
      _VisibilidadeSeguidores(usuarioService: usuarioService),
    ],
  );

  Widget _contaUi() => _SettingsSection(
    icon: Icons.manage_accounts_outlined,
    title: 'Conta',
    subtitle: 'Ações disponíveis para a sua conta',
    children: [
      _ActionButton(
        icon: Icons.person_outline,
        label: 'Editar perfil',
        onPressed: () => PageLoader.go(context, PageLoader.editarPerfil),
      ),
      const SizedBox(height: 16),
      _ActionButton(
        icon: Icons.logout,
        label: 'Sair da conta',
        onPressed: _sairDaConta,
      ),
      const SizedBox(height: 16),
      _ActionButton(
        icon: Icons.phonelink_erase,
        label: 'Sair de todos os lugares',
        onPressed: _sairDeTodosOsLugares,
      ),
      const SizedBox(height: 16),
      _ActionButton(
        icon: Icons.delete_outline,
        label: 'Excluir conta',
        destructive: true,
        onPressed: _confirmAccountDeletion,
      ),
    ],
  );

  // ============================================================
  // AÇÕES
  // ============================================================

  static final _repositorio = Uri.parse('https://github.com/characaio/conport');

  /// Versão vinda do `pubspec.yaml` pelo nome do pacote: evita o número
  /// estar escrito em dois lugares e divergir na próxima release.
  String _versao() {
    const version = String.fromEnvironment(
      'conport.versao',
      defaultValue: '1.0.0+1',
    );

    return version;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _abrir(Uri uri, ValueChanged<String> onMessage) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) onMessage('Não foi possível abrir o navegador.');
  }

  Future<void> _sairDaConta() async {
    // Revoga o token no servidor e limpa o cofre do aparelho. Mesmo sem rede a
    // saída acontece: a pessoa pediu para sair, não para rezar pelo 500.
    await AuthSession.instance.sairDaConta();

    // Lista de notificações e preferências ficam em memória: sem limpar aqui, a
    // conta que entrar depois veria o que é da conta que saiu.
    NotificacaoController.instance.limpar();
    conta.limpar();

    // Mostra a mensagem antes de navegar: o mensageiro fica acima do
    // Navigator e o aviso sobrevive à troca de rota.
    _showMessage('Você saiu da sua conta.');

    PageLoader.replace(context, PageLoader.welcome);
  }

  Future<void> _sairDeTodosOsLugares() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair de todos os lugares?'),
        content: const Text(
          'A conta sai deste aparelho e de qualquer outro onde ela estiver '
          'aberta. Será preciso entrar de novo em todos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair de todos'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await AuthSession.instance.sairDeTodosOsLugares();

    NotificacaoController.instance.limpar();
    conta.limpar();

    _showMessage('Sessões encerradas em todos os aparelhos.');

    PageLoader.replace(context, PageLoader.welcome);
  }

  Widget _sobre() => _SettingsSection(
    icon: Icons.info_outline,
    title: 'Sobre',
    subtitle: 'Versão, seus dados e o botão de arrependimento',
    children: [
      _InfoItem(
        icon: Icons.info_outline,
        titulo: 'Versão do aplicativo',
        valor: _versao(),
      ),
      _InfoItem(
        icon: Icons.code,
        titulo: 'Código-fonte',
        valor: 'Licença e código no GitHub',
        onTap: () => _abrir(_repositorio, _showMessage),
      ),
      const SizedBox(height: 16),
      _ActionButton(
        icon: Icons.file_download_outlined,
        label: 'Exportar meus dados',
        onPressed: _exportarDados,
      ),
      const SizedBox(height: 16),
      _ActionButton(
        icon: Icons.restart_alt,
        label: 'Restaurar configurações padrão',
        onPressed: _confirmarRestaurarPadroes,
      ),
    ],
  );

  /// Apaga a conta — de verdade, com a senha confirmada.
  ///
  /// A senha não é decoração: o servidor recusa com 401 e a pessoa continua
  /// dentro da conta. É o que impede que um aparelho emprestado, com a sessão
  /// ainda aberta, apague a conta de quem o deixou aberto.
  Future<void> _confirmAccountDeletion() async {
    final senha = await showDialog<String>(
      context: context,
      builder: (context) => _DialogoSenha(
        titulo: 'Excluir conta',
        texto:
            'Isto apaga a conta, seus reports, missões, conquistas e '
            'notificações. Não dá para desfazer.',
        textoBotao: 'Excluir definitivamente',
      ),
    );

    // Cancelar devolve `null`; uma senha vazia também não deve chegar ao
    // servidor como pedido de exclusão.
    if (senha == null || senha.isEmpty || !mounted) return;

    try {
      await usuarioService.excluirConta(senha);
    } catch (e) {
      if (!mounted) return;

      // A senha errada volta com a mensagem do servidor, que é o que a pessoa
      // precisa saber para tentar de novo.
      _showMessage('$e');

      return;
    }

    // Só desloga depois do 200: até lá a conta existe e a sessão vale.
    await AuthSession.instance.sairDaConta();
    NotificacaoController.instance.limpar();
    conta.limpar();

    if (!mounted) return;

    _showMessage('Sua conta foi excluída.');
    PageLoader.replace(context, PageLoader.welcome);
  }

  /// Monta o retrato dos dados e oferece para copiar.
  ///
  /// Não grava arquivo no aparelho: sem `share_plus`/`path_provider` não há
  /// para onde mandar, e fingir que exportou seria pior do que mostrar o
  /// conteúdo para a pessoa copiar.
  Future<void> _exportarDados() async {
    _showMessage('Juntando seus dados...');

    String texto;

    try {
      final dados = await usuarioService.exportarDados();
      texto = const JsonEncoder.withIndent('  ').convert(dados);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Não foi possível exportar agora.');
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seus dados'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              texto,
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: texto));

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Copiar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarRestaurarPadroes() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar padrões?'),
        content: const Text(
          'Volta tema, tamanho da fonte, alto contraste, animações, mapa e '
          'unidade de distância para o que vem de fábrica. Suas preferências '
          'de conta e o conteúdo dela não mudam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await settings.restaurarPadroes();

    if (mounted) _showMessage('Configurações restauradas.');
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // "Aparência" vem aberta: é o que a pessoa procura primeiro, e as
          // outras sete seções fechadas continuam deixando a página curta.
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(icon, size: 22),
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 9)),
          children: children,
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 11)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 9)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _Subtitulo extends StatelessWidget {
  final String texto;

  const _Subtitulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 2),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

class _AvisoErro extends StatelessWidget {
  final String mensagem;

  const _AvisoErro(this.mensagem);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      mensagem,
      style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.error),
    ),
  );
}

/// Um interruptor de preferência de **conta**.
///
/// Fica escondendo nada: enquanto as preferências não chegam do servidor não há
/// botão nenhum, porque mostrar o padrão e trocar na frente da pessoa seria
/// pior que esperar.
class _Preferencia extends StatelessWidget {
  final PreferenciasChave chave;
  final PreferenciasConta prefs;
  final String titulo;
  final String descricao;

  const _Preferencia({
    required this.chave,
    required this.prefs,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final atual = prefs.atual;

    if (atual == null) return const SizedBox.shrink();

    return Stack(
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(titulo, style: const TextStyle(fontSize: 11)),
          subtitle: Text(descricao, style: const TextStyle(fontSize: 9)),
          value: atual.valorDe(chave),
          onChanged: prefs.salvando ? null : (v) => prefs.definir(chave, v),
        ),
        // Fica sobre o interruptor para travar o toque enquanto grava, sem
        // desabilitar o widget inteiro (que escureceria o texto da seção).
        if (prefs.salvando)
          const Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Opções em duas ou três caixas lado a lado (usado para a unidade de
/// distância, que tem só duas escolhas).
class _OpcoesEscolha<T> extends StatelessWidget {
  final List<String> rotulos;
  final T selecionado;
  final int Function(T) indiceDe;
  final ValueChanged<int> aoTocar;

  const _OpcoesEscolha({
    required this.rotulos,
    required this.selecionado,
    required this.indiceDe,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < rotulos.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _CaixaEscolha(
              label: rotulos[i],
              selecionado: indiceDe(selecionado) == i,
              onTap: () => aoTocar(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _CaixaEscolha extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _CaixaEscolha({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: AppSettings.instance.duracao(
          const Duration(milliseconds: 180),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selecionado
              ? colors.primary.withValues(alpha: 0.16)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? colors.primary : colors.outlineVariant,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}

/// Uma opção que ocupa a linha inteira, com título e descrição.
class _EscolhaUnica extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool selecionado;
  final VoidCallback onTap;

  const _EscolhaUnica({
    required this.titulo,
    required this.descricao,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selecionado ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selecionado ? colors.primary : colors.outline,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 11)),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 9,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 18),
      title: Text(titulo, style: const TextStyle(fontSize: 11)),
      subtitle: Text(
        valor,
        style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
      ),
      trailing: onTap == null
          ? null
          : Icon(Icons.chevron_right, size: 16, color: colors.outline),
      onTap: onTap,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CaixaComIcone(
            label: 'Claro',
            icon: Icons.light_mode_outlined,
            selecionado: value == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CaixaComIcone(
            label: 'Escuro',
            icon: Icons.dark_mode_outlined,
            selecionado: value == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ),
      ],
    );
  }
}

class _CaixaComIcone extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selecionado;
  final VoidCallback onTap;

  const _CaixaComIcone({
    required this.label,
    required this.icon,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: AppSettings.instance.duracao(
          const Duration(milliseconds: 180),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selecionado
              ? colors.primary.withValues(alpha: 0.16)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? colors.primary : colors.outlineVariant,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selecionado ? colors.primary : null),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = destructive ? colors.error : colors.primary;

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 10)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.65)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

/// Botão rápido de tamanho de fonte predefinido.
///
/// Fica abaixo do slider: o slider continua para ajustes finos, os botões dão
/// acesso a tamanhos que cabem num texto só.
class _FontSizePreset extends StatelessWidget {
  final String label;
  final double escala;
  final bool selecionado;
  final VoidCallback onSelect;

  const _FontSizePreset({
    required this.label,
    required this.escala,
    required this.selecionado,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      selected: selecionado,
      onSelected: (_) => onSelect(),
      visualDensity: VisualDensity.compact,
      labelStyle: TextStyle(
        color: selecionado ? colors.onPrimary : colors.onSurfaceVariant,
      ),
    );
  }
}

/// Pede a senha e devolve o que a pessoa digitou.
///
/// `null` = cancelou. O botão de confirmar começa desligado e só liga com
/// algo digitado: assim "Excluir conta" nunca é alcançado por engano com o
/// campo vazio.
class _DialogoSenha extends StatefulWidget {
  final String titulo;
  final String texto;
  final String textoBotao;

  const _DialogoSenha({
    required this.titulo,
    required this.texto,
    required this.textoBotao,
  });

  @override
  State<_DialogoSenha> createState() => _DialogoSenhaState();
}

class _DialogoSenhaState extends State<_DialogoSenha> {
  final _controller = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.texto, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            enabled: !_enviando,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _confirmar(),
            decoration: const InputDecoration(
              labelText: 'Sua senha',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando || _controller.text.isEmpty ? null : _confirmar,
          child: Text(widget.textoBotao),
        ),
      ],
    );
  }

  void _confirmar() {
    setState(() => _enviando = true);
    Navigator.pop(context, _controller.text);
  }
}

class _LegalLinks extends StatelessWidget {
  final ValueChanged<String> onMessage;

  const _LegalLinks({required this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Informações legais',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _abrirRepositorio(onMessage),
          icon: const Icon(Icons.description_outlined, size: 16),
          label: const Text('Termos de uso', style: TextStyle(fontSize: 10)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _abrirRepositorio(onMessage),
          icon: const Icon(Icons.policy_outlined, size: 16),
          label: const Text(
            'Política de privacidade',
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Future<void> _abrirRepositorio(ValueChanged<String> onMessage) async {
    final opened = await launchUrl(
      Uri.parse('https://github.com/characaio/conport'),
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      onMessage('Não foi possível abrir o navegador.');
    }
  }
}

/// Quem pode abrir as listas de seguidores e de quem a pessoa segue.
///
/// Vai para o banco, e não para o [AppSettings], pelo mesmo motivo das outras
/// preferências de conta: escolher quem te vê é algo que a pessoa espera que
/// continue valendo em outro aparelho.
class _VisibilidadeSeguidores extends StatefulWidget {
  final UsuarioService usuarioService;

  const _VisibilidadeSeguidores({required this.usuarioService});

  @override
  State<_VisibilidadeSeguidores> createState() =>
      _VisibilidadeSeguidoresState();
}

class _VisibilidadeSeguidoresState extends State<_VisibilidadeSeguidores> {
  VisibilidadeSeguidores _atual = VisibilidadeSeguidores.publico;
  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  int? get _usuarioId => AuthSession.instance.usuario?.id;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final id = _usuarioId;

    // Sem conta não há lista para proteger: o botão some em vez de fingir
    // que salvou alguma coisa.
    if (id == null) {
      setState(() => _carregando = false);
      return;
    }

    try {
      final usuario = await widget.usuarioService.pegarDados(id);

      if (!mounted) return;

      setState(() {
        _atual = usuario.visibilidade;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  Future<void> _trocar(VisibilidadeSeguidores nova) async {
    final id = _usuarioId;

    if (id == null || nova == _atual || _salvando) return;

    final anterior = _atual;

    // A opção muda na hora; se o servidor recusar, volta.
    setState(() {
      _atual = nova;
      _salvando = true;
      _erro = null;
    });

    try {
      final salvo = await widget.usuarioService.atualizarVisibilidade(nova);

      if (!mounted) return;

      setState(() {
        _atual = salvo;
        _salvando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _atual = anterior;
        _salvando = false;
        _erro = 'Não foi possível salvar essa preferência.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_carregando || _usuarioId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Quem pode ver suas listas',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            if (_salvando)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Aplica-se a "quem sigo" e "quem me segue".',
          style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        for (final nivel in VisibilidadeSeguidores.values)
          RadioListTile<VisibilidadeSeguidores>(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: nivel,
            // ignore: deprecated_member_use
            groupValue: _atual,
            // ignore: deprecated_member_use
            onChanged: _salvando
                ? null
                : (v) {
                    if (v != null) _trocar(v);
                  },
            title: Text(nivel.rotulo, style: const TextStyle(fontSize: 11)),
            subtitle: Text(
              nivel.descricao,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        if (_erro != null) _AvisoErro(_erro!),
      ],
    );
  }
}
