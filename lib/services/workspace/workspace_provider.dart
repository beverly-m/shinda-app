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

    Future<void> addDebtor({
    required String workspaceId,
    required String clientName,
    required String phoneNumber,
    String? address,
    required List<Map<String, dynamic>> products,
  });
}
