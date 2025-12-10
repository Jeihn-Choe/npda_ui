import '../entities/outbound_sm_entity.dart';

abstract class OutboundSmRepository {
  Stream<List<OutboundSmEntity>> get outboundSmStream;
}
