import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MissionPhoto {
  final String path;
  final DateTime date;

  MissionPhoto({
    required this.path,
    required this.date,
  });
}

// Mock compartilhado entre aberturas da tela durante a execução do app.
class MissionPhotoStore {
  static final Map<int, List<MissionPhoto>> photos = {};

  static List<MissionPhoto> forMission(int missionId) {
    return photos.putIfAbsent(missionId, () => []);
  }

  static void add(int missionId, MissionPhoto photo) {
    forMission(missionId).insert(0, photo);
  }
}

class MissionSubmissionPage extends StatefulWidget {
  final int missionId;
  final String missionTitle;

  const MissionSubmissionPage({
    super.key,
    required this.missionId,
    required this.missionTitle,
  });

  @override
  State<MissionSubmissionPage> createState() =>
      _MissionSubmissionPageState();
}

class _MissionSubmissionPageState
    extends State<MissionSubmissionPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? _imagem;
  bool _enviando = false;

  List<MissionPhoto> get _fotos =>
      MissionPhotoStore.forMission(widget.missionId);

  Future<void> _selecionarImagem(ImageSource source) async {
    try {
      final imagem = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (imagem != null && mounted) {
        setState(() => _imagem = imagem);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a câmera ou galeria.'),
        ),
      );
    }
  }

  void _abrirGaleriaConclusoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MissionPhotoGalleryPage(
          missionId: widget.missionId,
          missionTitle: widget.missionTitle,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _enviarConclusao() async {
    if (_imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tire uma foto ou escolha uma da galeria.'),
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    // Mock: registra a foto localmente, sem chamar a API.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    MissionPhotoStore.add(
      widget.missionId,
      MissionPhoto(
        path: _imagem!.path,
        date: DateTime.now(),
      ),
    );

    setState(() {
      _imagem = null;
      _enviando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto adicionada às fotos da missão!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fotos = _fotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Concluir missão'),
        actions: [
          // Miniatura no canto superior direito.
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: _abrirGaleriaConclusoes,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 46,
                height: 46,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: fotos.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(fotos.first.path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.photo_library,
                              color: colors.primary,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                ),
                              ),
                              child: Text(
                                '${fotos.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        Icons.photo_library_outlined,
                        color: colors.primary,
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.missionTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tire uma foto para registrar a conclusão desta missão.',
            ),
            const SizedBox(height: 24),

            // Área principal: abre diretamente a câmera.
            GestureDetector(
              onTap: _enviando
                  ? null
                  : () => _selecionarImagem(ImageSource.camera),
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagem == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 58,
                            color: colors.primary,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Tirar foto da conclusão',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Toque para abrir a câmera',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(_imagem!.path),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: FilledButton.tonalIcon(
                              onPressed: _enviando
                                  ? null
                                  : () => _selecionarImagem(
                                        ImageSource.camera,
                                      ),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Refazer'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _enviando
                  ? null
                  : () => _selecionarImagem(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Escolher foto da galeria'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _enviando ? null : _enviarConclusao,
              icon: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _enviando ? 'Registrando...' : 'Enviar conclusão',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '${fotos.length} ${fotos.length == 1 ? 'foto registrada' : 'fotos registradas'} nesta missão',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class MissionPhotoGalleryPage extends StatelessWidget {
  final int missionId;
  final String missionTitle;

  const MissionPhotoGalleryPage({
    super.key,
    required this.missionId,
    required this.missionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final fotos = MissionPhotoStore.forMission(missionId);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas fotos'),
      ),
      body: fotos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma foto registrada ainda.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'As fotos adicionadas nesta missão aparecerão aqui.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: fotos.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final foto = fotos[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MissionPhotoDetailPage(
                          photo: foto,
                          missionTitle: missionTitle,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(foto.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colors.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MissionPhotoDetailPage extends StatelessWidget {
  final MissionPhoto photo;
  final String missionTitle;

  const MissionPhotoDetailPage({
    super.key,
    required this.photo,
    required this.missionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final data = photo.date;
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} às '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto da missão'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.file(
                File(photo.path),
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 64),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  missionTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Registrada em $dataFormatada'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
