import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/widgets/topbar.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String opcaoSelecionada = '1';

  final TextEditingController localController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  @override
  void dispose() {
    localController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Topbar(
              hasLogo: false,
              hasReturn: true,
              text: 'Criar Report',
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.primary, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho
                        Text(
                          'Registrar ocorrência',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Registre uma ocorrência ambiental observada em seu entorno.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),

                        const SizedBox(height: 28),

                        // Tipo
                        _FieldTitle(
                          icon: Symbols.category,
                          title: 'Tipo do ocorrido',
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          initialValue: opcaoSelecionada,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '1',
                              child: Text('Queimada'),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text('Animal ferido'),
                            ),
                            DropdownMenuItem(
                              value: '3',
                              child: Text('Desmatamento'),
                            ),
                            DropdownMenuItem(
                              value: '4',
                              child: Text('Animal exótico'),
                            ),
                            DropdownMenuItem(
                              value: '5',
                              child: Text('Poluição'),
                            ),
                          ],
                          onChanged: (valor) {
                            if (valor == null) return;

                            setState(() {
                              opcaoSelecionada = valor;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Localização
                        _FieldTitle(
                          icon: Symbols.location_on,
                          title: 'Localização',
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: localController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            hintText: 'Informe a localização do ocorrido',
                            prefixIcon: const Icon(
                              Symbols.location_on,
                              fill: 1,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Descrição
                        _FieldTitle(
                          icon: Symbols.description,
                          title: 'Descrição do ocorrido',
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: descricaoController,
                          minLines: 6,
                          maxLines: 10,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            hintText:
                                'Descreva o que aconteceu, onde ocorreu e outras informações relevantes...',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Anexos
                        _FieldTitle(icon: Symbols.attach_file, title: 'Anexos'),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 120,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: selecionar imagens/anexos
                            },
                            icon: const Icon(
                              Symbols.add_photo_alternate,
                              size: 28,
                            ),
                            label: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Adicionar anexos',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text('Adicione imagens da ocorrência'),
                              ],
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.primary,
                              side: BorderSide(color: colors.outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Enviar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _enviarReport();
                            },
                            icon: const Icon(Symbols.send, fill: 1),
                            label: const Text(
                              'Enviar report',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
          ),
        ],
      ),
    );
  }

  void _enviarReport() {
    final local = localController.text.trim();
    final descricao = descricaoController.text.trim();

    print('Tipo: $opcaoSelecionada');
    print('Local: $local');
    print('Descrição: $descricao');

    // TODO:
    // Fazer POST para a API.
  }
}

class _FieldTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FieldTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 21, color: colors.primary, fill: 1),

        const SizedBox(width: 8),

        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
