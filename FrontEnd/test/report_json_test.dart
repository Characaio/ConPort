import 'package:flutter_test/flutter_test.dart';

import 'package:conport/models/report.dart';

/// Regressão do "Alguma merda rolou rapaz": o report era criado (201) e a tela
/// ainda mostrava erro, porque o `Report.fromJson` só lia `TipoDeIncidente` /
/// `StatusReport` / `Localizacao` e o backend devolve `Tipo` / `Status` /
/// `Latitude`+`Longitude`.
void main() {
  // Corpo real devolvido pelo POST /unidade/{id}/reports (201).
  final corpoDaApi = <String, dynamic>{
    'Id': 9,
    'Tipo': 'QUEIMADA',
    'Status': 'PENDENTE',
    'DataDoOcorrido': '2026-10-03T21:49:54',
    'Descricao': 'fogo na mata',
    'Prioridade': 'MEDIA',
    'ImagensAnexadas': ['a.png'],
    'UsuarioNome': 'Usuário Demo',
    'UnidadeNome': 'Parque Estadual',
    'SupervisorNome': null,
    'DataDaAnalise': null,
    'Longitude': -43.1558,
    'Latitude': -22.9468,
  };

  test('lê o corpo que o backend devolve no 201', () {
    final report = Report.fromJson(corpoDaApi);

    expect(report.id, 9);
    expect(report.tipoDeIncidente, TipoDeIncidente.QUEIMADA);
    expect(report.statusReport, StatusReport.PENDNTE);
    expect(report.dataDoOcorrido, DateTime(2026, 10, 3, 21, 49, 54));
    expect(report.descricao, 'fogo na mata');
    expect(report.imagensAnexadas, ['a.png']);
    expect(report.unidadeNome, 'Parque Estadual');
    expect(report.supervisorNome, isNull);
    expect(report.dataDaAnalise, isNull);
    // Não existe campo "Localizacao": a localização vem em lat/long.
    expect(report.localizacao, '-22.9468, -43.1558');
  });

  test('aceita o corpo do ReportResumidoDTO, sem localização', () {
    final report = Report.fromJson(<String, dynamic>{
      'Id': 3,
      'Tipo': 'POLUICAO',
      'Status': 'ACEITO',
      'DataDoOcorrido': '2026-10-03T21:49:54',
      'Prioridade': 'ALTA',
      'motivoNegacao': null,
      'supervisorNome': 'Supervisora Ana',
    });

    expect(report.tipoDeIncidente, TipoDeIncidente.POLUICAO);
    // O backend tem ACEITO e TRATADO; o app trata os dois como concluído.
    expect(report.statusReport, StatusReport.TRATADO);
    expect(report.localizacao, 'Local não informado');
    expect(report.imagensAnexadas, isNull);
    expect(report.supervisorNome, 'Supervisora Ana');
  });

  test('diz qual valor veio errado, em vez de exception genérica', () {
    expect(
      () => Report.fromJson(<String, dynamic>{
        'Id': 1,
        'Tipo': 'TERREMOTO',
        'Status': 'PENDENTE',
        'DataDoOcorrido': '2026-10-03T21:49:54',
      }),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'mensagem',
          contains('TERREMOTO'),
        ),
      ),
    );
  });
}