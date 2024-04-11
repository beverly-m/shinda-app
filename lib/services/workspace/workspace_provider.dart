import 'package:shinda_app/utilities/models/cart_model.dart';

abstract class WorkspaceProvider {
  Future<void> createWorkspace({
    required String workspaceName,
    required String creatorId,
  });

  Future<List<Map<String, dynamic>>> getWorkspaceData({required String userId});

  Future<void> addProduct({
    required String workspaceId,
    required String productName,
    String? description,
    required String price,
    required String quantity,
    String? reorderQuantityLevel,
    String? expirationDate,
  });

  Future<List<Map<String, dynamic>>> getProducts({required String workspaceId});

  Future<List<Map<String, dynamic>>> getPOSProducts({required String workspaceId});

  Future<void> addDebtor(
      {required String workspaceId,
      required String clientName,
      required String phoneNumber,
      String? address,
      required double grandTotal,
      required String transactionId});

  Future<List<Map<String, dynamic>>> getDebtors({required String workspaceId});

  Future<Map<String, dynamic>> getDebtor({required String workspaceId, required String transactionId,});

  Future<void> addTransaction({
    required String workspaceId,
    required double subTotal,
    required String? paymentMode,
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
  });

  Future<List<Map<String, dynamic>>> getTransactions(
      {required String workspaceId});
  
  Future<void> updateTransaction({
    required String workspaceId,
    required String transactionId,
    required String paymentMode,
  });

  Future<List<Map<String, dynamic>>> getTransactionItems({
    required String workspaceId,
    required String transactionId,
  });

  Future<Map<String, dynamic>> getDashboardMeta({required String workspaceId});
}
