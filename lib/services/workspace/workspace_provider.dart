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
}
