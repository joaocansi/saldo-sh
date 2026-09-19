// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountRecordsTable extends AccountRecords
    with TableInfo<$AccountRecordsTable, AccountRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditLimitCentsMeta = const VerificationMeta(
    'creditLimitCents',
  );
  @override
  late final GeneratedColumn<int> creditLimitCents = GeneratedColumn<int>(
    'credit_limit_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _closingDayMeta = const VerificationMeta(
    'closingDay',
  );
  @override
  late final GeneratedColumn<int> closingDay = GeneratedColumn<int>(
    'closing_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorClockMeta = const VerificationMeta(
    'vectorClock',
  );
  @override
  late final GeneratedColumn<String> vectorClock = GeneratedColumn<String>(
    'vector_clock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    openingBalanceCents,
    creditLimitCents,
    closingDay,
    dueDay,
    archived,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit_cents')) {
      context.handle(
        _creditLimitCentsMeta,
        creditLimitCents.isAcceptableOrUnknown(
          data['credit_limit_cents']!,
          _creditLimitCentsMeta,
        ),
      );
    }
    if (data.containsKey('closing_day')) {
      context.handle(
        _closingDayMeta,
        closingDay.isAcceptableOrUnknown(data['closing_day']!, _closingDayMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('vector_clock')) {
      context.handle(
        _vectorClockMeta,
        vectorClock.isAcceptableOrUnknown(
          data['vector_clock']!,
          _vectorClockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      )!,
      creditLimitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_cents'],
      )!,
      closingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_day'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      vectorClock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_clock'],
      )!,
    );
  }

  @override
  $AccountRecordsTable createAlias(String alias) {
    return $AccountRecordsTable(attachedDatabase, alias);
  }
}

class AccountRecord extends DataClass implements Insertable<AccountRecord> {
  final String id;
  final String name;
  final String kind;
  final int openingBalanceCents;
  final int creditLimitCents;
  final int closingDay;
  final int dueDay;
  final bool archived;
  final int updatedAt;
  final int? deletedAt;
  final String originDeviceId;
  final String vectorClock;
  const AccountRecord({
    required this.id,
    required this.name,
    required this.kind,
    required this.openingBalanceCents,
    required this.creditLimitCents,
    required this.closingDay,
    required this.dueDay,
    required this.archived,
    required this.updatedAt,
    this.deletedAt,
    required this.originDeviceId,
    required this.vectorClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    map['credit_limit_cents'] = Variable<int>(creditLimitCents);
    map['closing_day'] = Variable<int>(closingDay);
    map['due_day'] = Variable<int>(dueDay);
    map['archived'] = Variable<bool>(archived);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['vector_clock'] = Variable<String>(vectorClock);
    return map;
  }

  AccountRecordsCompanion toCompanion(bool nullToAbsent) {
    return AccountRecordsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      openingBalanceCents: Value(openingBalanceCents),
      creditLimitCents: Value(creditLimitCents),
      closingDay: Value(closingDay),
      dueDay: Value(dueDay),
      archived: Value(archived),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      originDeviceId: Value(originDeviceId),
      vectorClock: Value(vectorClock),
    );
  }

