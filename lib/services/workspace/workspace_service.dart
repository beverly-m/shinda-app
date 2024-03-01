import 'dart:developer';

import 'package:shinda_app/constants/supabase.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_provider.dart';
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
        quantity_sold,
        quantity_available,
        quantity_defective,
        created_at,
        updated_at
        ''').eq(
        "workspace_id",
        workspaceId,
      );

      for (var element in productsData) {
        log(element.toString());
      }

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
    required List<Map<String, dynamic>> products,
  }) {
    // TODO: implement addDebtor
    throw UnimplementedError();
  }
}
