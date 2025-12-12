import '../entities/outbound_1f_sm_entity.dart';

abstract class Outbound1FMissionRepository {
  Stream<List<Outbound1fSmEntity>> get outbound1fMissionStream;
}
