import 'package:npda_ui_flutter/features/inbound/domain/entities/delete_missions_entity.dart';

abstract class MissionRepository {
  Future<void> deleteMissions(DeleteMissionsEntity entity);
}
