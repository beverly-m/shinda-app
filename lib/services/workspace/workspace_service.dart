import 'dart:developer';

import 'package:shinda_app/constants/supabase.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_provider.dart';
import 'package:shinda_app/utilities/models/cart_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkspaceService implements WorkspaceProvider {
  @override
  Future<void> createWorkspace({
    required String workspaceName,
    required String creatorId,
  }) async {
    try {
      await supabase.from("workspace").insert({
        "name": workspaceName,
        "creator_id": creatorId,
      });
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWorkspaceData(
      {required String userId}) async {
    try {
      final workspaceData = await supabase.from("workspace_member").select('''
        workspace_id, 
        workspace:workspace_id ( name, creator_id )
        ''').eq(
        "user_id",
        userId,
      );

      return workspaceData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<void> addProduct({
    required String workspaceId,
    required String productName,
    String? description,
    required String price,
    required String quantity,
    String? reorderQuantityLevel,
    String? expirationDate,
  }) async {
    try {
      double priceDouble = double.parse(price);
      int quantityInt = int.parse(quantity);
      int? reorderQuantityLevelInt;
      DateTime? expirationDateDateTime;

      if (reorderQuantityLevel != null && reorderQuantityLevel.isNotEmpty) {
        reorderQuantityLevelInt = int.parse(reorderQuantityLevel);
      }

      if (expirationDate != null && expirationDate.isNotEmpty) {
        expirationDateDateTime = DateTime.parse(expirationDate);
      }

      List<Map<String, dynamic>> product =
          await supabase.from('product').insert({
        'workspace_id': workspaceId,
        'name': productName,
        'description': description,
        'price': priceDouble
      }).select();

      await supabase.from('stock').insert({
        'product_id': product[0]['product_id'],
        'workspace_id': workspaceId,
        'quantity': quantityInt,
        'expiration_date': expirationDateDateTime != null
            ? '${expirationDateDateTime.year}-${expirationDateDateTime.month}-${expirationDateDateTime.day}'
            : null,
        'reorder_level': reorderQuantityLevelInt ?? '0',
        'quantity_available': quantityInt,
      }).select();
    } on PostgrestException catch (e) {
      log(e.message);
      log(e.code!);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts(
      {required String workspaceId}) async {
    try {
      final productsData = await supabase
          .from("stock")
          .select('''
        product:product_id (product_id, name, description, price),
        stock_id,
        quantity,
        expiration_date,
        reorder_level,
        quantity_sold,
        quantity_available,
        quantity_defective,
        created_at,
        updated_at
        ''')
          .eq(
            "workspace_id",
            workspaceId,
          )
          .order(
            'name',
            referencedTable: 'product',
            ascending: true,
          );

      return productsData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPOSProducts(
      {required String workspaceId}) async {
    try {
      final productsData = await supabase
          .from("stock")
          .select('''
        product:product_id (product_id, name, description, price),
        stock_id,
        quantity,
        expiration_date,
        reorder_level,
        quantity_sold,
        quantity_available,
        quantity_defective,
        created_at,
        updated_at
        ''')
          .eq(
            "workspace_id",
            workspaceId,
          )
          .gt('quantity_available', 0)
          .order(
            'name',
            referencedTable: 'product',
            ascending: true,
          );

      return productsData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<void> updateProduct(
      {required String stockId,
      required String workspaceId,
      required String quantity,
      required String oldQuantity,
      required String quantityAvailable,
      String? expirationDate}) async {
    try {
      int newQuantity = int.parse(oldQuantity) + int.parse(quantity);
      int newQuantityAvailable =
          int.parse(quantity) + int.parse(quantityAvailable);

      DateTime? expirationDateDateTime;

      if (expirationDate != null && expirationDate.isNotEmpty) {
        expirationDateDateTime = DateTime.parse(expirationDate);
      }

      await supabase.from('stock').update({
        'quantity': newQuantity,
        'quantity_available': newQuantityAvailable,
        'expiration_date': expirationDateDateTime != null
            ? '${expirationDateDateTime.year}-${expirationDateDateTime.month}-${expirationDateDateTime.day}'
            : null,
      }).match({'stock_id': stockId, 'workspace_id': workspaceId});
    } on PostgrestException catch (e) {
      log(e.message);
      log(e.hint!);
      log(e.details.toString());
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<void> addDebtor({
    required String workspaceId,
    required String clientName,
    required String phoneNumber,
    String? address,
    required double grandTotal,
    required String transactionId,
  }) async {
    try {
      await supabase.from('debtor').insert({
        'workspace_id': workspaceId,
        'client_name': clientName,
        'amount_owed': grandTotal,
        'phone_number': phoneNumber,
        'transaction_id': transactionId,
        'address': address,
      }).select();
    } on PostgrestException catch (e) {
      log(e.message);
      log(e.hint!);
      log(e.details.toString());
    } catch (e) {
      log("${e.toString()} -- in add debtor");
    }
  }

  @override
  Future<void> addTransaction({
    required String workspaceId,
    required double subTotal,
    String? paymentMode,
    String? discountPercentage,
    String? discountAmount,
    String? taxPercentage,
    String? taxAmount,
    required double grandTotal,
    required bool isPaid,
    required List<Cart> products,
    String? clientName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final List transactionItems = [];

      List<Map<String, dynamic>> transaction =
          await supabase.from('transaction').insert({
        'workspace_id': workspaceId,
        'subtotal': subTotal,
        'payment_mode': paymentMode,
        'grand_total': grandTotal,
        'is_paid': isPaid,
      }).select();

      for (var element in products) {
        transactionItems.add({
          'workspace_id': workspaceId,
          'transaction_id': transaction[0]["transaction_id"],
          'product_id': element.productId,
          'quantity': element.quantity.value,
          'price_per_item': element.productPrice
        });
      }

      await supabase.from('transaction_item').insert(transactionItems);

      if (isPaid == false) {
        await addDebtor(
          workspaceId: workspaceId,
          clientName: clientName!,
          phoneNumber: phoneNumber!,
          address: address,
          grandTotal: grandTotal,
          transactionId: transaction[0]["transaction_id"],
        );
      } else {
        log("The transaction was paid for!");
      }
    } on PostgrestException catch (e) {
      log(e.message);
      log(e.hint!);
      log(e.details.toString());
    } catch (e) {
      log("${e.toString()} -- in add transaction");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDebtors(
      {required String workspaceId}) async {
    try {
      final debtorsData = await supabase
          .from("debtor")
          .select('''
        debtor_id,
        client_name,
        amount_owed,
        phone_number,
        address,
        date_paid,
        transaction:transaction_id (transaction_id, payment_mode, is_paid)
    ''')
          .eq(
            "workspace_id",
            workspaceId,
          )
          .order('created_at');

      for (var element in debtorsData) {
        log(element.toString());
      }

      return debtorsData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions(
      {required String workspaceId}) async {
    try {
      final transactionsData = await supabase
          .from("transaction")
          .select('''
        transaction_id,
        grand_total,
        payment_mode,
        is_paid,
        created_at
        ''')
          .eq(
            "workspace_id",
            workspaceId,
          )
          .order('created_at');
      return transactionsData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionItems({
    required String workspaceId,
    required String transactionId,
  }) async {
    try {
      final transactionItemsData = await supabase
          .from("transaction_item")
          .select('''
        transaction_id,
        product_id,
        quantity,
        price_per_item,
        product:product_id(name)
        ''')
          .eq(
            "workspace_id",
            workspaceId,
          )
          .eq(
            "transaction_id",
            transactionId,
          );
      for (var element in transactionItemsData) {
        log(element.toString());
      }
      return transactionItemsData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<Map<String, dynamic>> getDebtor({
    required String workspaceId,
    required String transactionId,
  }) async {
    try {
      final debtorData = await supabase
          .from("debtor")
          .select('''
            debtor_id,
            client_name,
            amount_owed,
            phone_number,
            address,
            date_paid,
            transaction:transaction_id (transaction_id, payment_mode, is_paid)
          ''')
          .eq(
            'workspace_id',
            workspaceId,
          )
          .eq(
            'transaction_id',
            transactionId,
          )
          .limit(1)
          .single();

      return debtorData;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<void> updateTransaction({
    required String workspaceId,
    required String transactionId,
    required String paymentMode,
  }) async {
    // update payment_mode
    // set is_paid = true

    try {
      await supabase
          .from('transaction')
          .update({'payment_mode': paymentMode, 'is_paid': true})
          .eq('workspace_id', workspaceId)
          .eq('transaction_id', transactionId);
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardMeta(
      {required String workspaceId}) async {
    final Map<String, dynamic> dashboardMeta = {
      'income': 0,
      'momo': 0,
      'cash': 0,
      'card': 0,
      'bank': 0,
      'transactions': 0,
      'productsLowInStock': 0,
      'outstandingPayments': 0,
      'expiredProducts': 0,
      'outstandingPaymentsData': [],
      'expireProductsData': [],
      'productsLowInStockData': [],
      'mostSoldProductsData': {},
      'salesData': [],
    };

    try {
      DateTime timestamp = DateTime.timestamp();
      DateTime timestampTomorrow =
          DateTime.timestamp().add(const Duration(days: 1));
      DateTime timestampWeekAway =
          DateTime.timestamp().add(const Duration(days: 7));

      String today =
          '${timestamp.year}-${timestamp.month > 10 ? timestamp.month : '0${timestamp.month}'}-${timestamp.day > 10 ? timestamp.day : '0${timestamp.day}'}T00:00:00';
      String tomorrow =
          '${timestampTomorrow.year}-${timestampTomorrow.month > 10 ? timestampTomorrow.month : '0${timestampTomorrow.month}'}-${timestampTomorrow.day > 10 ? timestampTomorrow.day : '0${timestampTomorrow.day}'}T00:00:00';
      String weekAway =
          '${timestampWeekAway.year}-${timestampWeekAway.month > 10 ? timestampWeekAway.month : '0${timestampWeekAway.month}'}-${timestampWeekAway.day > 10 ? timestampWeekAway.day : '0${timestampWeekAway.day}'}';

      // TOTAL INCOME, INCOME BREAKDOWN & NUM OF TRANSACTIONS
      await supabase
          .from('transaction')
          .select()
          .lt('created_at', tomorrow)
          .gte('created_at', today)
          .eq('workspace_id', workspaceId)
          .eq('is_paid', true)
          .then((value) {
        // get number of transactions
        dashboardMeta['transactions'] = value.length;

        if (value.isNotEmpty) {
          for (var element in value) {
            // get total income
            dashboardMeta['income'] =
                dashboardMeta['income'] + element['grand_total'];

            // get income from different payment modes
            switch (element['payment_mode']) {
              case 'Mobile money':
                dashboardMeta['momo'] =
                    dashboardMeta['momo'] + element['grand_total'];
                break;
              case 'Cash':
                dashboardMeta['cash'] =
                    dashboardMeta['cash'] + element['grand_total'];
                break;
              case 'Card':
                dashboardMeta['card'] =
                    dashboardMeta['card'] + element['grand_total'];
                break;
              case 'Bank transfer':
                dashboardMeta['bank'] =
                    dashboardMeta['bank'] + element['grand_total'];
                break;
              default:
            }
          }
        }
        log('Daily Income ${dashboardMeta['income']}');
        log('Momo Income ${dashboardMeta['momo']}');
        log('Cash Income ${dashboardMeta['cash']}');
        log('Card Income ${dashboardMeta['card']}');
        log('Bank Transfer Income ${dashboardMeta['bank']}');
        log('Number of transactions ${dashboardMeta['transactions']}');
      });

      // NUM OF PRODUCTS LOW IN STOCK & PRODUCTS LOW IN STOCK
      await supabase.from("stock").select('''
        product:product_id (product_id, name, price),
        stock_id,
        quantity,
        reorder_level,
        quantity_available
        ''').eq('workspace_id', workspaceId).then((value) {
            for (var element in value) {
              // check if quantity is less than or equal to reorder level
              if (element['reorder_level'] >= element['quantity_available']) {
                // get number of products low in stock
                dashboardMeta['productsLowInStock'] =
                    dashboardMeta['productsLowInStock'] + 1;

                dashboardMeta['productsLowInStockData'].add(element);
              }
            }

            log('Number of products ${dashboardMeta['productsLowInStock']}');
            log('Products ${dashboardMeta['productsLowInStockData']}');
          });

      // NUM OF OUTSTANDING PAYMENTS & OUTSTANDING PAYMENTS
      await supabase
          .from('debtor')
          .select('''
              debtor_id,
              client_name,
              amount_owed,
              phone_number,
              address,
              transaction:transaction_id (transaction_id)
          ''')
          .eq('workspace_id', workspaceId)
          .filter('date_paid', 'is', 'null')
          .then((value) {
            // get number of outstanding payments
            dashboardMeta['outstandingPayments'] = value.length;

            // get outstanding payments
            dashboardMeta['outstandingPaymentsData'] = value;

            log('Number of outstanding payments ${dashboardMeta['outstandingPayments']}');

            log('Outstanding payments ${dashboardMeta['outstandingPaymentsData']}');
          });

      // NUM OF PRODUCTS EXPIRING/EXPIRED & PRODUCTS EXPIRING/EXPIRED
      await supabase
          .from('stock')
          .select('''
        product:product_id (product_id, name),
        stock_id,
        quantity,
        expiration_date
        ''')
          .eq('workspace_id', workspaceId)
          .lte('expiration_date', weekAway)
          .order('expiration_date', ascending: true)
          .then((value) {
            dashboardMeta['expiredProducts'] = value.length;

            if (value.isNotEmpty) {
              dashboardMeta['expiredProductsData'] = value;
            }

            log("Expired products: ${dashboardMeta['expiredProductsData']}");
            log("Number of expired products: ${dashboardMeta['expiredProducts']}");
          });

      // MOST SOLD PRODUCTS
      await supabase
          .from('transaction_item')
          .select('''
            product_id, 
            quantity, 
            created_at, 
            product:product_id (product_id, name)
            ''')
          .eq('workspace_id', workspaceId)
          .lt('created_at', tomorrow)
          .gte('created_at', today)
          .then((value) {
            final products = [];
            for (var element in value) {
              // check if product is already recorded
              if (products.contains(element['product_id'])) {
                // increment the quantity
                dashboardMeta['mostSoldProductsData'][element['product_id']]
                    [0] = dashboardMeta['mostSoldProductsData']
                        [element['product_id']][0] +
                    element['quantity'];
              } else {
                // add the product to the list
                dashboardMeta['mostSoldProductsData'].addAll({
                  element['product_id']: [
                    element['quantity'],
                    element['product']['name']
                  ]
                });

                products.add(element['product_id']);
              }
            }
            log("Most sold: ${dashboardMeta['mostSoldProductsData']}");
          });

      // SALES DATA FOR THE PAST 7 DAYS
      await supabase
          .from('week_sales_view')
          .select()
          .eq('workspace_id', workspaceId)
          .then((value) {
        dashboardMeta['salesData'] = value;
        log("Sales overview: ${dashboardMeta['salesData']}");
      });

      return dashboardMeta;
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }

  @override
  Future<void> deleteTransaction(
      {required String transactionId, required String workspaceId}) async {
    try {
      List<Map<String, dynamic>> deletedTransaction =
          await supabase.from('transaction').delete().match({
        'transaction_id': transactionId,
        'workspace_id': workspaceId,
      }).select();

      log("Deleted transaction");
      log(deletedTransaction.toString());
      log(deletedTransaction.length.toString());
    } on PostgrestException catch (e) {
      log(e.code ?? "Error occurred");
      log(e.message);
      throw GenericWorkspaceException();
    } catch (e) {
      log(e.toString());
      throw GenericWorkspaceException();
    }
  }
}
