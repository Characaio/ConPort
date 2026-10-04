import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/session/auth_session.dart';
import 'package:conport/core/theme/app_theme.dart';
import 'package:conport/models/usuario.dart';
import 'package:conport/services/usuarioService.dart';
import 'package:conport/widgets/auth_ui.dart';
import 'package:conport/widgets/topbar.dart';

/// Edição do perfil: foto, dados e senha.
///
/// Só entra no que o `PUT /usuarios/{id}` aceita. Campos que a pessoa não
/// mexeu não vão no corpo, então o backend mantém o valor antigo.
class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({
    super.key,
    required this.usuarioId,
    required this.usuarioService,
  });

  final int usuarioId;
  final UsuarioService usuarioService;

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();

  Usuario? _usuario;
  XFile? _fotoEscolhida;
  Uint8List? _bytesDaFoto;

  bool _carregando = true;
  bool _falhaAoCarregar = false;
  bool _salvando = false;
  bool _salvandoFoto = false;

  String? _erroNome;
  String? _erroUsername;
  String? _erroEmail;
  String? _erroData;
  String? _erroCidade;
  String? _erroEstado;
  String? _erroSenha;
  String? _erroSenhaAtual;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _dataController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _senhaController.dispose();
    _senhaAtualController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _falhaAoCarregar = false;
    });

    try {
      final usuario = await widget.usuarioService.pegarDados(
        widget.usuarioId,
      );

      if (!mounted) return;

      setState(() {
        _preencher(usuario);
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _falhaAoCarregar = true;
      });
    }
  }

  void _preencher(Usuario usuario) {
    _nomeController.text = usuario.nome;
    _usernameController.text = usuario.username ?? '';
    _emailController.text = usuario.email;
    _dataController.text = _dataPorExtenso(usuario.datanasc);
    _cidadeController.text = usuario.cidade;
    _estadoController.text = usuario.estado;
    _usuario = usuario;
  }

  bool get _temErroDeCampo =>
      _erroNome != null ||
      _erroUsername != null ||
      _erroEmail != null ||
      _erroData != null ||
      _erroCidade != null ||
      _erroEstado != null ||
      _erroSenha != null ||
      _erroSenhaAtual != null;

  // ============================================================
  // FOTO
  // ============================================================

  Future<void> _escolherFoto() async {
    final origem = await _menuDeOrigem();

    if (origem == null || !mounted) return;

    try {
      final foto = await ImagePicker().pickImage(
        source: origem,
        // Avatar é redondo e pequeno: 512 já sobra e não trava o envio.
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (foto == null) return;

      final bytes = await foto.readAsBytes();

      if (!mounted) return;

      setState(() {
        _fotoEscolhida = foto;
        _bytesDaFoto = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível acessar a imagem.');
    }
  }

  Future<ImageSource?> _menuDeOrigem() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Symbols.photo_camera),
              title: const Text('Tirar uma foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarFoto() async {
    final bytes = _bytesDaFoto;
    final foto = _fotoEscolhida;

    if (bytes == null || foto == null) return;

    setState(() {
      _salvandoFoto = true;
      _erroGeral = null;
    });

    try {
      await widget.usuarioService.atualizarAvatar(
        widget.usuarioId,
        bytes: bytes,
        nome: foto.name,
      );

      // Recarrega para o nome do arquivo vir do servidor: é ele que vira a
      // URL da foto, e um nome local não apareceria na imagem.
      final atualizado = await widget.usuarioService.pegarDados(
        widget.usuarioId,
      );

      if (!mounted) return;

      AuthSession.instance.entrar(atualizado, token: AuthSession.instance.token);

      setState(() {
        _usuario = atualizado;
        _fotoEscolhida = null;
        _bytesDaFoto = null;
        _salvandoFoto = false;
      });

      _mostrarMensagem('Foto atualizada.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvandoFoto = false;
        _erroGeral = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _confirmarRemoverFoto() async {
    final remover = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto?'),
        content: const Text(
          'Seu perfil volta a mostrar a silhueta padrão. Você pode escolher '
          'uma foto de novo depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (remover != true) return;

    setState(() {
      _salvandoFoto = true;
      _erroGeral = null;
    });

    try {
      await widget.usuarioService.removerAvatar(widget.usuarioId);

      final atualizado = await widget.usuarioService.pegarDados(
        widget.usuarioId,
      );

      if (!mounted) return;

      AuthSession.instance.entrar(atualizado, token: AuthSession.instance.token);

      setState(() {
        _usuario = atualizado;
        _fotoEscolhida = null;
        _bytesDaFoto = null;
        _salvandoFoto = false;
      });

      _mostrarMensagem('Foto removida.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvandoFoto = false;
        _erroGeral = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ============================================================
  // SALVAR
  // ============================================================

  Future<void> _salvar() async {
    DateTime? dataNasc;
    String? erroData;

    try {
      dataNasc = parseDataBrasileira(_dataController.text);
    } on FormatException catch (e) {
      erroData = e.message;
    }

    final senha = _senhaController.text;
    final senhaAtual = _senhaAtualController.text;

    final erroNome = _nomeController.text.trim().length < 2
        ? 'Digite seu nome.'
        : null;

    final erroSenha = senha.isNotEmpty && senha.length < 6
        ? 'A senha precisa de pelo menos 6 caracteres.'
        : null;

    // O backend exige a senha atual: sem ela a troca valeria para qualquer
    // conta, já que a rota é só pelo id.
    final erroSenhaAtual = senha.isNotEmpty && senhaAtual.isEmpty
        ? 'Informe a senha atual para trocar a senha.'
        : null;

    setState(() {
      _erroNome = erroNome;
      _erroUsername = !RegExp(
        r'^[a-z0-9_.]{3,24}$',
      ).hasMatch(_usernameController.text.trim().toLowerCase())
          ? 'Use de 3 a 24 caracteres: letras minúsculas, números, ponto ou _.'
          : null;
      _erroEmail = validarEmail(_emailController.text);
      _erroData = erroData;
      _erroCidade = _cidadeController.text.trim().length < 2
          ? 'Digite sua cidade.'
          : null;
      _erroEstado = _estadoController.text.trim().length < 2
          ? 'Digite o estado.'
          : null;
      _erroSenha = erroSenha;
      _erroSenhaAtual = erroSenhaAtual;
    });

    if (_temErroDeCampo || dataNasc == null) return;

    setState(() {
      _salvando = true;
      _erroGeral = null;
    });

    try {
      final atualizado = await widget.usuarioService.atualizarPerfil(
        widget.usuarioId,
        nome: _nomeController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        email: _emailController.text.trim(),
        dataNasc: dataNasc,
        cidade: _cidadeController.text.trim(),
        estado: _estadoController.text.trim(),
        senha: senha.isEmpty ? null : senha,
        senhaAtual: senha.isEmpty ? null : senhaAtual,
      );

      if (!mounted) return;

      // A sessão guarda o usuário em memória: sem isso, o resto do app
      // continuaria mostrando o nome e o e-mail antigos.
      final token = AuthSession.instance.token;
      AuthSession.instance.entrar(atualizado, token: token);

      // Senha nova não volta na resposta, e o campo também não deve
      // continuar cheio na tela.
      _senhaController.clear();
      _senhaAtualController.clear();

      setState(() {
        _usuario = atualizado;
        _salvando = false;
      });

      _mostrarMensagem('Perfil atualizado.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erroGeral = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

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
                showActions: false,
                text: 'Editar perfil',
              ),
            ),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _falhaAoCarregar
                  ? _FalhaAoCarregarTela(aoTentarNovamente: _carregar)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Foto(
                                url: _usuario?.avatarUrl,
                                bytesLocais: _bytesDaFoto,
                                carregando: _salvandoFoto,
                                escolhida: _fotoEscolhida != null,
                                corDeFundo: appColors.accentSalmon,
                                aoEscolher: _salvandoFoto ? null : _escolherFoto,
                                aoEnviar: _salvandoFoto ? null : _salvarFoto,
                                aoRemover: _salvandoFoto
                                    ? null
                                    : _confirmarRemoverFoto,
                              ),
                              const SizedBox(height: 26),
                              CampoTexto(
                                rotulo: 'Nome',
                                controller: _nomeController,
                                hint: 'Seu nome completo',
                                icone: Symbols.person,
                                erro: _erroNome,
                                teclado: TextInputType.name,
                                acao: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              CampoTexto(
                                rotulo: 'Username',
                                controller: _usernameController,
                                hint: 'seu.username',
                                icone: Symbols.alternate_email,
                                erro: _erroUsername,
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
                              const SizedBox(height: 24),
                              const Center(
                                child: SizedBox(
                                  width: 200,
                                  child: Divider(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Trocar senha',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Deixe em branco para manter a senha atual.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 14),
                              CampoSenha(
                                rotulo: 'Senha atual',
                                controller: _senhaAtualController,
                                hint: 'A senha de hoje',
                                erro: _erroSenhaAtual,
                                acao: TextInputAction.next,
                              ),
                              const SizedBox(height: 14),
                              CampoSenha(
                                rotulo: 'Nova senha',
                                controller: _senhaController,
                                hint: 'Mínimo de 6 caracteres',
                                erro: _erroSenha,
                                acao: TextInputAction.done,
                                aoEnviar: (_) => _salvar(),
                              ),
                              if (_erroGeral != null) ...[
                                const SizedBox(height: 14),
                                AvisoDeErro(mensagem: _erroGeral!),
                              ],
                              const SizedBox(height: 20),
                              BotaoAuth(
                                texto: 'Salvar alterações',
                                icone: Symbols.save,
                                corDeFundo: appColors.accentBrown,
                                carregando: _salvando,
                                onPressed: _salvar,
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
// FALHA AO CARREGAR
// ============================================================

/// Sem os dados carregados, salvar mandaria o formulário em branco por cima do
/// perfil de verdade. Melhor mostrar o erro e oferecer nova tentativa.
class _FalhaAoCarregarTela extends StatelessWidget {
  final VoidCallback aoTentarNovamente;

  const _FalhaAoCarregarTela({required this.aoTentarNovamente});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.cloud_off, size: 40),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar seu perfil.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: aoTentarNovamente,
              icon: const Icon(Symbols.refresh, size: 18),
              label: const Text('Tentar de novo', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FOTO
// ============================================================

/// Avatar com preview local: enquanto a foto escolhida não é salva, o app
/// mostra os bytes da própria imagem em vez de uma requisição à rede.
class _Foto extends StatelessWidget {
  final String? url;
  final Uint8List? bytesLocais;
  final bool carregando;
  final bool escolhida;
  final Color corDeFundo;
  final VoidCallback? aoEscolher;
  final VoidCallback? aoEnviar;
  final VoidCallback? aoRemover;

  const _Foto({
    required this.corDeFundo,
    this.url,
    this.bytesLocais,
    this.carregando = false,
    this.escolhida = false,
    this.aoEscolher,
    this.aoEnviar,
    this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // Local, porque um campo público não é promovido a não-nulo pelo
    // compilador mesmo depois do teste logo abaixo.
    final urlAtiva = url;
    final temFoto = bytesLocais != null || urlAtiva != null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: corDeFundo,
              backgroundImage: bytesLocais != null
                  ? MemoryImage(bytesLocais!)
                  : (urlAtiva != null ? NetworkImage(urlAtiva) : null),
              onBackgroundImageError:
                  urlAtiva == null || bytesLocais != null
                  ? null
                  : (error, stackTrace) {},
              child: temFoto
                  ? null
                  : Icon(
                      Symbols.person,
                      size: 76,
                      color: appColors.onAccent,
                      weight: 600,
                    ),
            ),
            if (carregando)
              const CircleAvatar(
                radius: 52,
                backgroundColor: Colors.black26,
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: aoEscolher,
              icon: const Icon(Symbols.photo_camera, size: 18),
              // Já tem foto (salva ou escolhida) é troca; sem foto, é a
              // primeira publicação.
              label: Text(
                temFoto ? 'Trocar foto' : 'Escolher foto',
                style: const TextStyle(fontSize: 11),
              ),
            ),
            if (temFoto)
              TextButton.icon(
                onPressed: aoRemover,
                icon: Icon(
                  Symbols.delete_outline,
                  size: 18,
                  color: colors.error,
                ),
                label: Text(
                  'Remover',
                  style: TextStyle(fontSize: 11, color: colors.error),
                ),
              ),
          ],
        ),
        if (escolhida)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Toque em "Enviar foto" para publicar.',
              style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
            ),
          ),
        if (escolhida) ...[
          const SizedBox(height: 8),
          _BotaoFoto(
            carregando: carregando,
            onPressed: aoEnviar,
          ),
        ],
      ],
    );
  }
}

/// Botão que publica a foto escolhida, separado do "escolher" para que a
/// troca só chegue ao servidor quando a pessoa confirma.
class _BotaoFoto extends StatelessWidget {
  final bool carregando;
  final VoidCallback? onPressed;

  const _BotaoFoto({required this.carregando, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return SizedBox(
      height: 34,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Symbols.cloud_upload, size: 16),
        label: Text(
          carregando ? 'Enviando...' : 'Enviar foto',
          style: const TextStyle(fontSize: 11),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: appColors.accentSalmon,
          foregroundColor: appColors.onAccent,
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
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');

  return '$dia/$mes/${data.year}';
}
