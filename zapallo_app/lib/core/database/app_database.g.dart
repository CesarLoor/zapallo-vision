// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LeafImagesTable extends LeafImages
    with TableInfo<$LeafImagesTable, LeafImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeafImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _blurScoreMeta = const VerificationMeta(
    'blurScore',
  );
  @override
  late final GeneratedColumn<double> blurScore = GeneratedColumn<double>(
    'blur_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brightnessScoreMeta = const VerificationMeta(
    'brightnessScore',
  );
  @override
  late final GeneratedColumn<double> brightnessScore = GeneratedColumn<double>(
    'brightness_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosisClassMeta = const VerificationMeta(
    'diagnosisClass',
  );
  @override
  late final GeneratedColumn<String> diagnosisClass = GeneratedColumn<String>(
    'diagnosis_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosisLabelMeta = const VerificationMeta(
    'diagnosisLabel',
  );
  @override
  late final GeneratedColumn<String> diagnosisLabel = GeneratedColumn<String>(
    'diagnosis_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosisConfidenceMeta =
      const VerificationMeta('diagnosisConfidence');
  @override
  late final GeneratedColumn<double> diagnosisConfidence =
      GeneratedColumn<double>(
        'diagnosis_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    capturedAt,
    fileSize,
    width,
    height,
    blurScore,
    brightnessScore,
    notes,
    diagnosisClass,
    diagnosisLabel,
    diagnosisConfidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaf_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeafImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('blur_score')) {
      context.handle(
        _blurScoreMeta,
        blurScore.isAcceptableOrUnknown(data['blur_score']!, _blurScoreMeta),
      );
    }
    if (data.containsKey('brightness_score')) {
      context.handle(
        _brightnessScoreMeta,
        brightnessScore.isAcceptableOrUnknown(
          data['brightness_score']!,
          _brightnessScoreMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('diagnosis_class')) {
      context.handle(
        _diagnosisClassMeta,
        diagnosisClass.isAcceptableOrUnknown(
          data['diagnosis_class']!,
          _diagnosisClassMeta,
        ),
      );
    }
    if (data.containsKey('diagnosis_label')) {
      context.handle(
        _diagnosisLabelMeta,
        diagnosisLabel.isAcceptableOrUnknown(
          data['diagnosis_label']!,
          _diagnosisLabelMeta,
        ),
      );
    }
    if (data.containsKey('diagnosis_confidence')) {
      context.handle(
        _diagnosisConfidenceMeta,
        diagnosisConfidence.isAcceptableOrUnknown(
          data['diagnosis_confidence']!,
          _diagnosisConfidenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeafImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeafImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      blurScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}blur_score'],
      ),
      brightnessScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brightness_score'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      diagnosisClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis_class'],
      ),
      diagnosisLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosis_label'],
      ),
      diagnosisConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}diagnosis_confidence'],
      ),
    );
  }

  @override
  $LeafImagesTable createAlias(String alias) {
    return $LeafImagesTable(attachedDatabase, alias);
  }
}

class LeafImage extends DataClass implements Insertable<LeafImage> {
  /// Identificador único (UUID v4) — FUN-007
  final String id;

  /// Ruta absoluta del archivo en el dispositivo
  final String filePath;

  /// Fecha y hora de captura — FUN-008
  final DateTime capturedAt;

  /// Tamaño del archivo en bytes
  final int fileSize;

  /// Ancho en píxeles
  final int width;

  /// Altura en píxeles
  final int height;

  /// Puntuación de nitidez (varianza del Laplaciano)
  /// Null si no se evaluó
  final double? blurScore;

  /// Puntuación de brillo promedio (0-255)
  final double? brightnessScore;

  /// Notas del usuario (para uso futuro)
  final String? notes;

  /// Clase detectada por el modelo (ej: 'downy_mildew')
  final String? diagnosisClass;

  /// Nombre en español de la enfermedad
  final String? diagnosisLabel;

  /// Confianza del modelo (0.0 - 1.0)
  final double? diagnosisConfidence;
  const LeafImage({
    required this.id,
    required this.filePath,
    required this.capturedAt,
    required this.fileSize,
    required this.width,
    required this.height,
    this.blurScore,
    this.brightnessScore,
    this.notes,
    this.diagnosisClass,
    this.diagnosisLabel,
    this.diagnosisConfidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_path'] = Variable<String>(filePath);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['file_size'] = Variable<int>(fileSize);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    if (!nullToAbsent || blurScore != null) {
      map['blur_score'] = Variable<double>(blurScore);
    }
    if (!nullToAbsent || brightnessScore != null) {
      map['brightness_score'] = Variable<double>(brightnessScore);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || diagnosisClass != null) {
      map['diagnosis_class'] = Variable<String>(diagnosisClass);
    }
    if (!nullToAbsent || diagnosisLabel != null) {
      map['diagnosis_label'] = Variable<String>(diagnosisLabel);
    }
    if (!nullToAbsent || diagnosisConfidence != null) {
      map['diagnosis_confidence'] = Variable<double>(diagnosisConfidence);
    }
    return map;
  }

