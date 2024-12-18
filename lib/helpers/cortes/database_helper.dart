import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cortes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // Cambia la versión para soportar migraciones
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Método para manejar migraciones
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE cortes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bscocNcoc TEXT NOT NULL,
      bscntCodf TEXT NOT NULL,
      bscocNcnt TEXT NOT NULL,
      dNomb TEXT NOT NULL,
      bscocNmor INTEGER NOT NULL,
      bscocImor REAL NOT NULL,
      bsmednser TEXT NOT NULL,
      bsmedNume TEXT NOT NULL,
      bscntlati REAL NOT NULL,
      bscntlogi REAL NOT NULL,
      dNcat TEXT NOT NULL,
      dCobc TEXT NOT NULL,
      dLotes TEXT NOT NULL,
      cortado INTEGER NOT NULL,
      fechaCorte TEXT NULL,
      imagenRuta TEXT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE rutas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bsrutnrut TEXT NOT NULL,
      bsrutdesc TEXT NOT NULL,
      bsrutabrv TEXT NOT NULL,
      bsruttipo TEXT NOT NULL,
      bsrutnzon TEXT NOT NULL,
      bsrutfcor TEXT NOT NULL,
      bsrutcper TEXT NOT NULL,
      bsrutstat INTEGER NOT NULL,
      bsrutride TEXT NOT NULL,
      dNomb TEXT NOT NULL,
      GbzonNzon TEXT NOT NULL,
      dNzon TEXT NOT NULL
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar la columna 'imagenRuta' si no existe
      await db.execute('ALTER TABLE cortes ADD COLUMN imagenRuta TEXT NULL');
      print('Columna "imagenRuta" agregada a la tabla "cortes".');
    }
  }

  // Métodos para la tabla cortes

  Future<int> insertCorte(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('cortes', data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> updateCortado(
    int id,
    bool cortado, {
    String? fechaCorte,
    String? imagenRuta,
  }) async {
    final db = await database;
    return await db.update(
      'cortes',
      {
        'cortado': cortado ? 1 : 0,
        'fechaCorte': fechaCorte,
        'imagenRuta': imagenRuta,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCortes() async {
    final db = await database;
    return await db.query('cortes');
  }

  Future<List<Map<String, dynamic>>> getCortesPorEstado(bool cortado) async {
    final db = await database;
    return await db.query(
      'cortes',
      where: 'cortado = ?',
      whereArgs: [cortado ? 1 : 0],
    );
  }

  Future<List<Map<String, dynamic>>> getCortesPaginados(
      int offset, int limit) async {
    final db = await database;
    return await db.query(
      'cortes',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getCortesPorFiltro(
      String columna, String valor) async {
    final db = await database;
    return await db.query(
      'cortes',
      where: '$columna LIKE ?',
      whereArgs: ['%$valor%'],
    );
  }

  Future<List<Map<String, dynamic>>> getCortesAvanzados({
    String? columna,
    String? valor,
    int? offset,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      'cortes',
      where: (columna != null && valor != null) ? '$columna LIKE ?' : null,
      whereArgs: (columna != null && valor != null) ? ['%$valor%'] : null,
      limit: limit,
      offset: offset,
    );
  }

  // Métodos para la tabla rutas

  Future<int> insertRuta(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('rutas', data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getRutas() async {
    final db = await database;
    return await db.query('rutas');
  }

  Future<List<Map<String, dynamic>>> getRutasPorFiltro(
      String columna, String valor) async {
    final db = await database;
    return await db.query(
      'rutas',
      where: '$columna LIKE ?',
      whereArgs: ['%$valor%'],
    );
  }

  Future<List<Map<String, dynamic>>> getRutasAvanzadas({
    String? columna,
    String? valor,
    int? offset,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      'rutas',
      where: (columna != null && valor != null) ? '$columna LIKE ?' : null,
      whereArgs: (columna != null && valor != null) ? ['%$valor%'] : null,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getCortesCortados() async {
    final db = await database;
    return await db.query(
      'cortes',
      where: 'cortado = 1',
    );
  }

  // Cerrar la base de datos
  Future close() async {
    final db = await database;
    db.close();
  }
}
