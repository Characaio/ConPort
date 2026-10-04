import 'package:http_parser/http_parser.dart';

/// Descobre o `Content-Type` de um arquivo pelo nome.
///
/// O multipart do Dart **não** manda `Content-Type` na parte do arquivo se a
/// gente não informar: sai só o `Content-Disposition`. O backend usa esse
/// header para validar o formato, então sem ele toda imagem era rejeitada com
/// "Formato de imagem não permitido" (e, como a validação vinha como
/// IllegalArgumentException, o app mostrava 500).
///
/// Extensão desconhecida cai em `image/jpeg`, que é o que o seletor de fotos
/// entrega na prática — melhor do que mandar uma parte sem tipo.
MediaType mediaTypeDaImagem(String? nomeArquivo) {
  final nome = (nomeArquivo ?? '').toLowerCase();

  if (nome.endsWith('.png')) return MediaType('image', 'png');
  if (nome.endsWith('.webp')) return MediaType('image', 'webp');
  if (nome.endsWith('.heic')) return MediaType('image', 'heic');

  // .jpg, .jpeg e o resto: JPEG.
  return MediaType('image', 'jpeg');
}