  factory AccountRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      openingBalanceCents: serializer.fromJson<int>(
        json['openingBalanceCents'],
      ),
      creditLimitCents: serializer.fromJson<int>(json['creditLimitCents']),
      closingDay: serializer.fromJson<int>(json['closingDay']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      archived: serializer.fromJson<bool>(json['archived']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      vectorClock: serializer.fromJson<String>(json['vectorClock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'openingBalanceCents': serializer.toJson<int>(openingBalanceCents),
      'creditLimitCents': serializer.toJson<int>(creditLimitCents),
      'closingDay': serializer.toJson<int>(closingDay),
      'dueDay': serializer.toJson<int>(dueDay),
      'archived': serializer.toJson<bool>(archived),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'vectorClock': serializer.toJson<String>(vectorClock),
    };
  }

  AccountRecord copyWith({
    String? id,
    String? name,
    String? kind,
    int? openingBalanceCents,
    int? creditLimitCents,
    int? closingDay,
    int? dueDay,
    bool? archived,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? originDeviceId,
    String? vectorClock,
  }) => AccountRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    creditLimitCents: creditLimitCents ?? this.creditLimitCents,
    closingDay: closingDay ?? this.closingDay,
    dueDay: dueDay ?? this.dueDay,
    archived: archived ?? this.archived,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    vectorClock: vectorClock ?? this.vectorClock,
  );
  AccountRecord copyWithCompanion(AccountRecordsCompanion data) {
    return AccountRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
      creditLimitCents: data.creditLimitCents.present
          ? data.creditLimitCents.value
          : this.creditLimitCents,
      closingDay: data.closingDay.present
          ? data.closingDay.value
          : this.closingDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      archived: data.archived.present ? data.archived.value : this.archived,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      vectorClock: data.vectorClock.present
          ? data.vectorClock.value
          : this.vectorClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('creditLimitCents: $creditLimitCents, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('archived: $archived, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    openingBalanceCents,
    creditLimitCents,
    closingDay,
    dueDay,
    archived,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.openingBalanceCents == this.openingBalanceCents &&
          other.creditLimitCents == this.creditLimitCents &&
          other.closingDay == this.closingDay &&
          other.dueDay == this.dueDay &&
          other.archived == this.archived &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.vectorClock == this.vectorClock);
}

class AccountRecordsCompanion extends UpdateCompanion<AccountRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> openingBalanceCents;
  final Value<int> creditLimitCents;
  final Value<int> closingDay;
  final Value<int> dueDay;
  final Value<bool> archived;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> originDeviceId;
  final Value<String> vectorClock;
  final Value<int> rowid;
  const AccountRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.creditLimitCents = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.archived = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountRecordsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    this.openingBalanceCents = const Value.absent(),
    this.creditLimitCents = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.archived = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String originDeviceId,
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       updatedAt = Value(updatedAt),
       originDeviceId = Value(originDeviceId);
  static Insertable<AccountRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? openingBalanceCents,
    Expression<int>? creditLimitCents,
    Expression<int>? closingDay,
    Expression<int>? dueDay,
    Expression<bool>? archived,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? originDeviceId,
    Expression<String>? vectorClock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (creditLimitCents != null) 'credit_limit_cents': creditLimitCents,
      if (closingDay != null) 'closing_day': closingDay,
      if (dueDay != null) 'due_day': dueDay,
      if (archived != null) 'archived': archived,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (vectorClock != null) 'vector_clock': vectorClock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? openingBalanceCents,
    Value<int>? creditLimitCents,
    Value<int>? closingDay,
    Value<int>? dueDay,
    Value<bool>? archived,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? originDeviceId,
    Value<String>? vectorClock,
    Value<int>? rowid,
  }) {
    return AccountRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      creditLimitCents: creditLimitCents ?? this.creditLimitCents,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      archived: archived ?? this.archived,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      vectorClock: vectorClock ?? this.vectorClock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (creditLimitCents.present) {
      map['credit_limit_cents'] = Variable<int>(creditLimitCents.value);
    }
    if (closingDay.present) {
      map['closing_day'] = Variable<int>(closingDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (vectorClock.present) {
      map['vector_clock'] = Variable<String>(vectorClock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('creditLimitCents: $creditLimitCents, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('archived: $archived, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionRecordsTable extends TransactionRecords
    with TableInfo<$TransactionRecordsTable, TransactionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<int> transactionDate = GeneratedColumn<int>(
    'transaction_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAccountIdMeta = const VerificationMeta(
    'targetAccountId',
  );
  @override
  late final GeneratedColumn<String> targetAccountId = GeneratedColumn<String>(
    'target_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentGroupIdMeta =
      const VerificationMeta('installmentGroupId');
  @override
  late final GeneratedColumn<String> installmentGroupId =
      GeneratedColumn<String>(
        'installment_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _installmentCountMeta = const VerificationMeta(
    'installmentCount',
  );
  @override
  late final GeneratedColumn<int> installmentCount = GeneratedColumn<int>(
    'installment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorClockMeta = const VerificationMeta(
    'vectorClock',
  );
  @override
  late final GeneratedColumn<String> vectorClock = GeneratedColumn<String>(
    'vector_clock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    amountCents,
    transactionDate,
    dueDate,
    type,
    accountId,
    targetAccountId,
    status,
    notes,
    recurrence,
    seriesId,
    installmentGroupId,
    installmentNumber,
    installmentCount,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('target_account_id')) {
      context.handle(
        _targetAccountIdMeta,
        targetAccountId.isAcceptableOrUnknown(
          data['target_account_id']!,
          _targetAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('installment_group_id')) {
      context.handle(
        _installmentGroupIdMeta,
        installmentGroupId.isAcceptableOrUnknown(
          data['installment_group_id']!,
          _installmentGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    }
    if (data.containsKey('installment_count')) {
      context.handle(
        _installmentCountMeta,
        installmentCount.isAcceptableOrUnknown(
          data['installment_count']!,
          _installmentCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('vector_clock')) {
      context.handle(
        _vectorClockMeta,
        vectorClock.isAcceptableOrUnknown(
          data['vector_clock']!,
          _vectorClockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      targetAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_account_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      installmentGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installment_group_id'],
      ),
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      installmentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      vectorClock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_clock'],
      )!,
    );
  }

  @override
  $TransactionRecordsTable createAlias(String alias) {
    return $TransactionRecordsTable(attachedDatabase, alias);
  }
}

class TransactionRecord extends DataClass
    implements Insertable<TransactionRecord> {
  final String id;
  final String name;
  final String category;
  final int amountCents;
  final int transactionDate;
  final int dueDate;
  final String type;
  final String accountId;
  final String? targetAccountId;
  final String status;
  final String notes;
  final String recurrence;
  final String? seriesId;
  final String? installmentGroupId;
  final int installmentNumber;
  final int installmentCount;
  final int updatedAt;
  final int? deletedAt;
  final String originDeviceId;
  final String vectorClock;
  const TransactionRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.amountCents,
    required this.transactionDate,
    required this.dueDate,
    required this.type,
    required this.accountId,
    this.targetAccountId,
    required this.status,
    required this.notes,
    required this.recurrence,
    this.seriesId,
    this.installmentGroupId,
    required this.installmentNumber,
    required this.installmentCount,
    required this.updatedAt,
    this.deletedAt,
    required this.originDeviceId,
    required this.vectorClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['amount_cents'] = Variable<int>(amountCents);
    map['transaction_date'] = Variable<int>(transactionDate);
    map['due_date'] = Variable<int>(dueDate);
    map['type'] = Variable<String>(type);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || targetAccountId != null) {
      map['target_account_id'] = Variable<String>(targetAccountId);
    }
    map['status'] = Variable<String>(status);
    map['notes'] = Variable<String>(notes);
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || installmentGroupId != null) {
      map['installment_group_id'] = Variable<String>(installmentGroupId);
    }
    map['installment_number'] = Variable<int>(installmentNumber);
    map['installment_count'] = Variable<int>(installmentCount);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['vector_clock'] = Variable<String>(vectorClock);
    return map;
  }

  TransactionRecordsCompanion toCompanion(bool nullToAbsent) {
    return TransactionRecordsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      amountCents: Value(amountCents),
      transactionDate: Value(transactionDate),
      dueDate: Value(dueDate),
      type: Value(type),
      accountId: Value(accountId),
      targetAccountId: targetAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAccountId),
      status: Value(status),
      notes: Value(notes),
      recurrence: Value(recurrence),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      installmentGroupId: installmentGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentGroupId),
      installmentNumber: Value(installmentNumber),
      installmentCount: Value(installmentCount),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      originDeviceId: Value(originDeviceId),
      vectorClock: Value(vectorClock),
    );
  }

  factory TransactionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      transactionDate: serializer.fromJson<int>(json['transactionDate']),
      dueDate: serializer.fromJson<int>(json['dueDate']),
      type: serializer.fromJson<String>(json['type']),
      accountId: serializer.fromJson<String>(json['accountId']),
      targetAccountId: serializer.fromJson<String?>(json['targetAccountId']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String>(json['notes']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      installmentGroupId: serializer.fromJson<String?>(
        json['installmentGroupId'],
      ),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      installmentCount: serializer.fromJson<int>(json['installmentCount']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      vectorClock: serializer.fromJson<String>(json['vectorClock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'amountCents': serializer.toJson<int>(amountCents),
      'transactionDate': serializer.toJson<int>(transactionDate),
      'dueDate': serializer.toJson<int>(dueDate),
      'type': serializer.toJson<String>(type),
      'accountId': serializer.toJson<String>(accountId),
      'targetAccountId': serializer.toJson<String?>(targetAccountId),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String>(notes),
      'recurrence': serializer.toJson<String>(recurrence),
      'seriesId': serializer.toJson<String?>(seriesId),
      'installmentGroupId': serializer.toJson<String?>(installmentGroupId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'installmentCount': serializer.toJson<int>(installmentCount),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'vectorClock': serializer.toJson<String>(vectorClock),
    };
  }

  TransactionRecord copyWith({
    String? id,
    String? name,
    String? category,
    int? amountCents,
    int? transactionDate,
    int? dueDate,
    String? type,
    String? accountId,
    Value<String?> targetAccountId = const Value.absent(),
    String? status,
    String? notes,
    String? recurrence,
    Value<String?> seriesId = const Value.absent(),
    Value<String?> installmentGroupId = const Value.absent(),
    int? installmentNumber,
    int? installmentCount,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? originDeviceId,
    String? vectorClock,
  }) => TransactionRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    amountCents: amountCents ?? this.amountCents,
    transactionDate: transactionDate ?? this.transactionDate,
    dueDate: dueDate ?? this.dueDate,
    type: type ?? this.type,
    accountId: accountId ?? this.accountId,
    targetAccountId: targetAccountId.present
        ? targetAccountId.value
        : this.targetAccountId,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    recurrence: recurrence ?? this.recurrence,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    installmentGroupId: installmentGroupId.present
        ? installmentGroupId.value
        : this.installmentGroupId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    installmentCount: installmentCount ?? this.installmentCount,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    vectorClock: vectorClock ?? this.vectorClock,
  );
  TransactionRecord copyWithCompanion(TransactionRecordsCompanion data) {
    return TransactionRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      type: data.type.present ? data.type.value : this.type,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      targetAccountId: data.targetAccountId.present
          ? data.targetAccountId.value
          : this.targetAccountId,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      installmentGroupId: data.installmentGroupId.present
          ? data.installmentGroupId.value
          : this.installmentGroupId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      installmentCount: data.installmentCount.present
          ? data.installmentCount.value
          : this.installmentCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      vectorClock: data.vectorClock.present
          ? data.vectorClock.value
          : this.vectorClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('amountCents: $amountCents, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('type: $type, ')
          ..write('accountId: $accountId, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('recurrence: $recurrence, ')
          ..write('seriesId: $seriesId, ')
          ..write('installmentGroupId: $installmentGroupId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    amountCents,
    transactionDate,
    dueDate,
    type,
    accountId,
    targetAccountId,
    status,
    notes,
    recurrence,
    seriesId,
    installmentGroupId,
    installmentNumber,
    installmentCount,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.amountCents == this.amountCents &&
          other.transactionDate == this.transactionDate &&
          other.dueDate == this.dueDate &&
          other.type == this.type &&
          other.accountId == this.accountId &&
          other.targetAccountId == this.targetAccountId &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.recurrence == this.recurrence &&
          other.seriesId == this.seriesId &&
          other.installmentGroupId == this.installmentGroupId &&
          other.installmentNumber == this.installmentNumber &&
          other.installmentCount == this.installmentCount &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.vectorClock == this.vectorClock);
}

class TransactionRecordsCompanion extends UpdateCompanion<TransactionRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<int> amountCents;
  final Value<int> transactionDate;
  final Value<int> dueDate;
  final Value<String> type;
  final Value<String> accountId;
  final Value<String?> targetAccountId;
  final Value<String> status;
  final Value<String> notes;
  final Value<String> recurrence;
  final Value<String?> seriesId;
  final Value<String?> installmentGroupId;
  final Value<int> installmentNumber;
  final Value<int> installmentCount;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> originDeviceId;
  final Value<String> vectorClock;
  final Value<int> rowid;
  const TransactionRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.type = const Value.absent(),
    this.accountId = const Value.absent(),
    this.targetAccountId = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.installmentGroupId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.installmentCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionRecordsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required int amountCents,
    required int transactionDate,
    required int dueDate,
    required String type,
    required String accountId,
    this.targetAccountId = const Value.absent(),
    required String status,
    this.notes = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.installmentGroupId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.installmentCount = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String originDeviceId,
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       amountCents = Value(amountCents),
       transactionDate = Value(transactionDate),
       dueDate = Value(dueDate),
       type = Value(type),
       accountId = Value(accountId),
       status = Value(status),
       updatedAt = Value(updatedAt),
       originDeviceId = Value(originDeviceId);
  static Insertable<TransactionRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? amountCents,
    Expression<int>? transactionDate,
    Expression<int>? dueDate,
    Expression<String>? type,
    Expression<String>? accountId,
    Expression<String>? targetAccountId,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? recurrence,
    Expression<String>? seriesId,
    Expression<String>? installmentGroupId,
    Expression<int>? installmentNumber,
    Expression<int>? installmentCount,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? originDeviceId,
    Expression<String>? vectorClock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (amountCents != null) 'amount_cents': amountCents,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (dueDate != null) 'due_date': dueDate,
      if (type != null) 'type': type,
      if (accountId != null) 'account_id': accountId,
      if (targetAccountId != null) 'target_account_id': targetAccountId,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (recurrence != null) 'recurrence': recurrence,
      if (seriesId != null) 'series_id': seriesId,
      if (installmentGroupId != null)
        'installment_group_id': installmentGroupId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (installmentCount != null) 'installment_count': installmentCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (vectorClock != null) 'vector_clock': vectorClock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<int>? amountCents,
    Value<int>? transactionDate,
    Value<int>? dueDate,
    Value<String>? type,
    Value<String>? accountId,
    Value<String?>? targetAccountId,
    Value<String>? status,
    Value<String>? notes,
    Value<String>? recurrence,
    Value<String?>? seriesId,
    Value<String?>? installmentGroupId,
    Value<int>? installmentNumber,
    Value<int>? installmentCount,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? originDeviceId,
    Value<String>? vectorClock,
    Value<int>? rowid,
  }) {
    return TransactionRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amountCents: amountCents ?? this.amountCents,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      recurrence: recurrence ?? this.recurrence,
      seriesId: seriesId ?? this.seriesId,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      installmentCount: installmentCount ?? this.installmentCount,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      vectorClock: vectorClock ?? this.vectorClock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<int>(transactionDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (targetAccountId.present) {
      map['target_account_id'] = Variable<String>(targetAccountId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (installmentGroupId.present) {
      map['installment_group_id'] = Variable<String>(installmentGroupId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (installmentCount.present) {
      map['installment_count'] = Variable<int>(installmentCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (vectorClock.present) {
      map['vector_clock'] = Variable<String>(vectorClock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('amountCents: $amountCents, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('type: $type, ')
          ..write('accountId: $accountId, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('recurrence: $recurrence, ')
          ..write('seriesId: $seriesId, ')
          ..write('installmentGroupId: $installmentGroupId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetRecordsTable extends BudgetRecords
    with TableInfo<$BudgetRecordsTable, BudgetRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitCentsMeta = const VerificationMeta(
    'limitCents',
  );
  @override
  late final GeneratedColumn<int> limitCents = GeneratedColumn<int>(
    'limit_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorClockMeta = const VerificationMeta(
    'vectorClock',
  );
  @override
  late final GeneratedColumn<String> vectorClock = GeneratedColumn<String>(
    'vector_clock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    limitCents,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('limit_cents')) {
      context.handle(
        _limitCentsMeta,
        limitCents.isAcceptableOrUnknown(data['limit_cents']!, _limitCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_limitCentsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('vector_clock')) {
      context.handle(
        _vectorClockMeta,
        vectorClock.isAcceptableOrUnknown(
          data['vector_clock']!,
          _vectorClockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      limitCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_cents'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      vectorClock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_clock'],
      )!,
    );
  }

  @override
  $BudgetRecordsTable createAlias(String alias) {
    return $BudgetRecordsTable(attachedDatabase, alias);
  }
}

class BudgetRecord extends DataClass implements Insertable<BudgetRecord> {
  final String id;
  final String category;
  final int limitCents;
  final int updatedAt;
  final int? deletedAt;
  final String originDeviceId;
  final String vectorClock;
  const BudgetRecord({
    required this.id,
    required this.category,
    required this.limitCents,
    required this.updatedAt,
    this.deletedAt,
    required this.originDeviceId,
    required this.vectorClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['limit_cents'] = Variable<int>(limitCents);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['vector_clock'] = Variable<String>(vectorClock);
    return map;
  }

  BudgetRecordsCompanion toCompanion(bool nullToAbsent) {
    return BudgetRecordsCompanion(
      id: Value(id),
      category: Value(category),
      limitCents: Value(limitCents),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      originDeviceId: Value(originDeviceId),
      vectorClock: Value(vectorClock),
    );
  }

  factory BudgetRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRecord(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      limitCents: serializer.fromJson<int>(json['limitCents']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      vectorClock: serializer.fromJson<String>(json['vectorClock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'limitCents': serializer.toJson<int>(limitCents),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'vectorClock': serializer.toJson<String>(vectorClock),
    };
  }

  BudgetRecord copyWith({
    String? id,
    String? category,
    int? limitCents,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? originDeviceId,
    String? vectorClock,
  }) => BudgetRecord(
    id: id ?? this.id,
    category: category ?? this.category,
    limitCents: limitCents ?? this.limitCents,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    vectorClock: vectorClock ?? this.vectorClock,
  );
  BudgetRecord copyWithCompanion(BudgetRecordsCompanion data) {
    return BudgetRecord(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      limitCents: data.limitCents.present
          ? data.limitCents.value
          : this.limitCents,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      vectorClock: data.vectorClock.present
          ? data.vectorClock.value
          : this.vectorClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRecord(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('limitCents: $limitCents, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    limitCents,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRecord &&
          other.id == this.id &&
          other.category == this.category &&
          other.limitCents == this.limitCents &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.vectorClock == this.vectorClock);
}

class BudgetRecordsCompanion extends UpdateCompanion<BudgetRecord> {
  final Value<String> id;
  final Value<String> category;
  final Value<int> limitCents;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> originDeviceId;
  final Value<String> vectorClock;
  final Value<int> rowid;
  const BudgetRecordsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.limitCents = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetRecordsCompanion.insert({
    required String id,
    required String category,
    required int limitCents,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String originDeviceId,
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       limitCents = Value(limitCents),
       updatedAt = Value(updatedAt),
       originDeviceId = Value(originDeviceId);
  static Insertable<BudgetRecord> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<int>? limitCents,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? originDeviceId,
    Expression<String>? vectorClock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (limitCents != null) 'limit_cents': limitCents,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (vectorClock != null) 'vector_clock': vectorClock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<int>? limitCents,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? originDeviceId,
    Value<String>? vectorClock,
    Value<int>? rowid,
  }) {
    return BudgetRecordsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      limitCents: limitCents ?? this.limitCents,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      vectorClock: vectorClock ?? this.vectorClock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (limitCents.present) {
      map['limit_cents'] = Variable<int>(limitCents.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (vectorClock.present) {
      map['vector_clock'] = Variable<String>(vectorClock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRecordsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('limitCents: $limitCents, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceRecordsTable extends RecurrenceRecords
    with TableInfo<$RecurrenceRecordsTable, RecurrenceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTemplateJsonMeta =
      const VerificationMeta('transactionTemplateJson');
  @override
  late final GeneratedColumn<String> transactionTemplateJson =
      GeneratedColumn<String>(
        'transaction_template_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<int> startsOn = GeneratedColumn<int>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<int> endsOn = GeneratedColumn<int>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorClockMeta = const VerificationMeta(
    'vectorClock',
  );
  @override
  late final GeneratedColumn<String> vectorClock = GeneratedColumn<String>(
    'vector_clock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionTemplateJson,
    frequency,
    status,
    startsOn,
    endsOn,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurrenceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_template_json')) {
      context.handle(
        _transactionTemplateJsonMeta,
        transactionTemplateJson.isAcceptableOrUnknown(
          data['transaction_template_json']!,
          _transactionTemplateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTemplateJsonMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('vector_clock')) {
      context.handle(
        _vectorClockMeta,
        vectorClock.isAcceptableOrUnknown(
          data['vector_clock']!,
          _vectorClockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionTemplateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_template_json'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_on'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      vectorClock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_clock'],
      )!,
    );
  }

  @override
  $RecurrenceRecordsTable createAlias(String alias) {
    return $RecurrenceRecordsTable(attachedDatabase, alias);
  }
}

class RecurrenceRecord extends DataClass
    implements Insertable<RecurrenceRecord> {
  final String id;
  final String transactionTemplateJson;
  final String frequency;
  final String status;
  final int startsOn;
  final int? endsOn;
  final int updatedAt;
  final int? deletedAt;
  final String originDeviceId;
  final String vectorClock;
  const RecurrenceRecord({
    required this.id,
    required this.transactionTemplateJson,
    required this.frequency,
    required this.status,
    required this.startsOn,
    this.endsOn,
    required this.updatedAt,
    this.deletedAt,
    required this.originDeviceId,
    required this.vectorClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_template_json'] = Variable<String>(
      transactionTemplateJson,
    );
    map['frequency'] = Variable<String>(frequency);
    map['status'] = Variable<String>(status);
    map['starts_on'] = Variable<int>(startsOn);
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<int>(endsOn);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['vector_clock'] = Variable<String>(vectorClock);
    return map;
  }

  RecurrenceRecordsCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceRecordsCompanion(
      id: Value(id),
      transactionTemplateJson: Value(transactionTemplateJson),
      frequency: Value(frequency),
      status: Value(status),
      startsOn: Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      originDeviceId: Value(originDeviceId),
      vectorClock: Value(vectorClock),
    );
  }

  factory RecurrenceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceRecord(
      id: serializer.fromJson<String>(json['id']),
      transactionTemplateJson: serializer.fromJson<String>(
        json['transactionTemplateJson'],
      ),
      frequency: serializer.fromJson<String>(json['frequency']),
      status: serializer.fromJson<String>(json['status']),
      startsOn: serializer.fromJson<int>(json['startsOn']),
      endsOn: serializer.fromJson<int?>(json['endsOn']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      vectorClock: serializer.fromJson<String>(json['vectorClock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionTemplateJson': serializer.toJson<String>(
        transactionTemplateJson,
      ),
      'frequency': serializer.toJson<String>(frequency),
      'status': serializer.toJson<String>(status),
      'startsOn': serializer.toJson<int>(startsOn),
      'endsOn': serializer.toJson<int?>(endsOn),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'vectorClock': serializer.toJson<String>(vectorClock),
    };
  }

  RecurrenceRecord copyWith({
    String? id,
    String? transactionTemplateJson,
    String? frequency,
    String? status,
    int? startsOn,
    Value<int?> endsOn = const Value.absent(),
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? originDeviceId,
    String? vectorClock,
  }) => RecurrenceRecord(
    id: id ?? this.id,
    transactionTemplateJson:
        transactionTemplateJson ?? this.transactionTemplateJson,
    frequency: frequency ?? this.frequency,
    status: status ?? this.status,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    vectorClock: vectorClock ?? this.vectorClock,
  );
  RecurrenceRecord copyWithCompanion(RecurrenceRecordsCompanion data) {
    return RecurrenceRecord(
      id: data.id.present ? data.id.value : this.id,
      transactionTemplateJson: data.transactionTemplateJson.present
          ? data.transactionTemplateJson.value
          : this.transactionTemplateJson,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      status: data.status.present ? data.status.value : this.status,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      vectorClock: data.vectorClock.present
          ? data.vectorClock.value
          : this.vectorClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRecord(')
          ..write('id: $id, ')
          ..write('transactionTemplateJson: $transactionTemplateJson, ')
          ..write('frequency: $frequency, ')
          ..write('status: $status, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionTemplateJson,
    frequency,
    status,
    startsOn,
    endsOn,
    updatedAt,
    deletedAt,
    originDeviceId,
    vectorClock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceRecord &&
          other.id == this.id &&
          other.transactionTemplateJson == this.transactionTemplateJson &&
          other.frequency == this.frequency &&
          other.status == this.status &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.vectorClock == this.vectorClock);
}

class RecurrenceRecordsCompanion extends UpdateCompanion<RecurrenceRecord> {
  final Value<String> id;
  final Value<String> transactionTemplateJson;
  final Value<String> frequency;
  final Value<String> status;
  final Value<int> startsOn;
  final Value<int?> endsOn;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> originDeviceId;
  final Value<String> vectorClock;
  final Value<int> rowid;
  const RecurrenceRecordsCompanion({
    this.id = const Value.absent(),
    this.transactionTemplateJson = const Value.absent(),
    this.frequency = const Value.absent(),
    this.status = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceRecordsCompanion.insert({
    required String id,
    required String transactionTemplateJson,
    required String frequency,
    this.status = const Value.absent(),
    required int startsOn,
    this.endsOn = const Value.absent(),
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String originDeviceId,
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionTemplateJson = Value(transactionTemplateJson),
       frequency = Value(frequency),
       startsOn = Value(startsOn),
       updatedAt = Value(updatedAt),
       originDeviceId = Value(originDeviceId);
  static Insertable<RecurrenceRecord> custom({
    Expression<String>? id,
    Expression<String>? transactionTemplateJson,
    Expression<String>? frequency,
    Expression<String>? status,
    Expression<int>? startsOn,
    Expression<int>? endsOn,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? originDeviceId,
    Expression<String>? vectorClock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionTemplateJson != null)
        'transaction_template_json': transactionTemplateJson,
      if (frequency != null) 'frequency': frequency,
      if (status != null) 'status': status,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (vectorClock != null) 'vector_clock': vectorClock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionTemplateJson,
    Value<String>? frequency,
    Value<String>? status,
    Value<int>? startsOn,
    Value<int?>? endsOn,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? originDeviceId,
    Value<String>? vectorClock,
    Value<int>? rowid,
  }) {
    return RecurrenceRecordsCompanion(
      id: id ?? this.id,
      transactionTemplateJson:
          transactionTemplateJson ?? this.transactionTemplateJson,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      vectorClock: vectorClock ?? this.vectorClock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionTemplateJson.present) {
      map['transaction_template_json'] = Variable<String>(
        transactionTemplateJson.value,
      );
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<int>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<int>(endsOn.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (vectorClock.present) {
      map['vector_clock'] = Variable<String>(vectorClock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('transactionTemplateJson: $transactionTemplateJson, ')
          ..write('frequency: $frequency, ')
          ..write('status: $status, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenceRecordsTable extends PreferenceRecords
    with TableInfo<$PreferenceRecordsTable, PreferenceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _synchronizableMeta = const VerificationMeta(
    'synchronizable',
  );
  @override
  late final GeneratedColumn<bool> synchronizable = GeneratedColumn<bool>(
    'synchronizable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchronizable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorClockMeta = const VerificationMeta(
    'vectorClock',
  );
  @override
  late final GeneratedColumn<String> vectorClock = GeneratedColumn<String>(
    'vector_clock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    valueJson,
    synchronizable,
    updatedAt,
    originDeviceId,
    vectorClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('synchronizable')) {
      context.handle(
        _synchronizableMeta,
        synchronizable.isAcceptableOrUnknown(
          data['synchronizable']!,
          _synchronizableMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('vector_clock')) {
      context.handle(
        _vectorClockMeta,
        vectorClock.isAcceptableOrUnknown(
          data['vector_clock']!,
          _vectorClockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  PreferenceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceRecord(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      synchronizable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchronizable'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      vectorClock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_clock'],
      )!,
    );
  }

  @override
  $PreferenceRecordsTable createAlias(String alias) {
    return $PreferenceRecordsTable(attachedDatabase, alias);
  }
}

class PreferenceRecord extends DataClass
    implements Insertable<PreferenceRecord> {
  final String key;
  final String valueJson;
  final bool synchronizable;
  final int updatedAt;
  final String originDeviceId;
  final String vectorClock;
  const PreferenceRecord({
    required this.key,
    required this.valueJson,
    required this.synchronizable,
    required this.updatedAt,
    required this.originDeviceId,
    required this.vectorClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['synchronizable'] = Variable<bool>(synchronizable);
    map['updated_at'] = Variable<int>(updatedAt);
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['vector_clock'] = Variable<String>(vectorClock);
    return map;
  }

  PreferenceRecordsCompanion toCompanion(bool nullToAbsent) {
    return PreferenceRecordsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      synchronizable: Value(synchronizable),
      updatedAt: Value(updatedAt),
      originDeviceId: Value(originDeviceId),
      vectorClock: Value(vectorClock),
    );
  }

  factory PreferenceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceRecord(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      synchronizable: serializer.fromJson<bool>(json['synchronizable']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      vectorClock: serializer.fromJson<String>(json['vectorClock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'synchronizable': serializer.toJson<bool>(synchronizable),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'vectorClock': serializer.toJson<String>(vectorClock),
    };
  }

  PreferenceRecord copyWith({
    String? key,
    String? valueJson,
    bool? synchronizable,
    int? updatedAt,
    String? originDeviceId,
    String? vectorClock,
  }) => PreferenceRecord(
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    synchronizable: synchronizable ?? this.synchronizable,
    updatedAt: updatedAt ?? this.updatedAt,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    vectorClock: vectorClock ?? this.vectorClock,
  );
  PreferenceRecord copyWithCompanion(PreferenceRecordsCompanion data) {
    return PreferenceRecord(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      synchronizable: data.synchronizable.present
          ? data.synchronizable.value
          : this.synchronizable,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      vectorClock: data.vectorClock.present
          ? data.vectorClock.value
          : this.vectorClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceRecord(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('synchronizable: $synchronizable, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    valueJson,
    synchronizable,
    updatedAt,
    originDeviceId,
    vectorClock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceRecord &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.synchronizable == this.synchronizable &&
          other.updatedAt == this.updatedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.vectorClock == this.vectorClock);
}

class PreferenceRecordsCompanion extends UpdateCompanion<PreferenceRecord> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<bool> synchronizable;
  final Value<int> updatedAt;
  final Value<String> originDeviceId;
  final Value<String> vectorClock;
  final Value<int> rowid;
  const PreferenceRecordsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.synchronizable = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenceRecordsCompanion.insert({
    required String key,
    required String valueJson,
    this.synchronizable = const Value.absent(),
    required int updatedAt,
    required String originDeviceId,
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson),
       updatedAt = Value(updatedAt),
       originDeviceId = Value(originDeviceId);
  static Insertable<PreferenceRecord> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<bool>? synchronizable,
    Expression<int>? updatedAt,
    Expression<String>? originDeviceId,
    Expression<String>? vectorClock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (synchronizable != null) 'synchronizable': synchronizable,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (vectorClock != null) 'vector_clock': vectorClock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenceRecordsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<bool>? synchronizable,
    Value<int>? updatedAt,
    Value<String>? originDeviceId,
    Value<String>? vectorClock,
    Value<int>? rowid,
  }) {
    return PreferenceRecordsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      synchronizable: synchronizable ?? this.synchronizable,
      updatedAt: updatedAt ?? this.updatedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      vectorClock: vectorClock ?? this.vectorClock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (synchronizable.present) {
      map['synchronizable'] = Variable<bool>(synchronizable.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (vectorClock.present) {
      map['vector_clock'] = Variable<String>(vectorClock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceRecordsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('synchronizable: $synchronizable, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String key;
  final String value;
  const SyncMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetadataData copyWith({String? key, String? value}) =>
      SyncMetadataData(key: key ?? this.key, value: value ?? this.value);
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TombstoneRecordsTable extends TombstoneRecords
    with TableInfo<$TombstoneRecordsTable, TombstoneRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TombstoneRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorClockMeta = const VerificationMeta(
    'vectorClock',
  );
  @override
  late final GeneratedColumn<String> vectorClock = GeneratedColumn<String>(
    'vector_clock',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    deletedAt,
    originDeviceId,
    vectorClock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<TombstoneRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('vector_clock')) {
      context.handle(
        _vectorClockMeta,
        vectorClock.isAcceptableOrUnknown(
          data['vector_clock']!,
          _vectorClockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vectorClockMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  TombstoneRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TombstoneRecord(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      vectorClock: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_clock'],
      )!,
    );
  }

  @override
  $TombstoneRecordsTable createAlias(String alias) {
    return $TombstoneRecordsTable(attachedDatabase, alias);
  }
}

class TombstoneRecord extends DataClass implements Insertable<TombstoneRecord> {
  final String entityType;
  final String entityId;
  final int deletedAt;
  final String originDeviceId;
  final String vectorClock;
  const TombstoneRecord({
    required this.entityType,
    required this.entityId,
    required this.deletedAt,
    required this.originDeviceId,
    required this.vectorClock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['deleted_at'] = Variable<int>(deletedAt);
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['vector_clock'] = Variable<String>(vectorClock);
    return map;
  }

  TombstoneRecordsCompanion toCompanion(bool nullToAbsent) {
    return TombstoneRecordsCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      deletedAt: Value(deletedAt),
      originDeviceId: Value(originDeviceId),
      vectorClock: Value(vectorClock),
    );
  }

  factory TombstoneRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TombstoneRecord(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      deletedAt: serializer.fromJson<int>(json['deletedAt']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      vectorClock: serializer.fromJson<String>(json['vectorClock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'deletedAt': serializer.toJson<int>(deletedAt),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'vectorClock': serializer.toJson<String>(vectorClock),
    };
  }

  TombstoneRecord copyWith({
    String? entityType,
    String? entityId,
    int? deletedAt,
    String? originDeviceId,
    String? vectorClock,
  }) => TombstoneRecord(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    deletedAt: deletedAt ?? this.deletedAt,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    vectorClock: vectorClock ?? this.vectorClock,
  );
  TombstoneRecord copyWithCompanion(TombstoneRecordsCompanion data) {
    return TombstoneRecord(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      vectorClock: data.vectorClock.present
          ? data.vectorClock.value
          : this.vectorClock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TombstoneRecord(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityType, entityId, deletedAt, originDeviceId, vectorClock);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TombstoneRecord &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.deletedAt == this.deletedAt &&
          other.originDeviceId == this.originDeviceId &&
          other.vectorClock == this.vectorClock);
}

class TombstoneRecordsCompanion extends UpdateCompanion<TombstoneRecord> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> deletedAt;
  final Value<String> originDeviceId;
  final Value<String> vectorClock;
  final Value<int> rowid;
  const TombstoneRecordsCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.vectorClock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TombstoneRecordsCompanion.insert({
    required String entityType,
    required String entityId,
    required int deletedAt,
    required String originDeviceId,
    required String vectorClock,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       deletedAt = Value(deletedAt),
       originDeviceId = Value(originDeviceId),
       vectorClock = Value(vectorClock);
  static Insertable<TombstoneRecord> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? deletedAt,
    Expression<String>? originDeviceId,
    Expression<String>? vectorClock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (vectorClock != null) 'vector_clock': vectorClock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TombstoneRecordsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? deletedAt,
    Value<String>? originDeviceId,
    Value<String>? vectorClock,
    Value<int>? rowid,
  }) {
    return TombstoneRecordsCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      deletedAt: deletedAt ?? this.deletedAt,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      vectorClock: vectorClock ?? this.vectorClock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (vectorClock.present) {
      map['vector_clock'] = Variable<String>(vectorClock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TombstoneRecordsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('vectorClock: $vectorClock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictRecordsTable extends SyncConflictRecords
    with TableInfo<$SyncConflictRecordsTable, SyncConflictRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localJsonMeta = const VerificationMeta(
    'localJson',
  );
  @override
  late final GeneratedColumn<String> localJson = GeneratedColumn<String>(
    'local_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteJsonMeta = const VerificationMeta(
    'remoteJson',
  );
  @override
  late final GeneratedColumn<String> remoteJson = GeneratedColumn<String>(
    'remote_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    localJson,
    remoteJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(
        _localJsonMeta,
        localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_localJsonMeta);
    }
    if (data.containsKey('remote_json')) {
      context.handle(
        _remoteJsonMeta,
        remoteJson.isAcceptableOrUnknown(data['remote_json']!, _remoteJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      )!,
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncConflictRecordsTable createAlias(String alias) {
    return $SyncConflictRecordsTable(attachedDatabase, alias);
  }
}

class SyncConflictRecord extends DataClass
    implements Insertable<SyncConflictRecord> {
  final String id;
  final String entityType;
  final String entityId;
  final String localJson;
  final String remoteJson;
  final int createdAt;
  const SyncConflictRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localJson,
    required this.remoteJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_json'] = Variable<String>(localJson);
    map['remote_json'] = Variable<String>(remoteJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SyncConflictRecordsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictRecordsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localJson: Value(localJson),
      remoteJson: Value(remoteJson),
      createdAt: Value(createdAt),
    );
  }

  factory SyncConflictRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRecord(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localJson: serializer.fromJson<String>(json['localJson']),
      remoteJson: serializer.fromJson<String>(json['remoteJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localJson': serializer.toJson<String>(localJson),
      'remoteJson': serializer.toJson<String>(remoteJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SyncConflictRecord copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? localJson,
    String? remoteJson,
    int? createdAt,
  }) => SyncConflictRecord(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localJson: localJson ?? this.localJson,
    remoteJson: remoteJson ?? this.remoteJson,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncConflictRecord copyWithCompanion(SyncConflictRecordsCompanion data) {
    return SyncConflictRecord(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRecord(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, entityId, localJson, remoteJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRecord &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localJson == this.localJson &&
          other.remoteJson == this.remoteJson &&
          other.createdAt == this.createdAt);
}

class SyncConflictRecordsCompanion extends UpdateCompanion<SyncConflictRecord> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localJson;
  final Value<String> remoteJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SyncConflictRecordsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictRecordsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String localJson,
    required String remoteJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localJson = Value(localJson),
       remoteJson = Value(remoteJson),
       createdAt = Value(createdAt);
  static Insertable<SyncConflictRecord> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localJson,
    Expression<String>? remoteJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localJson != null) 'local_json': localJson,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localJson,
    Value<String>? remoteJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncConflictRecordsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localJson: localJson ?? this.localJson,
      remoteJson: remoteJson ?? this.remoteJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRecordsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIToolAuditRecordsTable extends AIToolAuditRecords
    with TableInfo<$AIToolAuditRecordsTable, AIToolAuditRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIToolAuditRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskMeta = const VerificationMeta('risk');
  @override
  late final GeneratedColumn<String> risk = GeneratedColumn<String>(
    'risk',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _argumentsSummaryMeta = const VerificationMeta(
    'argumentsSummary',
  );
  @override
  late final GeneratedColumn<String> argumentsSummary = GeneratedColumn<String>(
    'arguments_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    toolName,
    risk,
    argumentsSummary,
    success,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_tool_audit';
  @override
  VerificationContext validateIntegrity(
    Insertable<AIToolAuditRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('risk')) {
      context.handle(
        _riskMeta,
        risk.isAcceptableOrUnknown(data['risk']!, _riskMeta),
      );
    } else if (isInserting) {
      context.missing(_riskMeta);
    }
    if (data.containsKey('arguments_summary')) {
      context.handle(
        _argumentsSummaryMeta,
        argumentsSummary.isAcceptableOrUnknown(
          data['arguments_summary']!,
          _argumentsSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_argumentsSummaryMeta);
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIToolAuditRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIToolAuditRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      )!,
      risk: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk'],
      )!,
      argumentsSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arguments_summary'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AIToolAuditRecordsTable createAlias(String alias) {
    return $AIToolAuditRecordsTable(attachedDatabase, alias);
  }
}

class AIToolAuditRecord extends DataClass
    implements Insertable<AIToolAuditRecord> {
  final String id;
  final String toolName;
  final String risk;
  final String argumentsSummary;
  final bool success;
  final int createdAt;
  const AIToolAuditRecord({
    required this.id,
    required this.toolName,
    required this.risk,
    required this.argumentsSummary,
    required this.success,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tool_name'] = Variable<String>(toolName);
    map['risk'] = Variable<String>(risk);
    map['arguments_summary'] = Variable<String>(argumentsSummary);
    map['success'] = Variable<bool>(success);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AIToolAuditRecordsCompanion toCompanion(bool nullToAbsent) {
    return AIToolAuditRecordsCompanion(
      id: Value(id),
      toolName: Value(toolName),
      risk: Value(risk),
      argumentsSummary: Value(argumentsSummary),
      success: Value(success),
      createdAt: Value(createdAt),
    );
  }

  factory AIToolAuditRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIToolAuditRecord(
      id: serializer.fromJson<String>(json['id']),
      toolName: serializer.fromJson<String>(json['toolName']),
      risk: serializer.fromJson<String>(json['risk']),
      argumentsSummary: serializer.fromJson<String>(json['argumentsSummary']),
      success: serializer.fromJson<bool>(json['success']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'toolName': serializer.toJson<String>(toolName),
      'risk': serializer.toJson<String>(risk),
      'argumentsSummary': serializer.toJson<String>(argumentsSummary),
      'success': serializer.toJson<bool>(success),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AIToolAuditRecord copyWith({
    String? id,
    String? toolName,
    String? risk,
    String? argumentsSummary,
    bool? success,
    int? createdAt,
  }) => AIToolAuditRecord(
    id: id ?? this.id,
    toolName: toolName ?? this.toolName,
    risk: risk ?? this.risk,
    argumentsSummary: argumentsSummary ?? this.argumentsSummary,
    success: success ?? this.success,
    createdAt: createdAt ?? this.createdAt,
  );
  AIToolAuditRecord copyWithCompanion(AIToolAuditRecordsCompanion data) {
    return AIToolAuditRecord(
      id: data.id.present ? data.id.value : this.id,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      risk: data.risk.present ? data.risk.value : this.risk,
      argumentsSummary: data.argumentsSummary.present
          ? data.argumentsSummary.value
          : this.argumentsSummary,
      success: data.success.present ? data.success.value : this.success,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIToolAuditRecord(')
          ..write('id: $id, ')
          ..write('toolName: $toolName, ')
          ..write('risk: $risk, ')
          ..write('argumentsSummary: $argumentsSummary, ')
          ..write('success: $success, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, toolName, risk, argumentsSummary, success, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIToolAuditRecord &&
          other.id == this.id &&
          other.toolName == this.toolName &&
          other.risk == this.risk &&
          other.argumentsSummary == this.argumentsSummary &&
          other.success == this.success &&
          other.createdAt == this.createdAt);
}

class AIToolAuditRecordsCompanion extends UpdateCompanion<AIToolAuditRecord> {
  final Value<String> id;
  final Value<String> toolName;
  final Value<String> risk;
  final Value<String> argumentsSummary;
  final Value<bool> success;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AIToolAuditRecordsCompanion({
    this.id = const Value.absent(),
    this.toolName = const Value.absent(),
    this.risk = const Value.absent(),
    this.argumentsSummary = const Value.absent(),
    this.success = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIToolAuditRecordsCompanion.insert({
    required String id,
    required String toolName,
    required String risk,
    required String argumentsSummary,
    required bool success,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       toolName = Value(toolName),
       risk = Value(risk),
       argumentsSummary = Value(argumentsSummary),
       success = Value(success),
       createdAt = Value(createdAt);
  static Insertable<AIToolAuditRecord> custom({
    Expression<String>? id,
    Expression<String>? toolName,
    Expression<String>? risk,
    Expression<String>? argumentsSummary,
    Expression<bool>? success,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (toolName != null) 'tool_name': toolName,
      if (risk != null) 'risk': risk,
      if (argumentsSummary != null) 'arguments_summary': argumentsSummary,
      if (success != null) 'success': success,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIToolAuditRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? toolName,
    Value<String>? risk,
    Value<String>? argumentsSummary,
    Value<bool>? success,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AIToolAuditRecordsCompanion(
      id: id ?? this.id,
      toolName: toolName ?? this.toolName,
      risk: risk ?? this.risk,
      argumentsSummary: argumentsSummary ?? this.argumentsSummary,
      success: success ?? this.success,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (risk.present) {
      map['risk'] = Variable<String>(risk.value);
    }
    if (argumentsSummary.present) {
      map['arguments_summary'] = Variable<String>(argumentsSummary.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIToolAuditRecordsCompanion(')
          ..write('id: $id, ')
          ..write('toolName: $toolName, ')
          ..write('risk: $risk, ')
          ..write('argumentsSummary: $argumentsSummary, ')
          ..write('success: $success, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIConversationRecordsTable extends AIConversationRecords
    with TableInfo<$AIConversationRecordsTable, AIConversationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIConversationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AIConversationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIConversationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIConversationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AIConversationRecordsTable createAlias(String alias) {
    return $AIConversationRecordsTable(attachedDatabase, alias);
  }
}

class AIConversationRecord extends DataClass
    implements Insertable<AIConversationRecord> {
  final String id;
  final String title;
  final int createdAt;
  final int updatedAt;
  const AIConversationRecord({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AIConversationRecordsCompanion toCompanion(bool nullToAbsent) {
    return AIConversationRecordsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AIConversationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIConversationRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AIConversationRecord copyWith({
    String? id,
    String? title,
    int? createdAt,
    int? updatedAt,
  }) => AIConversationRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AIConversationRecord copyWithCompanion(AIConversationRecordsCompanion data) {
    return AIConversationRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIConversationRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIConversationRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AIConversationRecordsCompanion
    extends UpdateCompanion<AIConversationRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AIConversationRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIConversationRecordsCompanion.insert({
    required String id,
    required String title,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AIConversationRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIConversationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AIConversationRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIConversationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIChatMessageRecordsTable extends AIChatMessageRecords
    with TableInfo<$AIChatMessageRecordsTable, AIChatMessageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIChatMessageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ai_conversations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    metadataJson,
    createdAt,
    sequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AIChatMessageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIChatMessageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIChatMessageRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $AIChatMessageRecordsTable createAlias(String alias) {
    return $AIChatMessageRecordsTable(attachedDatabase, alias);
  }
}

class AIChatMessageRecord extends DataClass
    implements Insertable<AIChatMessageRecord> {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final String metadataJson;
  final int createdAt;
  final int sequence;
  const AIChatMessageRecord({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.metadataJson,
    required this.createdAt,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at'] = Variable<int>(createdAt);
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  AIChatMessageRecordsCompanion toCompanion(bool nullToAbsent) {
    return AIChatMessageRecordsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      metadataJson: Value(metadataJson),
      createdAt: Value(createdAt),
      sequence: Value(sequence),
    );
  }

  factory AIChatMessageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIChatMessageRecord(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  AIChatMessageRecord copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? metadataJson,
    int? createdAt,
    int? sequence,
  }) => AIChatMessageRecord(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    metadataJson: metadataJson ?? this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    sequence: sequence ?? this.sequence,
  );
  AIChatMessageRecord copyWithCompanion(AIChatMessageRecordsCompanion data) {
    return AIChatMessageRecord(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIChatMessageRecord(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    metadataJson,
    createdAt,
    sequence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIChatMessageRecord &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.sequence == this.sequence);
}

class AIChatMessageRecordsCompanion
    extends UpdateCompanion<AIChatMessageRecord> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> metadataJson;
  final Value<int> createdAt;
  final Value<int> sequence;
  final Value<int> rowid;
  const AIChatMessageRecordsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIChatMessageRecordsCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.metadataJson = const Value.absent(),
    required int createdAt,
    required int sequence,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt),
       sequence = Value(sequence);
  static Insertable<AIChatMessageRecord> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? sequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (sequence != null) 'sequence': sequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIChatMessageRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String>? metadataJson,
    Value<int>? createdAt,
    Value<int>? sequence,
    Value<int>? rowid,
  }) {
    return AIChatMessageRecordsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      sequence: sequence ?? this.sequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIChatMessageRecordsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('sequence: $sequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountRecordsTable accountRecords = $AccountRecordsTable(this);
  late final $TransactionRecordsTable transactionRecords =
      $TransactionRecordsTable(this);
  late final $BudgetRecordsTable budgetRecords = $BudgetRecordsTable(this);
  late final $RecurrenceRecordsTable recurrenceRecords =
      $RecurrenceRecordsTable(this);
  late final $PreferenceRecordsTable preferenceRecords =
      $PreferenceRecordsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $TombstoneRecordsTable tombstoneRecords = $TombstoneRecordsTable(
    this,
  );
  late final $SyncConflictRecordsTable syncConflictRecords =
      $SyncConflictRecordsTable(this);
  late final $AIToolAuditRecordsTable aIToolAuditRecords =
      $AIToolAuditRecordsTable(this);
  late final $AIConversationRecordsTable aIConversationRecords =
      $AIConversationRecordsTable(this);
  late final $AIChatMessageRecordsTable aIChatMessageRecords =
      $AIChatMessageRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountRecords,
    transactionRecords,
    budgetRecords,
    recurrenceRecords,
    preferenceRecords,
    syncMetadata,
    tombstoneRecords,
    syncConflictRecords,
    aIToolAuditRecords,
    aIConversationRecords,
    aIChatMessageRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ai_conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ai_chat_messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AccountRecordsTableCreateCompanionBuilder =
    AccountRecordsCompanion Function({
      required String id,
      required String name,
      required String kind,
      Value<int> openingBalanceCents,
      Value<int> creditLimitCents,
      Value<int> closingDay,
      Value<int> dueDay,
      Value<bool> archived,
      required int updatedAt,
      Value<int?> deletedAt,
      required String originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });
typedef $$AccountRecordsTableUpdateCompanionBuilder =
    AccountRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<int> openingBalanceCents,
      Value<int> creditLimitCents,
      Value<int> closingDay,
      Value<int> dueDay,
      Value<bool> archived,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });

class $$AccountRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountRecordsTable> {
  $$AccountRecordsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitCents => $composableBuilder(
    column: $table.creditLimitCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountRecordsTable> {
  $$AccountRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitCents => $composableBuilder(
    column: $table.creditLimitCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountRecordsTable> {
  $$AccountRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditLimitCents => $composableBuilder(
    column: $table.creditLimitCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => column,
  );
}

class $$AccountRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountRecordsTable,
          AccountRecord,
          $$AccountRecordsTableFilterComposer,
          $$AccountRecordsTableOrderingComposer,
          $$AccountRecordsTableAnnotationComposer,
          $$AccountRecordsTableCreateCompanionBuilder,
          $$AccountRecordsTableUpdateCompanionBuilder,
          (
            AccountRecord,
            BaseReferences<_$AppDatabase, $AccountRecordsTable, AccountRecord>,
          ),
          AccountRecord,
          PrefetchHooks Function()
        > {
  $$AccountRecordsTableTableManager(
    _$AppDatabase db,
    $AccountRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> openingBalanceCents = const Value.absent(),
                Value<int> creditLimitCents = const Value.absent(),
                Value<int> closingDay = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountRecordsCompanion(
                id: id,
                name: name,
                kind: kind,
                openingBalanceCents: openingBalanceCents,
                creditLimitCents: creditLimitCents,
                closingDay: closingDay,
                dueDay: dueDay,
                archived: archived,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                Value<int> openingBalanceCents = const Value.absent(),
                Value<int> creditLimitCents = const Value.absent(),
                Value<int> closingDay = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String originDeviceId,
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountRecordsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                openingBalanceCents: openingBalanceCents,
                creditLimitCents: creditLimitCents,
                closingDay: closingDay,
                dueDay: dueDay,
                archived: archived,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountRecordsTable, AccountRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AccountRecordsTable,
                    AccountRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountRecordsTable,
      AccountRecord,
      $$AccountRecordsTableFilterComposer,
      $$AccountRecordsTableOrderingComposer,
      $$AccountRecordsTableAnnotationComposer,
      $$AccountRecordsTableCreateCompanionBuilder,
      $$AccountRecordsTableUpdateCompanionBuilder,
      (
        AccountRecord,
        BaseReferences<_$AppDatabase, $AccountRecordsTable, AccountRecord>,
      ),
      AccountRecord,
      PrefetchHooks Function()
    >;
typedef $$TransactionRecordsTableCreateCompanionBuilder =
    TransactionRecordsCompanion Function({
      required String id,
      required String name,
      required String category,
      required int amountCents,
      required int transactionDate,
      required int dueDate,
      required String type,
      required String accountId,
      Value<String?> targetAccountId,
      required String status,
      Value<String> notes,
      Value<String> recurrence,
      Value<String?> seriesId,
      Value<String?> installmentGroupId,
      Value<int> installmentNumber,
      Value<int> installmentCount,
      required int updatedAt,
      Value<int?> deletedAt,
      required String originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });
typedef $$TransactionRecordsTableUpdateCompanionBuilder =
    TransactionRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<int> amountCents,
      Value<int> transactionDate,
      Value<int> dueDate,
      Value<String> type,
      Value<String> accountId,
      Value<String?> targetAccountId,
      Value<String> status,
      Value<String> notes,
      Value<String> recurrence,
      Value<String?> seriesId,
      Value<String?> installmentGroupId,
      Value<int> installmentNumber,
      Value<int> installmentCount,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });

class $$TransactionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionRecordsTable> {
  $$TransactionRecordsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetAccountId => $composableBuilder(
    column: $table.targetAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installmentGroupId => $composableBuilder(
    column: $table.installmentGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionRecordsTable> {
  $$TransactionRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetAccountId => $composableBuilder(
    column: $table.targetAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installmentGroupId => $composableBuilder(
    column: $table.installmentGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionRecordsTable> {
  $$TransactionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get targetAccountId => $composableBuilder(
    column: $table.targetAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get installmentGroupId => $composableBuilder(
    column: $table.installmentGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => column,
  );
}

class $$TransactionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionRecordsTable,
          TransactionRecord,
          $$TransactionRecordsTableFilterComposer,
          $$TransactionRecordsTableOrderingComposer,
          $$TransactionRecordsTableAnnotationComposer,
          $$TransactionRecordsTableCreateCompanionBuilder,
          $$TransactionRecordsTableUpdateCompanionBuilder,
          (
            TransactionRecord,
            BaseReferences<
              _$AppDatabase,
              $TransactionRecordsTable,
              TransactionRecord
            >,
          ),
          TransactionRecord,
          PrefetchHooks Function()
        > {
  $$TransactionRecordsTableTableManager(
    _$AppDatabase db,
    $TransactionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> transactionDate = const Value.absent(),
                Value<int> dueDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> targetAccountId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String?> installmentGroupId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<int> installmentCount = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionRecordsCompanion(
                id: id,
                name: name,
                category: category,
                amountCents: amountCents,
                transactionDate: transactionDate,
                dueDate: dueDate,
                type: type,
                accountId: accountId,
                targetAccountId: targetAccountId,
                status: status,
                notes: notes,
                recurrence: recurrence,
                seriesId: seriesId,
                installmentGroupId: installmentGroupId,
                installmentNumber: installmentNumber,
                installmentCount: installmentCount,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required int amountCents,
                required int transactionDate,
                required int dueDate,
                required String type,
                required String accountId,
                Value<String?> targetAccountId = const Value.absent(),
                required String status,
                Value<String> notes = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String?> installmentGroupId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<int> installmentCount = const Value.absent(),
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String originDeviceId,
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionRecordsCompanion.insert(
                id: id,
                name: name,
                category: category,
                amountCents: amountCents,
                transactionDate: transactionDate,
                dueDate: dueDate,
                type: type,
                accountId: accountId,
                targetAccountId: targetAccountId,
                status: status,
                notes: notes,
                recurrence: recurrence,
                seriesId: seriesId,
                installmentGroupId: installmentGroupId,
                installmentNumber: installmentNumber,
                installmentCount: installmentCount,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionRecordsTable, TransactionRecord>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionRecordsTable,
                    TransactionRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionRecordsTable,
      TransactionRecord,
      $$TransactionRecordsTableFilterComposer,
      $$TransactionRecordsTableOrderingComposer,
      $$TransactionRecordsTableAnnotationComposer,
      $$TransactionRecordsTableCreateCompanionBuilder,
      $$TransactionRecordsTableUpdateCompanionBuilder,
      (
        TransactionRecord,
        BaseReferences<
          _$AppDatabase,
          $TransactionRecordsTable,
          TransactionRecord
        >,
      ),
      TransactionRecord,
      PrefetchHooks Function()
    >;
typedef $$BudgetRecordsTableCreateCompanionBuilder =
    BudgetRecordsCompanion Function({
      required String id,
      required String category,
      required int limitCents,
      required int updatedAt,
      Value<int?> deletedAt,
      required String originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });
typedef $$BudgetRecordsTableUpdateCompanionBuilder =
    BudgetRecordsCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<int> limitCents,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });

class $$BudgetRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetRecordsTable> {
  $$BudgetRecordsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitCents => $composableBuilder(
    column: $table.limitCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetRecordsTable> {
  $$BudgetRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitCents => $composableBuilder(
    column: $table.limitCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetRecordsTable> {
  $$BudgetRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get limitCents => $composableBuilder(
    column: $table.limitCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => column,
  );
}

class $$BudgetRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetRecordsTable,
          BudgetRecord,
          $$BudgetRecordsTableFilterComposer,
          $$BudgetRecordsTableOrderingComposer,
          $$BudgetRecordsTableAnnotationComposer,
          $$BudgetRecordsTableCreateCompanionBuilder,
          $$BudgetRecordsTableUpdateCompanionBuilder,
          (
            BudgetRecord,
            BaseReferences<_$AppDatabase, $BudgetRecordsTable, BudgetRecord>,
          ),
          BudgetRecord,
          PrefetchHooks Function()
        > {
  $$BudgetRecordsTableTableManager(_$AppDatabase db, $BudgetRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> limitCents = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetRecordsCompanion(
                id: id,
                category: category,
                limitCents: limitCents,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required int limitCents,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String originDeviceId,
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetRecordsCompanion.insert(
                id: id,
                category: category,
                limitCents: limitCents,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetRecordsTable, BudgetRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BudgetRecordsTable,
                    BudgetRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetRecordsTable,
      BudgetRecord,
      $$BudgetRecordsTableFilterComposer,
      $$BudgetRecordsTableOrderingComposer,
      $$BudgetRecordsTableAnnotationComposer,
      $$BudgetRecordsTableCreateCompanionBuilder,
      $$BudgetRecordsTableUpdateCompanionBuilder,
      (
        BudgetRecord,
        BaseReferences<_$AppDatabase, $BudgetRecordsTable, BudgetRecord>,
      ),
      BudgetRecord,
      PrefetchHooks Function()
    >;
typedef $$RecurrenceRecordsTableCreateCompanionBuilder =
    RecurrenceRecordsCompanion Function({
      required String id,
      required String transactionTemplateJson,
      required String frequency,
      Value<String> status,
      required int startsOn,
      Value<int?> endsOn,
      required int updatedAt,
      Value<int?> deletedAt,
      required String originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });
typedef $$RecurrenceRecordsTableUpdateCompanionBuilder =
    RecurrenceRecordsCompanion Function({
      Value<String> id,
      Value<String> transactionTemplateJson,
      Value<String> frequency,
      Value<String> status,
      Value<int> startsOn,
      Value<int?> endsOn,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });

class $$RecurrenceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceRecordsTable> {
  $$RecurrenceRecordsTableFilterComposer({
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

  ColumnFilters<String> get transactionTemplateJson => $composableBuilder(
    column: $table.transactionTemplateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurrenceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceRecordsTable> {
  $$RecurrenceRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get transactionTemplateJson => $composableBuilder(
    column: $table.transactionTemplateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurrenceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceRecordsTable> {
  $$RecurrenceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionTemplateJson => $composableBuilder(
    column: $table.transactionTemplateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<int> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => column,
  );
}

class $$RecurrenceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurrenceRecordsTable,
          RecurrenceRecord,
          $$RecurrenceRecordsTableFilterComposer,
          $$RecurrenceRecordsTableOrderingComposer,
          $$RecurrenceRecordsTableAnnotationComposer,
          $$RecurrenceRecordsTableCreateCompanionBuilder,
          $$RecurrenceRecordsTableUpdateCompanionBuilder,
          (
            RecurrenceRecord,
            BaseReferences<
              _$AppDatabase,
              $RecurrenceRecordsTable,
              RecurrenceRecord
            >,
          ),
          RecurrenceRecord,
          PrefetchHooks Function()
        > {
  $$RecurrenceRecordsTableTableManager(
    _$AppDatabase db,
    $RecurrenceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurrenceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionTemplateJson = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startsOn = const Value.absent(),
                Value<int?> endsOn = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceRecordsCompanion(
                id: id,
                transactionTemplateJson: transactionTemplateJson,
                frequency: frequency,
                status: status,
                startsOn: startsOn,
                endsOn: endsOn,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionTemplateJson,
                required String frequency,
                Value<String> status = const Value.absent(),
                required int startsOn,
                Value<int?> endsOn = const Value.absent(),
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String originDeviceId,
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceRecordsCompanion.insert(
                id: id,
                transactionTemplateJson: transactionTemplateJson,
                frequency: frequency,
                status: status,
                startsOn: startsOn,
                endsOn: endsOn,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurrenceRecordsTable, RecurrenceRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecurrenceRecordsTable,
                    RecurrenceRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurrenceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurrenceRecordsTable,
      RecurrenceRecord,
      $$RecurrenceRecordsTableFilterComposer,
      $$RecurrenceRecordsTableOrderingComposer,
      $$RecurrenceRecordsTableAnnotationComposer,
      $$RecurrenceRecordsTableCreateCompanionBuilder,
      $$RecurrenceRecordsTableUpdateCompanionBuilder,
      (
        RecurrenceRecord,
        BaseReferences<
          _$AppDatabase,
          $RecurrenceRecordsTable,
          RecurrenceRecord
        >,
      ),
      RecurrenceRecord,
      PrefetchHooks Function()
    >;
typedef $$PreferenceRecordsTableCreateCompanionBuilder =
    PreferenceRecordsCompanion Function({
      required String key,
      required String valueJson,
      Value<bool> synchronizable,
      required int updatedAt,
      required String originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });
typedef $$PreferenceRecordsTableUpdateCompanionBuilder =
    PreferenceRecordsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<bool> synchronizable,
      Value<int> updatedAt,
      Value<String> originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });

class $$PreferenceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PreferenceRecordsTable> {
  $$PreferenceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchronizable => $composableBuilder(
    column: $table.synchronizable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferenceRecordsTable> {
  $$PreferenceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchronizable => $composableBuilder(
    column: $table.synchronizable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferenceRecordsTable> {
  $$PreferenceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<bool> get synchronizable => $composableBuilder(
    column: $table.synchronizable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => column,
  );
}

class $$PreferenceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferenceRecordsTable,
          PreferenceRecord,
          $$PreferenceRecordsTableFilterComposer,
          $$PreferenceRecordsTableOrderingComposer,
          $$PreferenceRecordsTableAnnotationComposer,
          $$PreferenceRecordsTableCreateCompanionBuilder,
          $$PreferenceRecordsTableUpdateCompanionBuilder,
          (
            PreferenceRecord,
            BaseReferences<
              _$AppDatabase,
              $PreferenceRecordsTable,
              PreferenceRecord
            >,
          ),
          PreferenceRecord,
          PrefetchHooks Function()
        > {
  $$PreferenceRecordsTableTableManager(
    _$AppDatabase db,
    $PreferenceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<bool> synchronizable = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferenceRecordsCompanion(
                key: key,
                valueJson: valueJson,
                synchronizable: synchronizable,
                updatedAt: updatedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                Value<bool> synchronizable = const Value.absent(),
                required int updatedAt,
                required String originDeviceId,
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferenceRecordsCompanion.insert(
                key: key,
                valueJson: valueJson,
                synchronizable: synchronizable,
                updatedAt: updatedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferenceRecordsTable, PreferenceRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PreferenceRecordsTable,
                    PreferenceRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferenceRecordsTable,
      PreferenceRecord,
      $$PreferenceRecordsTableFilterComposer,
      $$PreferenceRecordsTableOrderingComposer,
      $$PreferenceRecordsTableAnnotationComposer,
      $$PreferenceRecordsTableCreateCompanionBuilder,
      $$PreferenceRecordsTableUpdateCompanionBuilder,
      (
        PreferenceRecord,
        BaseReferences<
          _$AppDatabase,
          $PreferenceRecordsTable,
          PreferenceRecord
        >,
      ),
      PreferenceRecord,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetadataTable, SyncMetadataData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncMetadataTable,
                    SyncMetadataData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$TombstoneRecordsTableCreateCompanionBuilder =
    TombstoneRecordsCompanion Function({
      required String entityType,
      required String entityId,
      required int deletedAt,
      required String originDeviceId,
      required String vectorClock,
      Value<int> rowid,
    });
typedef $$TombstoneRecordsTableUpdateCompanionBuilder =
    TombstoneRecordsCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<int> deletedAt,
      Value<String> originDeviceId,
      Value<String> vectorClock,
      Value<int> rowid,
    });

class $$TombstoneRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TombstoneRecordsTable> {
  $$TombstoneRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TombstoneRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TombstoneRecordsTable> {
  $$TombstoneRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TombstoneRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TombstoneRecordsTable> {
  $$TombstoneRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorClock => $composableBuilder(
    column: $table.vectorClock,
    builder: (column) => column,
  );
}

class $$TombstoneRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TombstoneRecordsTable,
          TombstoneRecord,
          $$TombstoneRecordsTableFilterComposer,
          $$TombstoneRecordsTableOrderingComposer,
          $$TombstoneRecordsTableAnnotationComposer,
          $$TombstoneRecordsTableCreateCompanionBuilder,
          $$TombstoneRecordsTableUpdateCompanionBuilder,
          (
            TombstoneRecord,
            BaseReferences<
              _$AppDatabase,
              $TombstoneRecordsTable,
              TombstoneRecord
            >,
          ),
          TombstoneRecord,
          PrefetchHooks Function()
        > {
  $$TombstoneRecordsTableTableManager(
    _$AppDatabase db,
    $TombstoneRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TombstoneRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TombstoneRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TombstoneRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> deletedAt = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<String> vectorClock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TombstoneRecordsCompanion(
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required int deletedAt,
                required String originDeviceId,
                required String vectorClock,
                Value<int> rowid = const Value.absent(),
              }) => TombstoneRecordsCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                deletedAt: deletedAt,
                originDeviceId: originDeviceId,
                vectorClock: vectorClock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TombstoneRecordsTable, TombstoneRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TombstoneRecordsTable,
                    TombstoneRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TombstoneRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TombstoneRecordsTable,
      TombstoneRecord,
      $$TombstoneRecordsTableFilterComposer,
      $$TombstoneRecordsTableOrderingComposer,
      $$TombstoneRecordsTableAnnotationComposer,
      $$TombstoneRecordsTableCreateCompanionBuilder,
      $$TombstoneRecordsTableUpdateCompanionBuilder,
      (
        TombstoneRecord,
        BaseReferences<_$AppDatabase, $TombstoneRecordsTable, TombstoneRecord>,
      ),
      TombstoneRecord,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictRecordsTableCreateCompanionBuilder =
    SyncConflictRecordsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String localJson,
      required String remoteJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SyncConflictRecordsTableUpdateCompanionBuilder =
    SyncConflictRecordsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localJson,
      Value<String> remoteJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SyncConflictRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictRecordsTable> {
  $$SyncConflictRecordsTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictRecordsTable> {
  $$SyncConflictRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictRecordsTable> {
  $$SyncConflictRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncConflictRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictRecordsTable,
          SyncConflictRecord,
          $$SyncConflictRecordsTableFilterComposer,
          $$SyncConflictRecordsTableOrderingComposer,
          $$SyncConflictRecordsTableAnnotationComposer,
          $$SyncConflictRecordsTableCreateCompanionBuilder,
          $$SyncConflictRecordsTableUpdateCompanionBuilder,
          (
            SyncConflictRecord,
            BaseReferences<
              _$AppDatabase,
              $SyncConflictRecordsTable,
              SyncConflictRecord
            >,
          ),
          SyncConflictRecord,
          PrefetchHooks Function()
        > {
  $$SyncConflictRecordsTableTableManager(
    _$AppDatabase db,
    $SyncConflictRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncConflictRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localJson = const Value.absent(),
                Value<String> remoteJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictRecordsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localJson: localJson,
                remoteJson: remoteJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String localJson,
                required String remoteJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictRecordsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localJson: localJson,
                remoteJson: remoteJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictRecordsTable, SyncConflictRecord>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncConflictRecordsTable,
                    SyncConflictRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictRecordsTable,
      SyncConflictRecord,
      $$SyncConflictRecordsTableFilterComposer,
      $$SyncConflictRecordsTableOrderingComposer,
      $$SyncConflictRecordsTableAnnotationComposer,
      $$SyncConflictRecordsTableCreateCompanionBuilder,
      $$SyncConflictRecordsTableUpdateCompanionBuilder,
      (
        SyncConflictRecord,
        BaseReferences<
          _$AppDatabase,
          $SyncConflictRecordsTable,
          SyncConflictRecord
        >,
      ),
      SyncConflictRecord,
      PrefetchHooks Function()
    >;
typedef $$AIToolAuditRecordsTableCreateCompanionBuilder =
    AIToolAuditRecordsCompanion Function({
      required String id,
      required String toolName,
      required String risk,
      required String argumentsSummary,
      required bool success,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AIToolAuditRecordsTableUpdateCompanionBuilder =
    AIToolAuditRecordsCompanion Function({
      Value<String> id,
      Value<String> toolName,
      Value<String> risk,
      Value<String> argumentsSummary,
      Value<bool> success,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$AIToolAuditRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AIToolAuditRecordsTable> {
  $$AIToolAuditRecordsTableFilterComposer({
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

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get risk => $composableBuilder(
    column: $table.risk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get argumentsSummary => $composableBuilder(
    column: $table.argumentsSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AIToolAuditRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AIToolAuditRecordsTable> {
  $$AIToolAuditRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get risk => $composableBuilder(
    column: $table.risk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get argumentsSummary => $composableBuilder(
    column: $table.argumentsSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AIToolAuditRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIToolAuditRecordsTable> {
  $$AIToolAuditRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get risk =>
      $composableBuilder(column: $table.risk, builder: (column) => column);

  GeneratedColumn<String> get argumentsSummary => $composableBuilder(
    column: $table.argumentsSummary,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AIToolAuditRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AIToolAuditRecordsTable,
          AIToolAuditRecord,
          $$AIToolAuditRecordsTableFilterComposer,
          $$AIToolAuditRecordsTableOrderingComposer,
          $$AIToolAuditRecordsTableAnnotationComposer,
          $$AIToolAuditRecordsTableCreateCompanionBuilder,
          $$AIToolAuditRecordsTableUpdateCompanionBuilder,
          (
            AIToolAuditRecord,
            BaseReferences<
              _$AppDatabase,
              $AIToolAuditRecordsTable,
              AIToolAuditRecord
            >,
          ),
          AIToolAuditRecord,
          PrefetchHooks Function()
        > {
  $$AIToolAuditRecordsTableTableManager(
    _$AppDatabase db,
    $AIToolAuditRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIToolAuditRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AIToolAuditRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AIToolAuditRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> toolName = const Value.absent(),
                Value<String> risk = const Value.absent(),
                Value<String> argumentsSummary = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AIToolAuditRecordsCompanion(
                id: id,
                toolName: toolName,
                risk: risk,
                argumentsSummary: argumentsSummary,
                success: success,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String toolName,
                required String risk,
                required String argumentsSummary,
                required bool success,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AIToolAuditRecordsCompanion.insert(
                id: id,
                toolName: toolName,
                risk: risk,
                argumentsSummary: argumentsSummary,
                success: success,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AIToolAuditRecordsTable, AIToolAuditRecord>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AIToolAuditRecordsTable,
                    AIToolAuditRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AIToolAuditRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AIToolAuditRecordsTable,
      AIToolAuditRecord,
      $$AIToolAuditRecordsTableFilterComposer,
      $$AIToolAuditRecordsTableOrderingComposer,
      $$AIToolAuditRecordsTableAnnotationComposer,
      $$AIToolAuditRecordsTableCreateCompanionBuilder,
      $$AIToolAuditRecordsTableUpdateCompanionBuilder,
      (
        AIToolAuditRecord,
        BaseReferences<
          _$AppDatabase,
          $AIToolAuditRecordsTable,
          AIToolAuditRecord
        >,
      ),
      AIToolAuditRecord,
      PrefetchHooks Function()
    >;
typedef $$AIConversationRecordsTableCreateCompanionBuilder =
    AIConversationRecordsCompanion Function({
      required String id,
      required String title,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AIConversationRecordsTableUpdateCompanionBuilder =
    AIConversationRecordsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$AIConversationRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AIConversationRecordsTable,
          AIConversationRecord
        > {
  $$AIConversationRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $AIChatMessageRecordsTable,
    List<AIChatMessageRecord>
  >
  _aIChatMessageRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.aIChatMessageRecords,
        aliasName: 'ai_conversations__id__ai_chat_messages__conversation_id',
      );

  $$AIChatMessageRecordsTableProcessedTableManager
  get aIChatMessageRecordsRefs {
    final manager = $$AIChatMessageRecordsTableTableManager(
      $_db,
      $_db.aIChatMessageRecords,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _aIChatMessageRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AIConversationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AIConversationRecordsTable> {
  $$AIConversationRecordsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> aIChatMessageRecordsRefs(
    Expression<bool> Function($$AIChatMessageRecordsTableFilterComposer f) f,
  ) {
    final $$AIChatMessageRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aIChatMessageRecords,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AIChatMessageRecordsTableFilterComposer(
            $db: $db,
            $table: $db.aIChatMessageRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AIConversationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AIConversationRecordsTable> {
  $$AIConversationRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AIConversationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIConversationRecordsTable> {
  $$AIConversationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> aIChatMessageRecordsRefs<T extends Object>(
    Expression<T> Function($$AIChatMessageRecordsTableAnnotationComposer a) f,
  ) {
    final $$AIChatMessageRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.aIChatMessageRecords,
          getReferencedColumn: (t) => t.conversationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AIChatMessageRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.aIChatMessageRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AIConversationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AIConversationRecordsTable,
          AIConversationRecord,
          $$AIConversationRecordsTableFilterComposer,
          $$AIConversationRecordsTableOrderingComposer,
          $$AIConversationRecordsTableAnnotationComposer,
          $$AIConversationRecordsTableCreateCompanionBuilder,
          $$AIConversationRecordsTableUpdateCompanionBuilder,
          (AIConversationRecord, $$AIConversationRecordsTableReferences),
          AIConversationRecord,
          PrefetchHooks Function({bool aIChatMessageRecordsRefs})
        > {
  $$AIConversationRecordsTableTableManager(
    _$AppDatabase db,
    $AIConversationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIConversationRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AIConversationRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AIConversationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AIConversationRecordsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AIConversationRecordsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $AIConversationRecordsTable,
                    AIConversationRecord
                  >(table),
                  $$AIConversationRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({aIChatMessageRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (aIChatMessageRecordsRefs) db.aIChatMessageRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (aIChatMessageRecordsRefs)
                    await $_getPrefetchedData<
                      AIConversationRecord,
                      $AIConversationRecordsTable,
                      AIChatMessageRecord
                    >(
                      currentTable: table,
                      referencedTable: $$AIConversationRecordsTableReferences
                          ._aIChatMessageRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AIConversationRecordsTableReferences(
                            db,
                            table,
                            p0,
                          ).aIChatMessageRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.conversationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AIConversationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AIConversationRecordsTable,
      AIConversationRecord,
      $$AIConversationRecordsTableFilterComposer,
      $$AIConversationRecordsTableOrderingComposer,
      $$AIConversationRecordsTableAnnotationComposer,
      $$AIConversationRecordsTableCreateCompanionBuilder,
      $$AIConversationRecordsTableUpdateCompanionBuilder,
      (AIConversationRecord, $$AIConversationRecordsTableReferences),
      AIConversationRecord,
      PrefetchHooks Function({bool aIChatMessageRecordsRefs})
    >;
typedef $$AIChatMessageRecordsTableCreateCompanionBuilder =
    AIChatMessageRecordsCompanion Function({
      required String id,
      required String conversationId,
      required String role,
      required String content,
      Value<String> metadataJson,
      required int createdAt,
      required int sequence,
      Value<int> rowid,
    });
typedef $$AIChatMessageRecordsTableUpdateCompanionBuilder =
    AIChatMessageRecordsCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<String> metadataJson,
      Value<int> createdAt,
      Value<int> sequence,
      Value<int> rowid,
    });

final class $$AIChatMessageRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AIChatMessageRecordsTable,
          AIChatMessageRecord
        > {
  $$AIChatMessageRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AIConversationRecordsTable _conversationIdTable(_$AppDatabase db) =>
      db.aIConversationRecords.createAlias(
        'ai_chat_messages__conversation_id__ai_conversations__id',
      );

  $$AIConversationRecordsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$AIConversationRecordsTableTableManager(
      $_db,
      $_db.aIConversationRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AIChatMessageRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AIChatMessageRecordsTable> {
  $$AIChatMessageRecordsTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  $$AIConversationRecordsTableFilterComposer get conversationId {
    final $$AIConversationRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationId,
          referencedTable: $db.aIConversationRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AIConversationRecordsTableFilterComposer(
                $db: $db,
                $table: $db.aIConversationRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AIChatMessageRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AIChatMessageRecordsTable> {
  $$AIChatMessageRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$AIConversationRecordsTableOrderingComposer get conversationId {
    final $$AIConversationRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationId,
          referencedTable: $db.aIConversationRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AIConversationRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.aIConversationRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AIChatMessageRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIChatMessageRecordsTable> {
  $$AIChatMessageRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  $$AIConversationRecordsTableAnnotationComposer get conversationId {
    final $$AIConversationRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.conversationId,
          referencedTable: $db.aIConversationRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AIConversationRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.aIConversationRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AIChatMessageRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AIChatMessageRecordsTable,
          AIChatMessageRecord,
          $$AIChatMessageRecordsTableFilterComposer,
          $$AIChatMessageRecordsTableOrderingComposer,
          $$AIChatMessageRecordsTableAnnotationComposer,
          $$AIChatMessageRecordsTableCreateCompanionBuilder,
          $$AIChatMessageRecordsTableUpdateCompanionBuilder,
          (AIChatMessageRecord, $$AIChatMessageRecordsTableReferences),
          AIChatMessageRecord,
          PrefetchHooks Function({bool conversationId})
        > {
  $$AIChatMessageRecordsTableTableManager(
    _$AppDatabase db,
    $AIChatMessageRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIChatMessageRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AIChatMessageRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AIChatMessageRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AIChatMessageRecordsCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                metadataJson: metadataJson,
                createdAt: createdAt,
                sequence: sequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String role,
                required String content,
                Value<String> metadataJson = const Value.absent(),
                required int createdAt,
                required int sequence,
                Value<int> rowid = const Value.absent(),
              }) => AIChatMessageRecordsCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                metadataJson: metadataJson,
                createdAt: createdAt,
                sequence: sequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AIChatMessageRecordsTable, AIChatMessageRecord>(
                    table,
                  ),
                  $$AIChatMessageRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.conversationId,
                        referencedTable: $$AIChatMessageRecordsTableReferences
                            ._conversationIdTable(db),
                        referencedColumn: $$AIChatMessageRecordsTableReferences
                            ._conversationIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AIChatMessageRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AIChatMessageRecordsTable,
      AIChatMessageRecord,
      $$AIChatMessageRecordsTableFilterComposer,
      $$AIChatMessageRecordsTableOrderingComposer,
      $$AIChatMessageRecordsTableAnnotationComposer,
      $$AIChatMessageRecordsTableCreateCompanionBuilder,
      $$AIChatMessageRecordsTableUpdateCompanionBuilder,
      (AIChatMessageRecord, $$AIChatMessageRecordsTableReferences),
      AIChatMessageRecord,
      PrefetchHooks Function({bool conversationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountRecordsTableTableManager get accountRecords =>
      $$AccountRecordsTableTableManager(_db, _db.accountRecords);
  $$TransactionRecordsTableTableManager get transactionRecords =>
      $$TransactionRecordsTableTableManager(_db, _db.transactionRecords);
  $$BudgetRecordsTableTableManager get budgetRecords =>
      $$BudgetRecordsTableTableManager(_db, _db.budgetRecords);
  $$RecurrenceRecordsTableTableManager get recurrenceRecords =>
      $$RecurrenceRecordsTableTableManager(_db, _db.recurrenceRecords);
  $$PreferenceRecordsTableTableManager get preferenceRecords =>
      $$PreferenceRecordsTableTableManager(_db, _db.preferenceRecords);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$TombstoneRecordsTableTableManager get tombstoneRecords =>
      $$TombstoneRecordsTableTableManager(_db, _db.tombstoneRecords);
  $$SyncConflictRecordsTableTableManager get syncConflictRecords =>
      $$SyncConflictRecordsTableTableManager(_db, _db.syncConflictRecords);
  $$AIToolAuditRecordsTableTableManager get aIToolAuditRecords =>
      $$AIToolAuditRecordsTableTableManager(_db, _db.aIToolAuditRecords);
  $$AIConversationRecordsTableTableManager get aIConversationRecords =>
      $$AIConversationRecordsTableTableManager(_db, _db.aIConversationRecords);
  $$AIChatMessageRecordsTableTableManager get aIChatMessageRecords =>
      $$AIChatMessageRecordsTableTableManager(_db, _db.aIChatMessageRecords);
}
