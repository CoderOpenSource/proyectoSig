class Medidor {
  final int id; // Campo id
  final int ncoc;
  final int codf;
  final int ncnt;
  final String nomb;
  final int nmor;
  final double imor;
  final String nser;
  final String nume;
  final double lat;
  final double lng;
  final String ncat;
  final String cobc;
  final String lotes;
  final String? fechaCorte; // Agregamos el campo fechaCorte como nulo

  Medidor({
    required this.id, // Requerimos el id en el constructor
    required this.ncoc,
    required this.codf,
    required this.ncnt,
    required this.nomb,
    required this.nmor,
    required this.imor,
    required this.nser,
    required this.nume,
    required this.lat,
    required this.lng,
    required this.ncat,
    required this.cobc,
    required this.lotes,
    this.fechaCorte, // Permitimos que fechaCorte sea opcional
  });

  factory Medidor.fromMap(Map<String, dynamic> map) {
    return Medidor(
      id: int.parse(map['id']!), // Parseamos el campo id desde el mapa
      ncoc: int.parse(map['bscocNcoc']!),
      codf: int.parse(map['bscntCodf']!),
      ncnt: int.parse(map['bscocNcnt']!),
      nomb: map['dNomb']!,
      nmor: int.parse(map['bscocNmor']!),
      imor: double.parse(map['bscocImor']!),
      nser: map['bsmednser']!,
      nume: map['bsmedNume']!,
      lat: double.parse(map['bscntlati']!),
      lng: double.parse(map['bscntlogi']!),
      ncat: map['dNcat']!,
      cobc: map['dCobc']!,
      lotes: map['dLotes']!,
      fechaCorte: map['fechaCorte'], // Parseamos la fechaCorte si existe
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bscocNcoc': ncoc,
      'bscntCodf': codf,
      'bscocNcnt': ncnt,
      'dNomb': nomb,
      'bscocNmor': nmor,
      'bscocImor': imor,
      'bsmednser': nser,
      'bsmedNume': nume,
      'bscntlati': lat,
      'bscntlogi': lng,
      'dNcat': ncat,
      'dCobc': cobc,
      'dLotes': lotes,
      'fechaCorte': fechaCorte, // Incluimos la fechaCorte en el mapa
    };
  }
}
