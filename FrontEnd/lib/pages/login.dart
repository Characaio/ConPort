import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/mocks/auth_mock.dart';
import 'package:conport/services/auth_service.dart';
import 'package:conport/widgets/auth_ui.dart';
import 'package:conport/widgets/topbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _carregando = false;
  String? _erroEmail;
  String? _erroSenha;
  String? _erroGeral;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _preencherDemo() {
    setState(() {
      _emailController.text = AuthMock.emailDemo;
      _senhaController.text = AuthMock.senhaDemo;
      _erroEmail = null;
      _erroSenha = null;
      _erroGeral = null;
    });
  }

  Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    final erroEmail = validarEmail(email);
    final erroSenha = senha.isEmpty ? 'Digite sua senha.' : null;

    if (erroEmail != null || erroSenha != null) {
      setState(() {
        _erroEmail = erroEmail;
        _erroSenha = erroSenha;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    ResultadoAutenticacao resultado;

    try {
      resultado = await _authService.entrar(email: email, senha: senha);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erroGeral = e.mensagem;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erroGeral = 'Não foi possível conectar. Tente novamente.';
      });
      return;
    }

    if (!mounted) return;

    AuthSession.instance.entrar(resultado.usuario, token: resultado.token);

    // Pega o mensageiro antes de navegar: ele fica acima do Navigator e a
    // mensagem sobrevive à troca de rota.
    final mensageiro = ScaffoldMessenger.of(context);

    PageLoader.replace(context, PageLoader.home);

    mensageiro.showSnackBar(
      SnackBar(content: Text('Bem-vindo de volta, ${resultado.usuario.nome}!')),
    );
  }

  void _irParaCadastro() =>
      // O argumento diz ao cadastro de onde ele veio, para o link
      // "Já tem uma conta?" voltar para cá quando necessário.
      Navigator.pushNamed(context, PageLoader.register, arguments: PageLoader.login);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Topbar(
                    hasLogo: false,
                    hasReturn: true,
                    text: 'Entrar',
                    showActions: false,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Entre para continuar sua trilha pelo ConPort.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!AppConfig.usarApi) ...[
                    _DicaDemo(onPreencher: _preencherDemo),
                    const SizedBox(height: 16),
                  ],
                  CampoTexto(
                    rotulo: 'E-mail',
                    controller: _emailController,
                    hint: 'voce@email.com',
                    icone: Symbols.mail,
                    erro: _erroEmail,
                    teclado: TextInputType.emailAddress,
                    autofill: AutofillHints.email,
                    acao: TextInputAction.next,
                    aoEnviar: (_) => _entrar(),
                  ),
                  const SizedBox(height: 14),
                  CampoSenha(
                    rotulo: 'Senha',
                    controller: _senhaController,
                    hint: 'Sua senha',
                    erro: _erroSenha,
                    acao: TextInputAction.done,
                    aoEnviar: (_) => _entrar(),
                  ),
                  if (_erroGeral != null) ...[
                    const SizedBox(height: 14),
                    AvisoDeErro(mensagem: _erroGeral!),
                  ],
                  const SizedBox(height: 18),
                  BotaoAuth(
                    texto: 'Entrar',
                    icone: Symbols.login,
                    corDeFundo: appColors.accentGreen,
                    carregando: _carregando,
                    onPressed: _entrar,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _irParaCadastro,
                      icon: const Icon(Symbols.person_add, size: 16),
                      label: const Text(
                        'Criar conta',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(
                          color: colors.primary.withValues(alpha: 0.6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão com a conta de demonstração (apenas no modo mockado).
class _DicaDemo extends StatelessWidget {
  final VoidCallback onPreencher;

  const _DicaDemo({required this.onPreencher});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.lightbulb, size: 16, color: colors.onPrimaryContainer),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Conta de demonstração',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${AuthMock.emailDemo} • senha ${AuthMock.senhaDemo}',
            style: TextStyle(
              fontSize: 11,
              color: colors.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onPreencher,
              child: const Text('Preencher conta demo', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
