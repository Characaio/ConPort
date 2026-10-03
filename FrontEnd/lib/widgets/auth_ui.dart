import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/theme/app_theme.dart';

// ============================================================
// VALIDAÇÕES
// ============================================================

/// Mensagem de erro ou `null` se o e-mail for válido.
String? validarEmail(String texto) {
  final email = texto.trim();

  if (email.isEmpty) return 'Digite seu e-mail.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'E-mail inválido.';
  }

  return null;
}

/// Converte `dd/mm/aaaa` em [DateTime].
///
/// Lança [FormatException] com a mensagem pronta para o campo quando o
/// texto não é uma data de nascimento válida.
DateTime parseDataBrasileira(String texto) {
  final valor = texto.trim();

  if (valor.isEmpty) {
    throw const FormatException('Digite sua data de nascimento.');
  }

  final partes = valor.split('/');

  if (partes.length != 3) {
    throw const FormatException('Use o formato DD/MM/AAAA.');
  }

  final dia = int.tryParse(partes[0].trim());
  final mes = int.tryParse(partes[1].trim());
  final ano = int.tryParse(partes[2].trim());

  if (dia == null || mes == null || ano == null || ano < 1900) {
    throw const FormatException('Data inválida.');
  }

  final data = DateTime(ano, mes, dia);

  if (data.year != ano || data.month != mes || data.day != dia) {
    throw const FormatException('Data inválida.');
  }

  if (data.isAfter(DateTime.now())) {
    throw const FormatException('A data não pode estar no futuro.');
  }

  return data;
}

// ============================================================
// BOTÃO
// ============================================================

/// Botão "pílula" usado nas telas de acesso.
class BotaoAuth extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final Color? corDeFundo;
  final bool carregando;

  const BotaoAuth({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.corDeFundo,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fundo = corDeFundo ?? colors.primary;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: fundo.withValues(alpha: 0.6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: carregando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ============================================================
// CAMPOS
// ============================================================

/// Campo de texto rotulado, no estilo dos demais formulários do app.
class CampoTexto extends StatelessWidget {
  final String rotulo;
  final TextEditingController controller;
  final String hint;
  final IconData? icone;
  final String? erro;
  final bool obscuro;
  final Widget? sufixo;
  final TextInputType? teclado;
  final TextInputAction? acao;
  final String? autofill;
  final bool somenteLeitura;
  final VoidCallback? aoTocar;
  final ValueChanged<String>? aoEnviar;

  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.controller,
    required this.hint,
    this.icone,
    this.erro,
    this.obscuro = false,
    this.sufixo,
    this.teclado,
    this.acao,
    this.autofill,
    this.somenteLeitura = false,
    this.aoTocar,
    this.aoEnviar,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: somenteLeitura,
          onTap: aoTocar,
          obscureText: obscuro,
          keyboardType: teclado,
          textInputAction: acao,
          autofillHints: autofill != null ? [autofill!] : null,
          onSubmitted: aoEnviar,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13),
            errorText: erro,
            prefixIcon: icone != null ? Icon(icone, size: 20) : null,
            suffixIcon: sufixo,
            filled: true,
            fillColor: appColors.inputBackground,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo de senha com botão de mostrar/ocultar.
class CampoSenha extends StatefulWidget {
  final String rotulo;
  final TextEditingController controller;
  final String hint;
  final String? erro;
  final TextInputAction? acao;
  final ValueChanged<String>? aoEnviar;

  const CampoSenha({
    super.key,
    required this.rotulo,
    required this.controller,
    required this.hint,
    this.erro,
    this.acao,
    this.aoEnviar,
  });

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _visivel = false;

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      rotulo: widget.rotulo,
      controller: widget.controller,
      hint: widget.hint,
      erro: widget.erro,
      obscuro: !_visivel,
      teclado: TextInputType.visiblePassword,
      acao: widget.acao,
      autofill: AutofillHints.password,
      aoEnviar: widget.aoEnviar,
      sufixo: IconButton(
        tooltip: _visivel ? 'Ocultar senha' : 'Mostrar senha',
        icon: Icon(
          _visivel ? Symbols.visibility_off : Symbols.visibility,
          size: 20,
        ),
        onPressed: () => setState(() => _visivel = !_visivel),
      ),
    );
  }
}

// ============================================================
// AVISO DE ERRO
// ============================================================

/// Erro que não pertence a um campo específico (credenciais, rede...).
class AvisoDeErro extends StatelessWidget {
  final String mensagem;

  const AvisoDeErro({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Symbols.error_outline, size: 18, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(fontSize: 12, color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SELO DE MODO DEMONSTRAÇÃO
// ============================================================

/// Aviso discreto de que o app está rodando com dados mockados.
class SeloModoDemo extends StatelessWidget {
  const SeloModoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Symbols.info, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Modo demonstração: dados locais, sem servidor conectado.',
            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
