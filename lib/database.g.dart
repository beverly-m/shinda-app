// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TransactionItemsTable extends TransactionItems
    with TableInfo<$TransactionItemsTable, TransactionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _initialPriceMeta =
      const VerificationMeta('initialPrice');
  @override
  late final GeneratedColumn<double> initialPrice = GeneratedColumn<double>(
      'initial_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _productPriceMeta =
      const VerificationMeta('productPrice');
  @override
  late final GeneratedColumn<double> productPrice = GeneratedColumn<double>(
      'product_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitTagMeta =
      const VerificationMeta('unitTag');
  @override
  late final GeneratedColumn<String> unitTag = GeneratedColumn<String>(
      'unit_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        productId,
        productName,
        initialPrice,
        productPrice,
        quantity,
        unitTag,
        image
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('initial_price')) {
      context.handle(
          _initialPriceMeta,
          initialPrice.isAcceptableOrUnknown(
              data['initial_price']!, _initialPriceMeta));
    } else if (isInserting) {
      context.missing(_initialPriceMeta);
    }
    if (data.containsKey('product_price')) {
      context.handle(
          _productPriceMeta,
          productPrice.isAcceptableOrUnknown(
              data['product_price']!, _productPriceMeta));
    } else if (isInserting) {
      context.missing(_productPriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_tag')) {
      context.handle(_unitTagMeta,
          unitTag.isAcceptableOrUnknown(data['unit_tag']!, _unitTagMeta));
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  TransactionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItem(
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      initialPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}initial_price'])!,
      productPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}product_price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_tag']),
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image']),
    );
  }

  @override
  $TransactionItemsTable createAlias(String alias) {
    return $TransactionItemsTable(attachedDatabase, alias);
  }
}

class TransactionItem extends DataClass implements Insertable<TransactionItem> {
  final int productId;
  final String productName;
  final double initialPrice;
  final double productPrice;
  final int quantity;
  final String? unitTag;
  final String? image;
  const TransactionItem(
      {required this.productId,
      required this.productName,
      required this.initialPrice,
      required this.productPrice,
      required this.quantity,
      this.unitTag,
      this.image});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<int>(productId);
    map['product_name'] = Variable<String>(productName);
    map['initial_price'] = Variable<double>(initialPrice);
    map['product_price'] = Variable<double>(productPrice);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || unitTag != null) {
      map['unit_tag'] = Variable<String>(unitTag);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      productId: Value(productId),
      productName: Value(productName),
      initialPrice: Value(initialPrice),
      productPrice: Value(productPrice),
      quantity: Value(quantity),
      unitTag: unitTag == null && nullToAbsent
          ? const Value.absent()
          : Value(unitTag),
      image:
          image == null && nullToAbsent ? const Value.absent() : Value(image),
    );
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItem(
      productId: serializer.fromJson<int>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      initialPrice: serializer.fromJson<double>(json['initialPrice']),
      productPrice: serializer.fromJson<double>(json['productPrice']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitTag: serializer.fromJson<String?>(json['unitTag']),
      image: serializer.fromJson<String?>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<int>(productId),
      'productName': serializer.toJson<String>(productName),
      'initialPrice': serializer.toJson<double>(initialPrice),
      'productPrice': serializer.toJson<double>(productPrice),
      'quantity': serializer.toJson<int>(quantity),
      'unitTag': serializer.toJson<String?>(unitTag),
      'image': serializer.toJson<String?>(image),
    };
  }

  TransactionItem copyWith(
          {int? productId,
          String? productName,
          double? initialPrice,
          double? productPrice,
          int? quantity,
          Value<String?> unitTag = const Value.absent(),
          Value<String?> image = const Value.absent()}) =>
      TransactionItem(
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        initialPrice: initialPrice ?? this.initialPrice,
        productPrice: productPrice ?? this.productPrice,
        quantity: quantity ?? this.quantity,
        unitTag: unitTag.present ? unitTag.value : this.unitTag,
        image: image.present ? image.value : this.image,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionItem(')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('initialPrice: $initialPrice, ')
          ..write('productPrice: $productPrice, ')
          ..write('quantity: $quantity, ')
          ..write('unitTag: $unitTag, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, productName, initialPrice,
      productPrice, quantity, unitTag, image);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItem &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.initialPrice == this.initialPrice &&
          other.productPrice == this.productPrice &&
          other.quantity == this.quantity &&
          other.unitTag == this.unitTag &&
          other.image == this.image);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItem> {
  final Value<int> productId;
  final Value<String> productName;
  final Value<double> initialPrice;
  final Value<double> productPrice;
  final Value<int> quantity;
  final Value<String?> unitTag;
  final Value<String?> image;
  final Value<int> rowid;
  const TransactionItemsCompanion({
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.initialPrice = const Value.absent(),
    this.productPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitTag = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    required int productId,
    required String productName,
    required double initialPrice,
    required double productPrice,
    required int quantity,
    this.unitTag = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : productId = Value(productId),
        productName = Value(productName),
        initialPrice = Value(initialPrice),
        productPrice = Value(productPrice),
        quantity = Value(quantity);
  static Insertable<TransactionItem> custom({
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<double>? initialPrice,
    Expression<double>? productPrice,
    Expression<int>? quantity,
    Expression<String>? unitTag,
    Expression<String>? image,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (initialPrice != null) 'initial_price': initialPrice,
      if (productPrice != null) 'product_price': productPrice,
      if (quantity != null) 'quantity': quantity,
      if (unitTag != null) 'unit_tag': unitTag,
      if (image != null) 'image': image,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionItemsCompanion copyWith(
      {Value<int>? productId,
      Value<String>? productName,
      Value<double>? initialPrice,
      Value<double>? productPrice,
      Value<int>? quantity,
      Value<String?>? unitTag,
      Value<String?>? image,
      Value<int>? rowid}) {
    return TransactionItemsCompanion(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      initialPrice: initialPrice ?? this.initialPrice,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      unitTag: unitTag ?? this.unitTag,
      image: image ?? this.image,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (initialPrice.present) {
      map['initial_price'] = Variable<double>(initialPrice.value);
    }
    if (productPrice.present) {
      map['product_price'] = Variable<double>(productPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitTag.present) {
      map['unit_tag'] = Variable<String>(unitTag.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('initialPrice: $initialPrice, ')
          ..write('productPrice: $productPrice, ')
          ..write('quantity: $quantity, ')
          ..write('unitTag: $unitTag, ')
          ..write('image: $image, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  late final $TransactionItemsTable transactionItems =
      $TransactionItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [transactionItems];
}