  LeafImagesCompanion toCompanion(bool nullToAbsent) {
    return LeafImagesCompanion(
      id: Value(id),
      filePath: Value(filePath),
      capturedAt: Value(capturedAt),
      fileSize: Value(fileSize),
      width: Value(width),
      height: Value(height),
      blurScore: blurScore == null && nullToAbsent
          ? const Value.absent()
          : Value(blurScore),
      brightnessScore: brightnessScore == null && nullToAbsent
          ? const Value.absent()
          : Value(brightnessScore),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      diagnosisClass: diagnosisClass == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosisClass),
      diagnosisLabel: diagnosisLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosisLabel),
      diagnosisConfidence: diagnosisConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosisConfidence),
    );
  }

  factory LeafImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeafImage(
      id: serializer.fromJson<String>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      blurScore: serializer.fromJson<double?>(json['blurScore']),
      brightnessScore: serializer.fromJson<double?>(json['brightnessScore']),
      notes: serializer.fromJson<String?>(json['notes']),
      diagnosisClass: serializer.fromJson<String?>(json['diagnosisClass']),
      diagnosisLabel: serializer.fromJson<String?>(json['diagnosisLabel']),
      diagnosisConfidence: serializer.fromJson<double?>(
        json['diagnosisConfidence'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filePath': serializer.toJson<String>(filePath),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'fileSize': serializer.toJson<int>(fileSize),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'blurScore': serializer.toJson<double?>(blurScore),
      'brightnessScore': serializer.toJson<double?>(brightnessScore),
      'notes': serializer.toJson<String?>(notes),
      'diagnosisClass': serializer.toJson<String?>(diagnosisClass),
      'diagnosisLabel': serializer.toJson<String?>(diagnosisLabel),
      'diagnosisConfidence': serializer.toJson<double?>(diagnosisConfidence),
    };
  }

  LeafImage copyWith({
    String? id,
    String? filePath,
    DateTime? capturedAt,
    int? fileSize,
    int? width,
    int? height,
    Value<double?> blurScore = const Value.absent(),
    Value<double?> brightnessScore = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> diagnosisClass = const Value.absent(),
    Value<String?> diagnosisLabel = const Value.absent(),
    Value<double?> diagnosisConfidence = const Value.absent(),
  }) => LeafImage(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    capturedAt: capturedAt ?? this.capturedAt,
    fileSize: fileSize ?? this.fileSize,
    width: width ?? this.width,
    height: height ?? this.height,
    blurScore: blurScore.present ? blurScore.value : this.blurScore,
    brightnessScore: brightnessScore.present
        ? brightnessScore.value
        : this.brightnessScore,
    notes: notes.present ? notes.value : this.notes,
    diagnosisClass: diagnosisClass.present
        ? diagnosisClass.value
        : this.diagnosisClass,
    diagnosisLabel: diagnosisLabel.present
        ? diagnosisLabel.value
        : this.diagnosisLabel,
    diagnosisConfidence: diagnosisConfidence.present
        ? diagnosisConfidence.value
        : this.diagnosisConfidence,
  );
  LeafImage copyWithCompanion(LeafImagesCompanion data) {
    return LeafImage(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      blurScore: data.blurScore.present ? data.blurScore.value : this.blurScore,
      brightnessScore: data.brightnessScore.present
          ? data.brightnessScore.value
          : this.brightnessScore,
      notes: data.notes.present ? data.notes.value : this.notes,
      diagnosisClass: data.diagnosisClass.present
          ? data.diagnosisClass.value
          : this.diagnosisClass,
      diagnosisLabel: data.diagnosisLabel.present
          ? data.diagnosisLabel.value
          : this.diagnosisLabel,
      diagnosisConfidence: data.diagnosisConfidence.present
          ? data.diagnosisConfidence.value
          : this.diagnosisConfidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeafImage(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('fileSize: $fileSize, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('blurScore: $blurScore, ')
          ..write('brightnessScore: $brightnessScore, ')
          ..write('notes: $notes, ')
          ..write('diagnosisClass: $diagnosisClass, ')
          ..write('diagnosisLabel: $diagnosisLabel, ')
          ..write('diagnosisConfidence: $diagnosisConfidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    capturedAt,
    fileSize,
    width,
    height,
    blurScore,
    brightnessScore,
    notes,
    diagnosisClass,
    diagnosisLabel,
    diagnosisConfidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeafImage &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.capturedAt == this.capturedAt &&
          other.fileSize == this.fileSize &&
          other.width == this.width &&
          other.height == this.height &&
          other.blurScore == this.blurScore &&
          other.brightnessScore == this.brightnessScore &&
          other.notes == this.notes &&
          other.diagnosisClass == this.diagnosisClass &&
          other.diagnosisLabel == this.diagnosisLabel &&
          other.diagnosisConfidence == this.diagnosisConfidence);
}

class LeafImagesCompanion extends UpdateCompanion<LeafImage> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<DateTime> capturedAt;
  final Value<int> fileSize;
  final Value<int> width;
  final Value<int> height;
  final Value<double?> blurScore;
  final Value<double?> brightnessScore;
  final Value<String?> notes;
  final Value<String?> diagnosisClass;
  final Value<String?> diagnosisLabel;
  final Value<double?> diagnosisConfidence;
  final Value<int> rowid;
  const LeafImagesCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.blurScore = const Value.absent(),
    this.brightnessScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.diagnosisClass = const Value.absent(),
    this.diagnosisLabel = const Value.absent(),
    this.diagnosisConfidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeafImagesCompanion.insert({
    required String id,
    required String filePath,
    required DateTime capturedAt,
    this.fileSize = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.blurScore = const Value.absent(),
    this.brightnessScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.diagnosisClass = const Value.absent(),
    this.diagnosisLabel = const Value.absent(),
    this.diagnosisConfidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       filePath = Value(filePath),
       capturedAt = Value(capturedAt);
  static Insertable<LeafImage> custom({
    Expression<String>? id,
    Expression<String>? filePath,
    Expression<DateTime>? capturedAt,
    Expression<int>? fileSize,
    Expression<int>? width,
    Expression<int>? height,
    Expression<double>? blurScore,
    Expression<double>? brightnessScore,
    Expression<String>? notes,
    Expression<String>? diagnosisClass,
    Expression<String>? diagnosisLabel,
    Expression<double>? diagnosisConfidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (fileSize != null) 'file_size': fileSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (blurScore != null) 'blur_score': blurScore,
      if (brightnessScore != null) 'brightness_score': brightnessScore,
      if (notes != null) 'notes': notes,
      if (diagnosisClass != null) 'diagnosis_class': diagnosisClass,
      if (diagnosisLabel != null) 'diagnosis_label': diagnosisLabel,
      if (diagnosisConfidence != null)
        'diagnosis_confidence': diagnosisConfidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeafImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? filePath,
    Value<DateTime>? capturedAt,
    Value<int>? fileSize,
    Value<int>? width,
    Value<int>? height,
    Value<double?>? blurScore,
    Value<double?>? brightnessScore,
    Value<String?>? notes,
    Value<String?>? diagnosisClass,
    Value<String?>? diagnosisLabel,
    Value<double?>? diagnosisConfidence,
    Value<int>? rowid,
  }) {
    return LeafImagesCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      capturedAt: capturedAt ?? this.capturedAt,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      blurScore: blurScore ?? this.blurScore,
      brightnessScore: brightnessScore ?? this.brightnessScore,
      notes: notes ?? this.notes,
      diagnosisClass: diagnosisClass ?? this.diagnosisClass,
      diagnosisLabel: diagnosisLabel ?? this.diagnosisLabel,
      diagnosisConfidence: diagnosisConfidence ?? this.diagnosisConfidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (blurScore.present) {
      map['blur_score'] = Variable<double>(blurScore.value);
    }
    if (brightnessScore.present) {
      map['brightness_score'] = Variable<double>(brightnessScore.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (diagnosisClass.present) {
      map['diagnosis_class'] = Variable<String>(diagnosisClass.value);
    }
    if (diagnosisLabel.present) {
      map['diagnosis_label'] = Variable<String>(diagnosisLabel.value);
    }
    if (diagnosisConfidence.present) {
      map['diagnosis_confidence'] = Variable<double>(diagnosisConfidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeafImagesCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('fileSize: $fileSize, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('blurScore: $blurScore, ')
          ..write('brightnessScore: $brightnessScore, ')
          ..write('notes: $notes, ')
          ..write('diagnosisClass: $diagnosisClass, ')
          ..write('diagnosisLabel: $diagnosisLabel, ')
          ..write('diagnosisConfidence: $diagnosisConfidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LeafImagesTable leafImages = $LeafImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [leafImages];
}

typedef $$LeafImagesTableCreateCompanionBuilder =
    LeafImagesCompanion Function({
      required String id,
      required String filePath,
      required DateTime capturedAt,
      Value<int> fileSize,
      Value<int> width,
      Value<int> height,
      Value<double?> blurScore,
      Value<double?> brightnessScore,
      Value<String?> notes,
      Value<String?> diagnosisClass,
      Value<String?> diagnosisLabel,
      Value<double?> diagnosisConfidence,
      Value<int> rowid,
    });
typedef $$LeafImagesTableUpdateCompanionBuilder =
    LeafImagesCompanion Function({
      Value<String> id,
      Value<String> filePath,
      Value<DateTime> capturedAt,
      Value<int> fileSize,
      Value<int> width,
      Value<int> height,
      Value<double?> blurScore,
      Value<double?> brightnessScore,
      Value<String?> notes,
      Value<String?> diagnosisClass,
      Value<String?> diagnosisLabel,
      Value<double?> diagnosisConfidence,
      Value<int> rowid,
    });

class $$LeafImagesTableFilterComposer
    extends Composer<_$AppDatabase, $LeafImagesTable> {
  $$LeafImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get blurScore => $composableBuilder(
    column: $table.blurScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brightnessScore => $composableBuilder(
    column: $table.brightnessScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosisClass => $composableBuilder(
    column: $table.diagnosisClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosisLabel => $composableBuilder(
    column: $table.diagnosisLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get diagnosisConfidence => $composableBuilder(
    column: $table.diagnosisConfidence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeafImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LeafImagesTable> {
  $$LeafImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get blurScore => $composableBuilder(
    column: $table.blurScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brightnessScore => $composableBuilder(
    column: $table.brightnessScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosisClass => $composableBuilder(
    column: $table.diagnosisClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosisLabel => $composableBuilder(
    column: $table.diagnosisLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get diagnosisConfidence => $composableBuilder(
    column: $table.diagnosisConfidence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeafImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeafImagesTable> {
  $$LeafImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get blurScore =>
      $composableBuilder(column: $table.blurScore, builder: (column) => column);

  GeneratedColumn<double> get brightnessScore => $composableBuilder(
    column: $table.brightnessScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get diagnosisClass => $composableBuilder(
    column: $table.diagnosisClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diagnosisLabel => $composableBuilder(
    column: $table.diagnosisLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get diagnosisConfidence => $composableBuilder(
    column: $table.diagnosisConfidence,
    builder: (column) => column,
  );
}

class $$LeafImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeafImagesTable,
          LeafImage,
          $$LeafImagesTableFilterComposer,
          $$LeafImagesTableOrderingComposer,
          $$LeafImagesTableAnnotationComposer,
          $$LeafImagesTableCreateCompanionBuilder,
          $$LeafImagesTableUpdateCompanionBuilder,
          (
            LeafImage,
            BaseReferences<_$AppDatabase, $LeafImagesTable, LeafImage>,
          ),
          LeafImage,
          PrefetchHooks Function()
        > {
  $$LeafImagesTableTableManager(_$AppDatabase db, $LeafImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeafImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeafImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeafImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<double?> blurScore = const Value.absent(),
                Value<double?> brightnessScore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> diagnosisClass = const Value.absent(),
                Value<String?> diagnosisLabel = const Value.absent(),
                Value<double?> diagnosisConfidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeafImagesCompanion(
                id: id,
                filePath: filePath,
                capturedAt: capturedAt,
                fileSize: fileSize,
                width: width,
                height: height,
                blurScore: blurScore,
                brightnessScore: brightnessScore,
                notes: notes,
                diagnosisClass: diagnosisClass,
                diagnosisLabel: diagnosisLabel,
                diagnosisConfidence: diagnosisConfidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String filePath,
                required DateTime capturedAt,
                Value<int> fileSize = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<double?> blurScore = const Value.absent(),
                Value<double?> brightnessScore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> diagnosisClass = const Value.absent(),
                Value<String?> diagnosisLabel = const Value.absent(),
                Value<double?> diagnosisConfidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeafImagesCompanion.insert(
                id: id,
                filePath: filePath,
                capturedAt: capturedAt,
                fileSize: fileSize,
                width: width,
                height: height,
                blurScore: blurScore,
                brightnessScore: brightnessScore,
                notes: notes,
                diagnosisClass: diagnosisClass,
                diagnosisLabel: diagnosisLabel,
                diagnosisConfidence: diagnosisConfidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeafImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeafImagesTable,
      LeafImage,
      $$LeafImagesTableFilterComposer,
      $$LeafImagesTableOrderingComposer,
      $$LeafImagesTableAnnotationComposer,
      $$LeafImagesTableCreateCompanionBuilder,
      $$LeafImagesTableUpdateCompanionBuilder,
      (LeafImage, BaseReferences<_$AppDatabase, $LeafImagesTable, LeafImage>),
      LeafImage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LeafImagesTableTableManager get leafImages =>
      $$LeafImagesTableTableManager(_db, _db.leafImages);
}
