/// Uma classe que representa um banco emissor.
class BancoEmissor {
  final String codigo;
  final String? banco;
  final String? ispb;
  final String? pdf;

  BancoEmissor({
    required this.codigo,
    this.banco,
    this.ispb,
    this.pdf = 'https://www.bcb.gov.br/pom/spb/estatistica/port/ASTR003.pdf',
  });

  BancoEmissor.empty({
    this.codigo = '000',
    this.banco = 'N/A',
    this.ispb = 'N/A',
    this.pdf = 'https://www.bcb.gov.br/pom/spb/estatistica/port/ASTR003.pdf',
  });
}
