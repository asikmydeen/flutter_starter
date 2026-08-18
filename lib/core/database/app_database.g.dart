// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TodoRecordsTable extends TodoRecords
    with TableInfo<$TodoRecordsTable, TodoRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    entityId,
    title,
    completed,
    version,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
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
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, entityId};
  @override
  TodoRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoRecord(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $TodoRecordsTable createAlias(String alias) {
    return $TodoRecordsTable(attachedDatabase, alias);
  }
}

class TodoRecord extends DataClass implements Insertable<TodoRecord> {
  final String userId;
  final String entityId;
  final String title;
  final bool completed;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  const TodoRecord({
    required this.userId,
    required this.entityId,
    required this.title,
    required this.completed,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['entity_id'] = Variable<String>(entityId);
    map['title'] = Variable<String>(title);
    map['completed'] = Variable<bool>(completed);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    return map;
  }

  TodoRecordsCompanion toCompanion(bool nullToAbsent) {
    return TodoRecordsCompanion(
      userId: Value(userId),
      entityId: Value(entityId),
      title: Value(title),
      completed: Value(completed),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
    );
  }

  factory TodoRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoRecord(
      userId: serializer.fromJson<String>(json['userId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      title: serializer.fromJson<String>(json['title']),
      completed: serializer.fromJson<bool>(json['completed']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'entityId': serializer.toJson<String>(entityId),
      'title': serializer.toJson<String>(title),
      'completed': serializer.toJson<bool>(completed),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
    };
  }

  TodoRecord copyWith({
    String? userId,
    String? entityId,
    String? title,
    bool? completed,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
  }) => TodoRecord(
    userId: userId ?? this.userId,
    entityId: entityId ?? this.entityId,
    title: title ?? this.title,
    completed: completed ?? this.completed,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
  );
  TodoRecord copyWithCompanion(TodoRecordsCompanion data) {
    return TodoRecord(
      userId: data.userId.present ? data.userId.value : this.userId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      title: data.title.present ? data.title.value : this.title,
      completed: data.completed.present ? data.completed.value : this.completed,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoRecord(')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('title: $title, ')
          ..write('completed: $completed, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    entityId,
    title,
    completed,
    version,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoRecord &&
          other.userId == this.userId &&
          other.entityId == this.entityId &&
          other.title == this.title &&
          other.completed == this.completed &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState);
}

class TodoRecordsCompanion extends UpdateCompanion<TodoRecord> {
  final Value<String> userId;
  final Value<String> entityId;
  final Value<String> title;
  final Value<bool> completed;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<int> rowid;
  const TodoRecordsCompanion({
    this.userId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.title = const Value.absent(),
    this.completed = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoRecordsCompanion.insert({
    required String userId,
    required String entityId,
    required String title,
    required bool completed,
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       entityId = Value(entityId),
       title = Value(title),
       completed = Value(completed),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TodoRecord> custom({
    Expression<String>? userId,
    Expression<String>? entityId,
    Expression<String>? title,
    Expression<bool>? completed,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (entityId != null) 'entity_id': entityId,
      if (title != null) 'title': title,
      if (completed != null) 'completed': completed,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoRecordsCompanion copyWith({
    Value<String>? userId,
    Value<String>? entityId,
    Value<String>? title,
    Value<bool>? completed,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<int>? rowid,
  }) {
    return TodoRecordsCompanion(
      userId: userId ?? this.userId,
      entityId: entityId ?? this.entityId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoRecordsCompanion(')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('title: $title, ')
          ..write('completed: $completed, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxRecordsTable extends OutboxRecords
    with TableInfo<$OutboxRecordsTable, OutboxRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<int> operation = GeneratedColumn<int>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseJsonMeta = const VerificationMeta(
    'baseJson',
  );
  @override
  late final GeneratedColumn<String> baseJson = GeneratedColumn<String>(
    'base_json',
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
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idempotencyKey,
    userId,
    entityId,
    operation,
    baseVersion,
    baseJson,
    localJson,
    attempts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseVersionMeta);
    }
    if (data.containsKey('base_json')) {
      context.handle(
        _baseJsonMeta,
        baseJson.isAcceptableOrUnknown(data['base_json']!, _baseJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_baseJsonMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(
        _localJsonMeta,
        localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_localJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idempotencyKey};
  @override
  OutboxRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRecord(
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operation'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      )!,
      baseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_json'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxRecordsTable createAlias(String alias) {
    return $OutboxRecordsTable(attachedDatabase, alias);
  }
}

class OutboxRecord extends DataClass implements Insertable<OutboxRecord> {
  final String idempotencyKey;
  final String userId;
  final String entityId;
  final int operation;
  final int baseVersion;
  final String baseJson;
  final String localJson;
  final int attempts;
  final DateTime createdAt;
  const OutboxRecord({
    required this.idempotencyKey,
    required this.userId,
    required this.entityId,
    required this.operation,
    required this.baseVersion,
    required this.baseJson,
    required this.localJson,
    required this.attempts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['user_id'] = Variable<String>(userId);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<int>(operation);
    map['base_version'] = Variable<int>(baseVersion);
    map['base_json'] = Variable<String>(baseJson);
    map['local_json'] = Variable<String>(localJson);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxRecordsCompanion toCompanion(bool nullToAbsent) {
    return OutboxRecordsCompanion(
      idempotencyKey: Value(idempotencyKey),
      userId: Value(userId),
      entityId: Value(entityId),
      operation: Value(operation),
      baseVersion: Value(baseVersion),
      baseJson: Value(baseJson),
      localJson: Value(localJson),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRecord(
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      userId: serializer.fromJson<String>(json['userId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<int>(json['operation']),
      baseVersion: serializer.fromJson<int>(json['baseVersion']),
      baseJson: serializer.fromJson<String>(json['baseJson']),
      localJson: serializer.fromJson<String>(json['localJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'userId': serializer.toJson<String>(userId),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<int>(operation),
      'baseVersion': serializer.toJson<int>(baseVersion),
      'baseJson': serializer.toJson<String>(baseJson),
      'localJson': serializer.toJson<String>(localJson),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxRecord copyWith({
    String? idempotencyKey,
    String? userId,
    String? entityId,
    int? operation,
    int? baseVersion,
    String? baseJson,
    String? localJson,
    int? attempts,
    DateTime? createdAt,
  }) => OutboxRecord(
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    userId: userId ?? this.userId,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    baseVersion: baseVersion ?? this.baseVersion,
    baseJson: baseJson ?? this.baseJson,
    localJson: localJson ?? this.localJson,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRecord copyWithCompanion(OutboxRecordsCompanion data) {
    return OutboxRecord(
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      baseJson: data.baseJson.present ? data.baseJson.value : this.baseJson,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRecord(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('baseJson: $baseJson, ')
          ..write('localJson: $localJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idempotencyKey,
    userId,
    entityId,
    operation,
    baseVersion,
    baseJson,
    localJson,
    attempts,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRecord &&
          other.idempotencyKey == this.idempotencyKey &&
          other.userId == this.userId &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.baseVersion == this.baseVersion &&
          other.baseJson == this.baseJson &&
          other.localJson == this.localJson &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class OutboxRecordsCompanion extends UpdateCompanion<OutboxRecord> {
  final Value<String> idempotencyKey;
  final Value<String> userId;
  final Value<String> entityId;
  final Value<int> operation;
  final Value<int> baseVersion;
  final Value<String> baseJson;
  final Value<String> localJson;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OutboxRecordsCompanion({
    this.idempotencyKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.baseJson = const Value.absent(),
    this.localJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxRecordsCompanion.insert({
    required String idempotencyKey,
    required String userId,
    required String entityId,
    required int operation,
    required int baseVersion,
    required String baseJson,
    required String localJson,
    this.attempts = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : idempotencyKey = Value(idempotencyKey),
       userId = Value(userId),
       entityId = Value(entityId),
       operation = Value(operation),
       baseVersion = Value(baseVersion),
       baseJson = Value(baseJson),
       localJson = Value(localJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxRecord> custom({
    Expression<String>? idempotencyKey,
    Expression<String>? userId,
    Expression<String>? entityId,
    Expression<int>? operation,
    Expression<int>? baseVersion,
    Expression<String>? baseJson,
    Expression<String>? localJson,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (userId != null) 'user_id': userId,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (baseVersion != null) 'base_version': baseVersion,
      if (baseJson != null) 'base_json': baseJson,
      if (localJson != null) 'local_json': localJson,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxRecordsCompanion copyWith({
    Value<String>? idempotencyKey,
    Value<String>? userId,
    Value<String>? entityId,
    Value<int>? operation,
    Value<int>? baseVersion,
    Value<String>? baseJson,
    Value<String>? localJson,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxRecordsCompanion(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      userId: userId ?? this.userId,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      baseVersion: baseVersion ?? this.baseVersion,
      baseJson: baseJson ?? this.baseJson,
      localJson: localJson ?? this.localJson,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<int>(operation.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (baseJson.present) {
      map['base_json'] = Variable<String>(baseJson.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRecordsCompanion(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('baseJson: $baseJson, ')
          ..write('localJson: $localJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictRecordsTable extends ConflictRecords
    with TableInfo<$ConflictRecordsTable, ConflictRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _baseJsonMeta = const VerificationMeta(
    'baseJson',
  );
  @override
  late final GeneratedColumn<String> baseJson = GeneratedColumn<String>(
    'base_json',
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
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    entityId,
    baseJson,
    localJson,
    remoteJson,
    fieldsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflict_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('base_json')) {
      context.handle(
        _baseJsonMeta,
        baseJson.isAcceptableOrUnknown(data['base_json']!, _baseJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_baseJsonMeta);
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
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {userId, entityId};
  @override
  ConflictRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictRecord(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      baseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_json'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      )!,
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      )!,
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ConflictRecordsTable createAlias(String alias) {
    return $ConflictRecordsTable(attachedDatabase, alias);
  }
}

class ConflictRecord extends DataClass implements Insertable<ConflictRecord> {
  final String userId;
  final String entityId;
  final String baseJson;
  final String localJson;
  final String remoteJson;
  final String fieldsJson;
  final DateTime createdAt;
  const ConflictRecord({
    required this.userId,
    required this.entityId,
    required this.baseJson,
    required this.localJson,
    required this.remoteJson,
    required this.fieldsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['entity_id'] = Variable<String>(entityId);
    map['base_json'] = Variable<String>(baseJson);
    map['local_json'] = Variable<String>(localJson);
    map['remote_json'] = Variable<String>(remoteJson);
    map['fields_json'] = Variable<String>(fieldsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConflictRecordsCompanion toCompanion(bool nullToAbsent) {
    return ConflictRecordsCompanion(
      userId: Value(userId),
      entityId: Value(entityId),
      baseJson: Value(baseJson),
      localJson: Value(localJson),
      remoteJson: Value(remoteJson),
      fieldsJson: Value(fieldsJson),
      createdAt: Value(createdAt),
    );
  }

  factory ConflictRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictRecord(
      userId: serializer.fromJson<String>(json['userId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      baseJson: serializer.fromJson<String>(json['baseJson']),
      localJson: serializer.fromJson<String>(json['localJson']),
      remoteJson: serializer.fromJson<String>(json['remoteJson']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'entityId': serializer.toJson<String>(entityId),
      'baseJson': serializer.toJson<String>(baseJson),
      'localJson': serializer.toJson<String>(localJson),
      'remoteJson': serializer.toJson<String>(remoteJson),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ConflictRecord copyWith({
    String? userId,
    String? entityId,
    String? baseJson,
    String? localJson,
    String? remoteJson,
    String? fieldsJson,
    DateTime? createdAt,
  }) => ConflictRecord(
    userId: userId ?? this.userId,
    entityId: entityId ?? this.entityId,
    baseJson: baseJson ?? this.baseJson,
    localJson: localJson ?? this.localJson,
    remoteJson: remoteJson ?? this.remoteJson,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ConflictRecord copyWithCompanion(ConflictRecordsCompanion data) {
    return ConflictRecord(
      userId: data.userId.present ? data.userId.value : this.userId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      baseJson: data.baseJson.present ? data.baseJson.value : this.baseJson,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRecord(')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('baseJson: $baseJson, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    entityId,
    baseJson,
    localJson,
    remoteJson,
    fieldsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictRecord &&
          other.userId == this.userId &&
          other.entityId == this.entityId &&
          other.baseJson == this.baseJson &&
          other.localJson == this.localJson &&
          other.remoteJson == this.remoteJson &&
          other.fieldsJson == this.fieldsJson &&
          other.createdAt == this.createdAt);
}

class ConflictRecordsCompanion extends UpdateCompanion<ConflictRecord> {
  final Value<String> userId;
  final Value<String> entityId;
  final Value<String> baseJson;
  final Value<String> localJson;
  final Value<String> remoteJson;
  final Value<String> fieldsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ConflictRecordsCompanion({
    this.userId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.baseJson = const Value.absent(),
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictRecordsCompanion.insert({
    required String userId,
    required String entityId,
    required String baseJson,
    required String localJson,
    required String remoteJson,
    required String fieldsJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       entityId = Value(entityId),
       baseJson = Value(baseJson),
       localJson = Value(localJson),
       remoteJson = Value(remoteJson),
       fieldsJson = Value(fieldsJson),
       createdAt = Value(createdAt);
  static Insertable<ConflictRecord> custom({
    Expression<String>? userId,
    Expression<String>? entityId,
    Expression<String>? baseJson,
    Expression<String>? localJson,
    Expression<String>? remoteJson,
    Expression<String>? fieldsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (entityId != null) 'entity_id': entityId,
      if (baseJson != null) 'base_json': baseJson,
      if (localJson != null) 'local_json': localJson,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictRecordsCompanion copyWith({
    Value<String>? userId,
    Value<String>? entityId,
    Value<String>? baseJson,
    Value<String>? localJson,
    Value<String>? remoteJson,
    Value<String>? fieldsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ConflictRecordsCompanion(
      userId: userId ?? this.userId,
      entityId: entityId ?? this.entityId,
      baseJson: baseJson ?? this.baseJson,
      localJson: localJson ?? this.localJson,
      remoteJson: remoteJson ?? this.remoteJson,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (baseJson.present) {
      map['base_json'] = Variable<String>(baseJson.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRecordsCompanion(')
          ..write('userId: $userId, ')
          ..write('entityId: $entityId, ')
          ..write('baseJson: $baseJson, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCheckpointRecordsTable extends SyncCheckpointRecords
    with TableInfo<$SyncCheckpointRecordsTable, SyncCheckpointRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCheckpointRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchronizedAtMeta = const VerificationMeta(
    'synchronizedAt',
  );
  @override
  late final GeneratedColumn<DateTime> synchronizedAt =
      GeneratedColumn<DateTime>(
        'synchronized_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    collection,
    cursor,
    synchronizedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_checkpoint_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCheckpointRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('synchronized_at')) {
      context.handle(
        _synchronizedAtMeta,
        synchronizedAt.isAcceptableOrUnknown(
          data['synchronized_at']!,
          _synchronizedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, collection};
  @override
  SyncCheckpointRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCheckpointRecord(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      synchronizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synchronized_at'],
      ),
    );
  }

  @override
  $SyncCheckpointRecordsTable createAlias(String alias) {
    return $SyncCheckpointRecordsTable(attachedDatabase, alias);
  }
}

class SyncCheckpointRecord extends DataClass
    implements Insertable<SyncCheckpointRecord> {
  final String userId;
  final String collection;
  final String? cursor;
  final DateTime? synchronizedAt;
  const SyncCheckpointRecord({
    required this.userId,
    required this.collection,
    this.cursor,
    this.synchronizedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['collection'] = Variable<String>(collection);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || synchronizedAt != null) {
      map['synchronized_at'] = Variable<DateTime>(synchronizedAt);
    }
    return map;
  }

  SyncCheckpointRecordsCompanion toCompanion(bool nullToAbsent) {
    return SyncCheckpointRecordsCompanion(
      userId: Value(userId),
      collection: Value(collection),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      synchronizedAt: synchronizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(synchronizedAt),
    );
  }

  factory SyncCheckpointRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCheckpointRecord(
      userId: serializer.fromJson<String>(json['userId']),
      collection: serializer.fromJson<String>(json['collection']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      synchronizedAt: serializer.fromJson<DateTime?>(json['synchronizedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'collection': serializer.toJson<String>(collection),
      'cursor': serializer.toJson<String?>(cursor),
      'synchronizedAt': serializer.toJson<DateTime?>(synchronizedAt),
    };
  }

  SyncCheckpointRecord copyWith({
    String? userId,
    String? collection,
    Value<String?> cursor = const Value.absent(),
    Value<DateTime?> synchronizedAt = const Value.absent(),
  }) => SyncCheckpointRecord(
    userId: userId ?? this.userId,
    collection: collection ?? this.collection,
    cursor: cursor.present ? cursor.value : this.cursor,
    synchronizedAt: synchronizedAt.present
        ? synchronizedAt.value
        : this.synchronizedAt,
  );
  SyncCheckpointRecord copyWithCompanion(SyncCheckpointRecordsCompanion data) {
    return SyncCheckpointRecord(
      userId: data.userId.present ? data.userId.value : this.userId,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      synchronizedAt: data.synchronizedAt.present
          ? data.synchronizedAt.value
          : this.synchronizedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCheckpointRecord(')
          ..write('userId: $userId, ')
          ..write('collection: $collection, ')
          ..write('cursor: $cursor, ')
          ..write('synchronizedAt: $synchronizedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, collection, cursor, synchronizedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCheckpointRecord &&
          other.userId == this.userId &&
          other.collection == this.collection &&
          other.cursor == this.cursor &&
          other.synchronizedAt == this.synchronizedAt);
}

class SyncCheckpointRecordsCompanion
    extends UpdateCompanion<SyncCheckpointRecord> {
  final Value<String> userId;
  final Value<String> collection;
  final Value<String?> cursor;
  final Value<DateTime?> synchronizedAt;
  final Value<int> rowid;
  const SyncCheckpointRecordsCompanion({
    this.userId = const Value.absent(),
    this.collection = const Value.absent(),
    this.cursor = const Value.absent(),
    this.synchronizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCheckpointRecordsCompanion.insert({
    required String userId,
    required String collection,
    this.cursor = const Value.absent(),
    this.synchronizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       collection = Value(collection);
  static Insertable<SyncCheckpointRecord> custom({
    Expression<String>? userId,
    Expression<String>? collection,
    Expression<String>? cursor,
    Expression<DateTime>? synchronizedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (collection != null) 'collection': collection,
      if (cursor != null) 'cursor': cursor,
      if (synchronizedAt != null) 'synchronized_at': synchronizedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCheckpointRecordsCompanion copyWith({
    Value<String>? userId,
    Value<String>? collection,
    Value<String?>? cursor,
    Value<DateTime?>? synchronizedAt,
    Value<int>? rowid,
  }) {
    return SyncCheckpointRecordsCompanion(
      userId: userId ?? this.userId,
      collection: collection ?? this.collection,
      cursor: cursor ?? this.cursor,
      synchronizedAt: synchronizedAt ?? this.synchronizedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (synchronizedAt.present) {
      map['synchronized_at'] = Variable<DateTime>(synchronizedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCheckpointRecordsCompanion(')
          ..write('userId: $userId, ')
          ..write('collection: $collection, ')
          ..write('cursor: $cursor, ')
          ..write('synchronizedAt: $synchronizedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TodoRecordsTable todoRecords = $TodoRecordsTable(this);
  late final $OutboxRecordsTable outboxRecords = $OutboxRecordsTable(this);
  late final $ConflictRecordsTable conflictRecords = $ConflictRecordsTable(
    this,
  );
  late final $SyncCheckpointRecordsTable syncCheckpointRecords =
      $SyncCheckpointRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    todoRecords,
    outboxRecords,
    conflictRecords,
    syncCheckpointRecords,
  ];
}

typedef $$TodoRecordsTableCreateCompanionBuilder =
    TodoRecordsCompanion Function({
      required String userId,
      required String entityId,
      required String title,
      required bool completed,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<int> rowid,
    });
typedef $$TodoRecordsTableUpdateCompanionBuilder =
    TodoRecordsCompanion Function({
      Value<String> userId,
      Value<String> entityId,
      Value<String> title,
      Value<bool> completed,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<int> rowid,
    });

class $$TodoRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoRecordsTable> {
  $$TodoRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoRecordsTable> {
  $$TodoRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoRecordsTable> {
  $$TodoRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$TodoRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoRecordsTable,
          TodoRecord,
          $$TodoRecordsTableFilterComposer,
          $$TodoRecordsTableOrderingComposer,
          $$TodoRecordsTableAnnotationComposer,
          $$TodoRecordsTableCreateCompanionBuilder,
          $$TodoRecordsTableUpdateCompanionBuilder,
          (
            TodoRecord,
            BaseReferences<_$AppDatabase, $TodoRecordsTable, TodoRecord>,
          ),
          TodoRecord,
          PrefetchHooks Function()
        > {
  $$TodoRecordsTableTableManager(_$AppDatabase db, $TodoRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoRecordsCompanion(
                userId: userId,
                entityId: entityId,
                title: title,
                completed: completed,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String entityId,
                required String title,
                required bool completed,
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoRecordsCompanion.insert(
                userId: userId,
                entityId: entityId,
                title: title,
                completed: completed,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoRecordsTable,
      TodoRecord,
      $$TodoRecordsTableFilterComposer,
      $$TodoRecordsTableOrderingComposer,
      $$TodoRecordsTableAnnotationComposer,
      $$TodoRecordsTableCreateCompanionBuilder,
      $$TodoRecordsTableUpdateCompanionBuilder,
      (
        TodoRecord,
        BaseReferences<_$AppDatabase, $TodoRecordsTable, TodoRecord>,
      ),
      TodoRecord,
      PrefetchHooks Function()
    >;
typedef $$OutboxRecordsTableCreateCompanionBuilder =
    OutboxRecordsCompanion Function({
      required String idempotencyKey,
      required String userId,
      required String entityId,
      required int operation,
      required int baseVersion,
      required String baseJson,
      required String localJson,
      Value<int> attempts,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OutboxRecordsTableUpdateCompanionBuilder =
    OutboxRecordsCompanion Function({
      Value<String> idempotencyKey,
      Value<String> userId,
      Value<String> entityId,
      Value<int> operation,
      Value<int> baseVersion,
      Value<String> baseJson,
      Value<String> localJson,
      Value<int> attempts,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$OutboxRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseJson => $composableBuilder(
    column: $table.baseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseJson => $composableBuilder(
    column: $table.baseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxRecordsTable> {
  $$OutboxRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseJson =>
      $composableBuilder(column: $table.baseJson, builder: (column) => column);

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxRecordsTable,
          OutboxRecord,
          $$OutboxRecordsTableFilterComposer,
          $$OutboxRecordsTableOrderingComposer,
          $$OutboxRecordsTableAnnotationComposer,
          $$OutboxRecordsTableCreateCompanionBuilder,
          $$OutboxRecordsTableUpdateCompanionBuilder,
          (
            OutboxRecord,
            BaseReferences<_$AppDatabase, $OutboxRecordsTable, OutboxRecord>,
          ),
          OutboxRecord,
          PrefetchHooks Function()
        > {
  $$OutboxRecordsTableTableManager(_$AppDatabase db, $OutboxRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> operation = const Value.absent(),
                Value<int> baseVersion = const Value.absent(),
                Value<String> baseJson = const Value.absent(),
                Value<String> localJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxRecordsCompanion(
                idempotencyKey: idempotencyKey,
                userId: userId,
                entityId: entityId,
                operation: operation,
                baseVersion: baseVersion,
                baseJson: baseJson,
                localJson: localJson,
                attempts: attempts,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idempotencyKey,
                required String userId,
                required String entityId,
                required int operation,
                required int baseVersion,
                required String baseJson,
                required String localJson,
                Value<int> attempts = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxRecordsCompanion.insert(
                idempotencyKey: idempotencyKey,
                userId: userId,
                entityId: entityId,
                operation: operation,
                baseVersion: baseVersion,
                baseJson: baseJson,
                localJson: localJson,
                attempts: attempts,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxRecordsTable,
      OutboxRecord,
      $$OutboxRecordsTableFilterComposer,
      $$OutboxRecordsTableOrderingComposer,
      $$OutboxRecordsTableAnnotationComposer,
      $$OutboxRecordsTableCreateCompanionBuilder,
      $$OutboxRecordsTableUpdateCompanionBuilder,
      (
        OutboxRecord,
        BaseReferences<_$AppDatabase, $OutboxRecordsTable, OutboxRecord>,
      ),
      OutboxRecord,
      PrefetchHooks Function()
    >;
typedef $$ConflictRecordsTableCreateCompanionBuilder =
    ConflictRecordsCompanion Function({
      required String userId,
      required String entityId,
      required String baseJson,
      required String localJson,
      required String remoteJson,
      required String fieldsJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ConflictRecordsTableUpdateCompanionBuilder =
    ConflictRecordsCompanion Function({
      Value<String> userId,
      Value<String> entityId,
      Value<String> baseJson,
      Value<String> localJson,
      Value<String> remoteJson,
      Value<String> fieldsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ConflictRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictRecordsTable> {
  $$ConflictRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseJson => $composableBuilder(
    column: $table.baseJson,
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

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictRecordsTable> {
  $$ConflictRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseJson => $composableBuilder(
    column: $table.baseJson,
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

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictRecordsTable> {
  $$ConflictRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get baseJson =>
      $composableBuilder(column: $table.baseJson, builder: (column) => column);

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ConflictRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictRecordsTable,
          ConflictRecord,
          $$ConflictRecordsTableFilterComposer,
          $$ConflictRecordsTableOrderingComposer,
          $$ConflictRecordsTableAnnotationComposer,
          $$ConflictRecordsTableCreateCompanionBuilder,
          $$ConflictRecordsTableUpdateCompanionBuilder,
          (
            ConflictRecord,
            BaseReferences<
              _$AppDatabase,
              $ConflictRecordsTable,
              ConflictRecord
            >,
          ),
          ConflictRecord,
          PrefetchHooks Function()
        > {
  $$ConflictRecordsTableTableManager(
    _$AppDatabase db,
    $ConflictRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> baseJson = const Value.absent(),
                Value<String> localJson = const Value.absent(),
                Value<String> remoteJson = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictRecordsCompanion(
                userId: userId,
                entityId: entityId,
                baseJson: baseJson,
                localJson: localJson,
                remoteJson: remoteJson,
                fieldsJson: fieldsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String entityId,
                required String baseJson,
                required String localJson,
                required String remoteJson,
                required String fieldsJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ConflictRecordsCompanion.insert(
                userId: userId,
                entityId: entityId,
                baseJson: baseJson,
                localJson: localJson,
                remoteJson: remoteJson,
                fieldsJson: fieldsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictRecordsTable,
      ConflictRecord,
      $$ConflictRecordsTableFilterComposer,
      $$ConflictRecordsTableOrderingComposer,
      $$ConflictRecordsTableAnnotationComposer,
      $$ConflictRecordsTableCreateCompanionBuilder,
      $$ConflictRecordsTableUpdateCompanionBuilder,
      (
        ConflictRecord,
        BaseReferences<_$AppDatabase, $ConflictRecordsTable, ConflictRecord>,
      ),
      ConflictRecord,
      PrefetchHooks Function()
    >;
typedef $$SyncCheckpointRecordsTableCreateCompanionBuilder =
    SyncCheckpointRecordsCompanion Function({
      required String userId,
      required String collection,
      Value<String?> cursor,
      Value<DateTime?> synchronizedAt,
      Value<int> rowid,
    });
typedef $$SyncCheckpointRecordsTableUpdateCompanionBuilder =
    SyncCheckpointRecordsCompanion Function({
      Value<String> userId,
      Value<String> collection,
      Value<String?> cursor,
      Value<DateTime?> synchronizedAt,
      Value<int> rowid,
    });

class $$SyncCheckpointRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCheckpointRecordsTable> {
  $$SyncCheckpointRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get synchronizedAt => $composableBuilder(
    column: $table.synchronizedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCheckpointRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCheckpointRecordsTable> {
  $$SyncCheckpointRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get synchronizedAt => $composableBuilder(
    column: $table.synchronizedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCheckpointRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCheckpointRecordsTable> {
  $$SyncCheckpointRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get synchronizedAt => $composableBuilder(
    column: $table.synchronizedAt,
    builder: (column) => column,
  );
}

class $$SyncCheckpointRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCheckpointRecordsTable,
          SyncCheckpointRecord,
          $$SyncCheckpointRecordsTableFilterComposer,
          $$SyncCheckpointRecordsTableOrderingComposer,
          $$SyncCheckpointRecordsTableAnnotationComposer,
          $$SyncCheckpointRecordsTableCreateCompanionBuilder,
          $$SyncCheckpointRecordsTableUpdateCompanionBuilder,
          (
            SyncCheckpointRecord,
            BaseReferences<
              _$AppDatabase,
              $SyncCheckpointRecordsTable,
              SyncCheckpointRecord
            >,
          ),
          SyncCheckpointRecord,
          PrefetchHooks Function()
        > {
  $$SyncCheckpointRecordsTableTableManager(
    _$AppDatabase db,
    $SyncCheckpointRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCheckpointRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SyncCheckpointRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncCheckpointRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> collection = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> synchronizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCheckpointRecordsCompanion(
                userId: userId,
                collection: collection,
                cursor: cursor,
                synchronizedAt: synchronizedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String collection,
                Value<String?> cursor = const Value.absent(),
                Value<DateTime?> synchronizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCheckpointRecordsCompanion.insert(
                userId: userId,
                collection: collection,
                cursor: cursor,
                synchronizedAt: synchronizedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCheckpointRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCheckpointRecordsTable,
      SyncCheckpointRecord,
      $$SyncCheckpointRecordsTableFilterComposer,
      $$SyncCheckpointRecordsTableOrderingComposer,
      $$SyncCheckpointRecordsTableAnnotationComposer,
      $$SyncCheckpointRecordsTableCreateCompanionBuilder,
      $$SyncCheckpointRecordsTableUpdateCompanionBuilder,
      (
        SyncCheckpointRecord,
        BaseReferences<
          _$AppDatabase,
          $SyncCheckpointRecordsTable,
          SyncCheckpointRecord
        >,
      ),
      SyncCheckpointRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TodoRecordsTableTableManager get todoRecords =>
      $$TodoRecordsTableTableManager(_db, _db.todoRecords);
  $$OutboxRecordsTableTableManager get outboxRecords =>
      $$OutboxRecordsTableTableManager(_db, _db.outboxRecords);
  $$ConflictRecordsTableTableManager get conflictRecords =>
      $$ConflictRecordsTableTableManager(_db, _db.conflictRecords);
  $$SyncCheckpointRecordsTableTableManager get syncCheckpointRecords =>
      $$SyncCheckpointRecordsTableTableManager(_db, _db.syncCheckpointRecords);
}
