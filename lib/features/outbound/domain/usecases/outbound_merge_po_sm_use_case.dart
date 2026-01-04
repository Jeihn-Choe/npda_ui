import 'dart:async';

import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_sm_entity.dart';
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_po_repository.dart';

import '../entities/outbound_po_entity.dart';
import '../repositories/outbound_sm_repository.dart';

class OutboundMergePoSmUseCase {
  final OutboundSmRepository _smRepository;
  final OutboundPoRepository _poRepository;

  OutboundMergePoSmUseCase(this._smRepository, this._poRepository);

  Stream<List<OutboundPoEntity>> call() {
    final outboundMergedPoListStream =
        StreamController<List<OutboundPoEntity>>();

    List<OutboundSmEntity> newSmList = [];
    List<OutboundPoEntity> newPoList = [];

    void emitMergedList() {
      if (outboundMergedPoListStream.isClosed) return;

      final mergedPoList = _mergeSmAndPo(newSmList, newPoList);
      outboundMergedPoListStream.add(mergedPoList);
    }

    /// SM 메시지가 들어오면 Merge 메소드 호출
    final smSubscription = _smRepository.outboundSmStream.listen((list) {
      newSmList = list;
      emitMergedList();
    });

    /// po 메시지가 들어오면 Merge 메소드 호출
    final poSubscription = _poRepository.outboundPoStream.listen((list) {
      newPoList = list;

      emitMergedList();
    });

    outboundMergedPoListStream.onCancel = () {
      smSubscription.cancel();
      poSubscription.cancel();
    };

    return outboundMergedPoListStream.stream;
  }

  List<OutboundPoEntity> _mergeSmAndPo(
    List<OutboundSmEntity> newSmList,
    List<OutboundPoEntity> newPoList,
  ) {
    List<OutboundPoEntity> mergedList = [];

    for (var sm in newSmList) {
      final convertedSm = OutboundPoEntity(
        missionType: sm.missionType,
        sourceBin: sm.sourceBin,
        destinationBin: sm.destinationBin,
        isWrapped: sm.isWrapped,
        doNo: sm.doNo,
        targetRackLevel: 0,
        destinationArea: 0,
        uid: '',
      );

      mergedList.add(convertedSm);
    }

    for (var po in newPoList) {
      final existsInList = mergedList.any((e) => e.uid == po.uid);

      if (!existsInList) mergedList.add(po);
    }

    return mergedList;
  }
}