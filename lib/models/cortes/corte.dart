class Corte {
  int id;
  String bscocNcoc;
  String bscntCodf;
  String bscocNcnt;
  String dNomb;
  int bscocNmor;
  double bscocImor;
  String bsmednser;
  String bsmedNume;
  double bscntlati;
  double bscntlogi;
  String dNcat;
  String dCobc;
  String dLotes;
  bool cortado;
  String? fechaCorte; // Atributo nuevo: fecha de corte (nullable)

  Corte({
    required this.id,
    required this.bscocNcoc,
    required this.bscntCodf,
    required this.bscocNcnt,
    required this.dNomb,
    required this.bscocNmor,
    required this.bscocImor,
    required this.bsmednser,
    required this.bsmedNume,
    required this.bscntlati,
    required this.bscntlogi,
    required this.dNcat,
    required this.dCobc,
    required this.dLotes,
    required this.cortado,
    this.fechaCorte, // Parámetro opcional
  });

  Map<String, dynamic> toMap() {
    return {
      'bscocNcoc': bscocNcoc,
      'bscntCodf': bscntCodf,
      'bscocNcnt': bscocNcnt,
      'dNomb': dNomb,
      'bscocNmor': bscocNmor,
      'bscocImor': bscocImor,
      'bsmednser': bsmednser,
      'bsmedNume': bsmedNume,
      'bscntlati': bscntlati,
      'bscntlogi': bscntlogi,
      'dNcat': dNcat,
      'dCobc': dCobc,
      'dLotes': dLotes,
      'cortado': cortado ? 1 : 0,
      'fechaCorte': fechaCorte, // Incluir la fecha de corte
    };
  }
}
