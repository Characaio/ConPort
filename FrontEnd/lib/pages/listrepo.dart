import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:conport/widgets/topbar.dart';

class SeusReports extends StatelessWidget {
  const SeusReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7E7),

      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // TOPO
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Topbar(
                hasLogo: false,
                hasReturn: true,
                text: 'Seus Reports',
              ),
            ),

            // ==========================================
            // LISTA DE REPORTS
            // ==========================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                children: const [
                  // REPORT NEGADO
                  NovoReportCard(
                    status: 'Negado',
                    motivo: 'Falso Report',
                    statusColor: Color(0xFFFF6B6B),
                    statusIcon: Symbols.cancel,
                    quantidadeAnexos: 0,
                  ),

                  // REPORT PENDENTE
                  NovoReportCard(
                    status: 'Pendente',
                    motivo: null,
                    statusColor: Color(0xFFC7C900),
                    statusIcon: Symbols.more_horiz,
                    mostrarImagem: true,
                    quantidadeAnexos: 1,
                  ),

                  // REPORT CONCLUÍDO
                  NovoReportCard(
                    status: 'Resolvido',
                    motivo: null,
                    statusColor: Color(0xFF00C83C),
                    statusIcon: Symbols.check_circle,
                    autor: 'Joãozinho Biologias da Silva',
                    mostrarImagem: true,
                    quantidadeAnexos: 2,
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


// ======================================================
// NOVO CARD DE REPORT
// ======================================================

class NovoReportCard extends StatelessWidget {
  final String status;
  final String? motivo;
  final String? autor;
  final int quantidadeAnexos;
  final Color statusColor;
  final IconData statusIcon;

  final bool mostrarImagem;

  const NovoReportCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.quantidadeAnexos,
    this.motivo,
    this.autor,
    this.mostrarImagem = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        // COR DO CARD
        color: const Color(0xFFE5E7E7),

        // BORDA = COR DO RESULTADO
        border: Border.all(
          color: statusColor,
          width: 1,
        ),

        borderRadius: BorderRadius.circular(13),
      ),

      child: Padding(
        padding: const EdgeInsets.all(10),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // ÍCONE DO ANIMAL
            // ==========================================
            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),

              child: const Icon(
                Symbols.pets,
                color: Colors.black,
                size: 28,
              ),
            ),

            const SizedBox(width: 7),

            // ==========================================
            // INFORMAÇÕES
            // ==========================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  const Text(
                    'Animal ferido',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 1),

                  // LOCAL
                  Row(
                    children: [
                      const Icon(
                        Symbols.explore,
                        size: 13,
                        color: Colors.black,
                      ),

                      const SizedBox(width: 3),

                      const Text(
                        'Jardim Europa',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // DATA
                  Row(
                    children: [
                      const Icon(
                        Symbols.calendar_month,
                        size: 14,
                        color: Colors.black,
                      ),

                      const SizedBox(width: 4),

                      const Text(
                        '67/67/6767 67:67',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // STATUS
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),

                  // ======================================
                  // MOTIVO
                  // ======================================
                  if (motivo != null) ...[
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Symbols.info,
                          size: 14,
                          color: Colors.black,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          motivo!,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ======================================
                  // AUTOR
                  // Só aparece quando o report foi concluído
                  // ======================================
                  if (autor != null) ...[
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Symbols.person,
                          size: 14,
                          color: Colors.black,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            'Por $autor',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ==========================================
            // IMAGEM
            // ==========================================
            if (quantidadeAnexos > 0) ...[
              const SizedBox(width: 8),

              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  children: [
                    // Segundo anexo, aparece somente se tiver 2
                    if (quantidadeAnexos >= 2)
                      Positioned(
                        left: 7,
                        top: 4,
                        child: Container(
                          width: 80,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8A8A8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                    // Primeiro anexo
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 80,
                        height: 88,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5B5B5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ]
        ),
      ),
    );
  }
}