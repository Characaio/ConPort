import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/conquistas/conquistas.dart';
import 'package:conport/services/avistamento_service.dart';
import 'package:conport/widgets/topbar.dart';

class AvistamentoPage extends StatefulWidget {
  final XFile imagem;
  final int unidadeId;
  final int usuarioId;
  final AvistamentoService service;

  const AvistamentoPage({
    super.key,
    required this.imagem,
    required this.unidadeId,
    required this.usuarioId,
    this.service = const AvistamentoService(),
  });

  /// Ponto de entrada: chame isto no clique do botão "Enviar Avistamento".
  /// Pede a imagem (câmera/galeria no celular, seletor de arquivos no PC)
  /// e, se o usuário escolher uma, abre a tela de confirmação.
        static Future<void> iniciar(
          BuildContext context, {
          required int unidadeId,
          required int usuarioId,
        }) async {
          final imagem = await escolherImagem(context);

          if (imagem == null || !context.mounted) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AvistamentoPage(
                imagem: imagem,
                unidadeId: unidadeId,
                usuarioId: usuarioId,
              ),
            ),
          );
        }

  @override
  State<AvistamentoPage> createState() => _AvistamentoPageState();
}

class _AvistamentoPageState extends State<AvistamentoPage> {
  Uint8List? _bytes;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _carregarBytes();
  }

  // Usar bytes (em vez de File) faz o preview funcionar também na web.
  Future<void> _carregarBytes() async {
    final bytes = await widget.imagem.readAsBytes();
    if (!mounted) return;
    setState(() => _bytes = bytes);
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await widget.service.enviar(
        imagem:widget.imagem,
        unidadeId: widget.unidadeId,
        usuarioId: widget.usuarioId,
        );

      messenger.showSnackBar(
        const SnackBar(content: Text('Avistamento enviado!')),
      );

      if (mounted) {
        await registrarConquista(context, TipoConquista.avistamentoEnviado);
      }

      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível enviar o avistamento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(hasLogo: false, hasReturn: false, text: 'Avistamento'),
              const Divider(),
              const SizedBox(height: 56),

              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 15, color: colors.onSurface),
                  children: const [
                    TextSpan(text: 'Deseja enviar essa imagem como um\n'),
                    TextSpan(
                      text: 'Avistamento',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: '?'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Moldura preta arredondada com a imagem dentro
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _bytes == null
                        ? const Center(child: CircularProgressIndicator())
                        : Image.memory(_bytes!, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 56),

              Row(
                children: [
                  Expanded(
                    child: _BotaoPilula(
                      texto: 'Enviar',
                      cor: const Color(0xFF5E7654),
                      carregando: _enviando,
                      onPressed: _enviando ? null : _enviar,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _BotaoPilula(
                      texto: 'Cancelar',
                      cor: const Color(0xFF6B5750),
                      onPressed: _enviando
                          ? null
                          : () => Navigator.of(context).pop(),
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

class _BotaoPilula extends StatelessWidget {
  final String texto;
  final Color cor;
  final bool carregando;
  final VoidCallback? onPressed;

  const _BotaoPilula({
    required this.texto,
    required this.cor,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: cor.withAlpha(150),
          disabledForegroundColor: Colors.white70,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: carregando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(texto, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

// ============================================================
// SELEÇÃO DE IMAGEM
// ============================================================

/// Câmera só existe no celular. No PC (Linux, Windows, macOS) e na web
/// o image_picker não tem câmera, então vai direto para o seletor de arquivos.
bool get _temCamera =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

Future<XFile?> escolherImagem(BuildContext context) async {
  ImageSource? origem = ImageSource.gallery;

  if (_temCamera) {
    origem = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Symbols.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Usuário fechou o menu sem escolher
  if (origem == null) return null;

  try {
    return await ImagePicker().pickImage(
      source: origem,
      maxWidth: 1920,
      imageQuality: 85,
    );
  } catch (e) {
    // Ex.: permissão de câmera negada
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível acessar a imagem.')),
      );
    }
    return null;
  }
}
