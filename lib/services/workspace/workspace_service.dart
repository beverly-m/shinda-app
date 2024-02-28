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
}
