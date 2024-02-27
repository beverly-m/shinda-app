abstract class WorkspaceProvider {
  Future<void> getWorkspaceDetails({
    required String workspaceName,
    required String creatorId,
  });
}
