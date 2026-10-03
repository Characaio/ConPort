import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/config/app_config.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/services/auth_service.dart';
import 'package:conport/widgets/auth_ui.dart';
import 'package:conport/widgets/topbar.dart';

/// Cadastro: coleta tudo o que o `SignupDTO` do backend pede
/// (nome, data de nascimento, e-mail, senha, estado e cidade).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaController = TextEditingController();

  bool _carregando = false;
  String? _erroNome;
  String? _erroData;
  String? _erroEmail;
  String? _erroEstado;
  String? _erroCidade;
  String? _erroSenha;
  String? _erroConfirma;
  String? _erroGeral;

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _emailController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    _senhaController.dispose();
    _confirmaController.dispose();
    super.dispose();
  }

  bool get _temErroDeCampo =>
      _erroNome != null ||
      _erroData != null ||
      _erroEmail != null ||
      _erroEstado != null ||
      _erroCidade != null ||
      _erroSenha != null ||
      _erroConfirma != null;

  Future<void> _criarConta() async {
    String? erroData;
    DateTime? dataNasc;

    try {
      dataNasc = parseDataBrasileira(_dataController.text);
    } on FormatException catch (e) {
      erroData = e.message;
    }

    final senha = _senhaController.text;

    final erroNome = _nomeController.text.trim().length < 2
        ? 'Digite seu nome.'
        : null;
    final erroEmail = validarEmail(_emailController.text);
    final erroEstado = _estadoController.text.trim().isEmpty
        ? 'Digite o estado.'
        : null;
    final erroCidade = _cidadeController.text.trim().isEmpty
        ? 'Digite a cidade.'
        : null;
    final erroSenha = senha.length < 6
        ? 'A senha precisa de pelo menos 6 caracteres.'
        : null;
    final erroConfirma = senha != _confirmaController.text
        ? 'As senhas não conferem.'
        : null;

    setState(() {
      _erroNome = erroNome;
      _erroData = erroData;
      _erroEmail = erroEmail;
      _erroEstado = erroEstado;
      _erroCidade = erroCidade;
      _erroSenha = erroSenha;
      _erroConfirma = erroConfirma;
    });

    if (_temErroDeCampo || dataNasc == null) return;

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    ResultadoAutenticacao resultado;

    try {
      resultado = await _authService.cadastrar(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: senha,
        dataNasc: dataNasc,
        estado: _estadoController.text,
        cidade: _cidadeController.text,
      );
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

    final mensageiro = ScaffoldMessenger.of(context);

    PageLoader.replace(context, PageLoader.home);

    mensageiro.showSnackBar(
      SnackBar(
        content: Text('Conta criada. Bem-vindo, ${resultado.usuario.nome}!'),
      ),
    );
  }

  void _irParaEntrar() {
    final veioDoLogin =
        ModalRoute.of(context)?.settings.arguments == PageLoader.login;

    if (veioDoLogin && Navigator.canPop(context)) {
      // O login já está logo abaixo na pilha.
      PageLoader.back(context);
      return;
    }

    // Veio do intermediário (ou abriu direto por rota).
    PageLoader.replace(context, PageLoader.login);
  }

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
                    text: 'Criar conta',
                    showActions: false,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Junte-se ao ConPort',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Crie sua conta para registrar reports e completar missões.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CampoTexto(
                    rotulo: 'Nome de usuário',
                    controller: _nomeController,
                    hint: 'Como você quer ser chamado',
                    icone: Symbols.person,
                    erro: _erroNome,
                    teclado: TextInputType.name,
                    autofill: AutofillHints.name,
                    acao: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    rotulo: 'Data de nascimento',
                    controller: _dataController,
                    hint: 'DD/MM/AAAA',
                    icone: Symbols.calendar_month,
                    erro: _erroData,
                    teclado: TextInputType.datetime,
                    acao: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    rotulo: 'E-mail',
                    controller: _emailController,
                    hint: 'voce@email.com',
                    icone: Symbols.mail,
                    erro: _erroEmail,
                    teclado: TextInputType.emailAddress,
                    autofill: AutofillHints.email,
                    acao: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CampoTexto(
                          rotulo: 'Estado',
                          controller: _estadoController,
                          hint: 'SP',
                          erro: _erroEstado,
                          acao: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoTexto(
                          rotulo: 'Cidade',
                          controller: _cidadeController,
                          hint: 'Sua cidade',
                          erro: _erroCidade,
                          acao: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CampoSenha(
                    rotulo: 'Senha',
                    controller: _senhaController,
                    hint: 'Mínimo de 6 caracteres',
                    erro: _erroSenha,
                    acao: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  CampoSenha(
                    rotulo: 'Confirmar senha',
                    controller: _confirmaController,
                    hint: 'Digite a senha de novo',
                    erro: _erroConfirma,
                    acao: TextInputAction.done,
                    aoEnviar: (_) => _criarConta(),
                  ),
                  if (_erroGeral != null) ...[
                    const SizedBox(height: 14),
                    AvisoDeErro(mensagem: _erroGeral!),
                  ],
                  const SizedBox(height: 18),
                  BotaoAuth(
                    texto: 'Criar conta',
                    icone: Symbols.person_add,
                    corDeFundo: appColors.accentBrown,
                    carregando: _carregando,
                    onPressed: _criarConta,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem uma conta?',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: _irParaEntrar,
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!AppConfig.usarApi) ...[
                    const SizedBox(height: 4),
                    const Center(child: SeloModoDemo()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
