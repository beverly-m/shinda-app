abstract class WorkspaceProvider {
  Future<void> createWorkspace({
    required String workspaceName,
    required String creatorId,
  });

  Future<List<Map<String, dynamic>>> getWorkspaceData({required String userId});
}
