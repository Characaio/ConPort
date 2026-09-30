import 'package:flutter/material.dart';
import 'package:conport/widgets/topbar.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  double urgencia = 0.5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Topbar(hasLogo: false, hasReturn: true, text: 'Criar Report'),

                const SizedBox(height: 20),

                const Text('O que aconteceu?'),

                const SizedBox(height: 6),

                DropdownMenu<String>(
                  width: double.infinity,
                  initialSelection: 'queimada',
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'queimada', label: 'Queimada'),
                    DropdownMenuEntry(
                      value: 'animal_ferido',
                      label: 'Animal Ferido',
                    ),
                    DropdownMenuEntry(
                      value: 'animal_exotico',
                      label: 'Animal Exótico',
                    ),
                    DropdownMenuEntry(value: 'poluicao', label: 'Poluição'),
                    DropdownMenuEntry(
                      value: 'desmatamento',
                      label: 'Desmatamento',
                    ),
                  ],
                  onSelected: (value) {},
                ),

                const SizedBox(height: 16),
                const Text('Descrição'),

                const SizedBox(height: 16),

                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                          'Nunc commodo turpis leo, ut fringilla lorem posuere a. '
                          'Mauris ut tellus in justo venenatis tristique efficitur '
                          'sit amet metus.',
                        ),
                        const Spacer(),

                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),

                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const Spacer(),

                            const Icon(Icons.attach_file, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Local'),
                const SizedBox(height: 6),

                Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: Text('R. dos bobões, 0')),
                      Icon(Icons.location_on, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                const Text('o quão urgente é o ocorrido'),
                const SizedBox(height: 4),

                Slider(
                  value: urgencia,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() {
                      urgencia = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Pouco', style: TextStyle(fontSize: 15)),

                    Text('muito', style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 14),

                const Text('Veja o que se fazer referente a queimadas:'),
                const SizedBox(height: 2),

                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Nunc commodo turpis leo, ut fringilla lorem posuere a. '
                  'Mauris ut tellus in justo venenatis tristique efficitur '
                  'sit amet metus.',
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 8),
                Container(
                  height: 145,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Enviar'),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('cancelar '),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
