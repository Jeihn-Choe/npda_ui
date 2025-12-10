import '../entities/inbound_sm_entity.dart';

abstract class InboundSmRepository {
  Stream<List<InboundSmEntity>> get inboundMissionStream;
}
