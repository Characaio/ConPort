import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/settings/app_settings.dart';
import 'package:conport/widgets/topbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    settings.addListener(_settingsChanged);
  }

  @override
  void dispose() {
    settings.removeListener(_settingsChanged);
    super.dispose();
  }

  void _settingsChanged() {
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
                        _SettingsSection(
                          icon: Icons.palette_outlined,
                          title: 'Tema',
                          subtitle: 'Cores e estilo do aplicativo',
                          children: [
                            _ThemeSelector(
                              value: settings.themeMode,
                              onChanged: settings.setThemeMode,
                            ),
                            const SizedBox(height: 12),
                            _SettingsSwitch(
                              title: 'Usar Material 3',
                              subtitle:
                                  'Ativa os componentes mais recentes do Material.',
                              value: settings.useMaterial3,
                              onChanged: settings.setUseMaterial3,
                            ),
                          ],
                        ),
                        _SettingsSection(
                          icon: Icons.text_fields,
                          title: 'Tamanho de fonte',
                          subtitle: 'Ajuste o tamanho dos textos na tela',
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pequena',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  '${(settings.fontScale * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Text(
                                  'Grande',
                                  style: TextStyle(fontSize: 14),
                                ),
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
                          ],
                        ),
                        _SettingsSection(
                          icon: Icons.visibility_outlined,
                          title: 'Aparência',
                          subtitle: 'Preferências de leitura e animação',
                          children: [
                            _SettingsSwitch(
                              title: 'Alto contraste',
                              subtitle:
                                  'Aumenta a diferença entre textos e fundos.',
                              value: settings.highContrast,
                              onChanged: settings.setHighContrast,
                            ),
                            _SettingsSwitch(
                              title: 'Reduzir animações',
                              subtitle:
                                  'Diminui movimentos e transições da interface.',
                              value: settings.reduceMotion,
                              onChanged: settings.setReduceMotion,
                            ),
                          ],
                        ),
                        _SettingsSection(
                          icon: Icons.manage_accounts_outlined,
                          title: 'Ações da conta',
                          subtitle: 'Ações disponíveis para sua conta',
                          children: [
                            _ActionButton(
                              icon: Icons.person_outline,
                              label: 'Editar perfil',
                              onPressed: () {
                                PageLoader.go(context, PageLoader.profile);
                              },
                            ),
                            SizedBox(height: 16),
                            _ActionButton(
                              icon: Icons.logout,
                              label: 'Sair da conta',
                              onPressed: () =>
                                  _showMessage('Logout disponível em breve.'),
                            ),
                            SizedBox(height: 16),
                            _ActionButton(
                              icon: Icons.delete_outline,
                              label: 'Excluir conta',
                              destructive: true,
                              onPressed: _confirmAccountDeletion,
                            ),
                          ],
                        ),
                        _SettingsSection(
                          icon: Icons.notifications_none,
                          title: 'Notificações',
                          subtitle: 'Escolha como deseja receber novidades',
                          children: [
                            _SettingsSwitch(
                              title: 'Notificações no aplicativo',
                              subtitle:
                                  'Alertas sobre missões, reports e novidades.',
                              value: settings.pushNotifications,
                              onChanged: settings.setPushNotifications,
                            ),
                            _SettingsSwitch(
                              title: 'Notificações por e-mail',
                              subtitle: 'Receba um resumo ocasional por e-mail.',
                              value: settings.emailNotifications,
                              onChanged: settings.setEmailNotifications,
                            ),
                          ],
                        ),
                        _SettingsSection(
                          icon: Icons.person_outline,
                          title: 'Perfil',
                          subtitle: 'Controle como outras pessoas encontram você',
                          children: [
                            _SettingsSwitch(
                              title: 'Perfil público',
                              subtitle:
                                  'Permite que outros usuários vejam seu perfil.',
                              value: settings.profilePublic,
                              onChanged: settings.setProfilePublic,
                            ),
                            _SettingsSwitch(
                              title: 'Permitir solicitações de amizade',
                              subtitle:
                                  'Outros usuários poderão enviar convites.',
                              value: settings.allowFriendRequests,
                              onChanged: settings.setAllowFriendRequests,
                            ),
                          ],
                        ),
                        _SettingsSection(
                          icon: Icons.lock_outline,
                          title: 'Privacidade',
                          subtitle: 'Controle o uso de seus dados',
                          children: [
                            _SettingsSwitch(
                              title: 'Compartilhar localização',
                              subtitle:
                                  'Usa sua localização em recursos compatíveis.',
                              value: settings.shareLocation,
                              onChanged: settings.setShareLocation,
                            ),
                            _SettingsSwitch(
                              title: 'Dados de uso anônimos',
                              subtitle:
                                  'Ajuda a melhorar o aplicativo sem identificar você.',
                              value: settings.analytics,
                              onChanged: settings.setAnalytics,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _LegalLinks(onMessage: _showMessage),
                        const SizedBox(height: 10),
                        Text(
                          'ConPort • configurações desta sessão',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmAccountDeletion() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: const Text(
          'Esta ação será conectada ao backend posteriormente. Nenhum dado será excluído agora.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      _showMessage('Exclusão de conta disponível em breve.');
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
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

class _ThemeSelector extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeChoice(
            label: 'Claro',
            icon: Icons.light_mode_outlined,
            selected: value == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeChoice(
            label: 'Escuro',
            icon: Icons.dark_mode_outlined,
            selected: value == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeChoice(
            label: 'Sistema',
            icon: Icons.settings_suggest_outlined,
            selected: value == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.16)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selected ? colors.primary : null),
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

class _LegalLinks extends StatelessWidget {
  final ValueChanged<String> onMessage;

  const _LegalLinks({required this.onMessage});

  static final _repositoryUri = Uri.parse(
    'https://github.com/characaio/conport',
  );

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
          onPressed: () => _openRepository(onMessage),
          icon: const Icon(Icons.description_outlined, size: 16),
          label: const Text('Termos de uso', style: TextStyle(fontSize: 10)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openRepository(onMessage),
          icon: const Icon(Icons.policy_outlined, size: 16),
          label: const Text(
            'Política de privacidade',
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Future<void> _openRepository(ValueChanged<String> onMessage) async {
    final opened = await launchUrl(
      _repositoryUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      onMessage('Não foi possível abrir o navegador.');
    }
  }
}
