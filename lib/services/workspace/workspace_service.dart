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
      final productsData = await supabase.from("stock").select('''
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
        ''').eq(
        "workspace_id",
        workspaceId,
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
      final debtorsData = await supabase.from("debtor").select('''
        debtor_id,
        client_name,
        amount_owed,
        phone_number,
        address,
        date_paid,
        transaction:transaction_id (transaction_id, payment_mode, is_paid)
    ''').eq(
        "workspace_id",
        workspaceId,
      );

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
      final transactionsData = await supabase.from("transaction").select('''
        transaction_id,
        grand_total,
        payment_mode,
        is_paid,
        created_at
        ''').eq(
        "workspace_id",
        workspaceId,
      );
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
}
