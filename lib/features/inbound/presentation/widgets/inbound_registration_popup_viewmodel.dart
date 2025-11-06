import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';

import '../providers/inbound_order_list_provider.dart';

/// inbound_popup viewmodel에서 관리하는 상태 모음
class InboundRegistrationPopupViewModel extends ChangeNotifier {
  /// 텍스트 컨트롤러
  final TextEditingController pltCodeController = TextEditingController();
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  String? _selectedRackLevel;

  String? get selectedRackLevel => _selectedRackLevel;

  /// 랙 레벨 목록
  final List<String> rackLevels = ['1단 - 001', '2단 - 002', '3단 - 003', '기준없음'];

  final Ref _ref;

  InboundRegistrationPopupViewModel(this._ref);

  /// 초기화
  void initialize() {
    final sessionState = _ref.read(sessionManagerProvider);

    /// 현재 시간을 작업시간으로 설정
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));

    workTimeController.text = currentTime.toString().substring(0, 19);

    /// userId 로 사번 업데이트
    userIdController.text = sessionState.userId ?? '';

    /// 초기화 필요 시 추가
    // pltCodeController.text = 'P180047852-020001';
    _selectedRackLevel = rackLevels[0];

    notifyListeners();
  }

  /// 랙 레벨 선택 변경
  void setSelectedRackLevel(String? value) {
    _selectedRackLevel = value;
    notifyListeners();
  }

  /// 작업시간 업데이트
  void updateWorkTime(DateTime selectedDateTime) {
    workTimeController.text = selectedDateTime.toString().substring(0, 19);
    notifyListeners();
  }

  /// 현재 작업시간 가져오기
  DateTime getCurrentWorkTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 9));
  }

  /// UI에서 pltCode 직접 세팅
  void setPltCode(String? pltCode) {
    if (pltCode != null) pltCodeController.text = pltCode;
    notifyListeners();
  }

  /// 폼 유효성 검사
  bool isFormValid() {
    return pltCodeController.text.isNotEmpty &&
        _selectedRackLevel != null &&
        workTimeController.text.isNotEmpty &&
        userIdController.text.isNotEmpty;
  }

  /// 저장 로직 => 리스트에 담아서 상태 관리해야함 : inbound screen에서 상태에 접근해서 목록 드로잉
  Future<void> saveInboundRegistration(WidgetRef ref) async {
    if (!isFormValid()) {
      return;
    }

    /// 상태 관리자에 항목 추가 요청
    try {
      await ref
          .read(inboundOrderListProvider.notifier)
          .addInboundOrder(
            pltNo: pltCodeController.text,
            workStartTime: DateTime.parse(workTimeController.text),
            userId: userIdController.text,
            selectedRackLevel: _selectedRackLevel,
          );

      pltCodeController.clear();
      _selectedRackLevel = null;
      final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
      workTimeController.text = currentTime.toString().substring(0, 19);
      notifyListeners();
    } catch (e) {
      // 에러 처리 (예: 사용자에게 오류 메시지 표시)
    }
  }

  /// 폼 초기화
  void resetForm() {
    pltCodeController.clear();
    _selectedRackLevel = null;
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
    workTimeController.text = currentTime.toString().substring(0, 19);
    notifyListeners();
  }

  // 리소스 해제
  @override
  void dispose() {
    pltCodeController.dispose();
    workTimeController.dispose();
    userIdController.dispose();
    super.dispose();
  }
}
