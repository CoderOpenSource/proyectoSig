class Medidor {
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

  Medidor({
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
  });

  factory Medidor.fromMap(Map<String, String> map) {
    return Medidor(
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
    );
  }
}
