import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../providers/inbound_order_list_provider.dart';

/// inbound_popup viewmodel에서 관리하는 상태 모음
class InboundRegistrationPopupViewModel extends ChangeNotifier {
  /// 텍스트 컨트롤러
  final TextEditingController pltCodeController = TextEditingController();
  final TextEditingController sourceBinController = TextEditingController();
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  String? _selectedRackLevel;
  String? destinationArea;
  String? _errorMessage;

  String? get selectedRackLevel => _selectedRackLevel;

  String? get errorMessage => _errorMessage;

  /// 스캔데이터 HU / 저장빈 구분 => 필드에 채워줌
  void applyScannedData(String scannedData) {
    // 시작이 P 이면 HU
    if (scannedData.startsWith('P')) {
      pltCodeController.text = scannedData;
    }
    // 시작이 2A 이면 출발 저장빈
    if (scannedData.startsWith('2A')) {
      sourceBinController.text = scannedData;
    }
    notifyListeners();
  }

  /// 두 필드가 모두 채워졌는지 확인
  bool areBothFieldsFilled() {
    return pltCodeController.text.isNotEmpty &&
        sourceBinController.text.isNotEmpty;
  }

  /// 랙 레벨 목록
  final List<String> rackLevels = ['기준없음', '1단 - 001', '2단 - 002', '3단 - 003'];

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
    destinationArea = null; // 초기화 시 null로 설정

    /// 에러 메시지 클리어
    _errorMessage = null;

    notifyListeners();
  }

  /// Destination Area 지정
  void setDestinationArea(String? area) {
    destinationArea = area;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void setErrorMessage(String? message) {
    _errorMessage = message;
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
        sourceBinController.text.isNotEmpty &&
        _selectedRackLevel != null &&
        workTimeController.text.isNotEmpty &&
        userIdController.text.isNotEmpty &&
        destinationArea != null;
  }

  /// 저장 로직 => 리스트에 담아서 상태 관리해야함 : inbound screen에서 상태에 접근해서 목록 드로잉
  Future<void> saveInboundRegistration(
    WidgetRef ref,
    BuildContext context,
  ) async {
    appLogger.d('saveInboundRegistration 호출됨');
    appLogger.d('isFormValid: ${isFormValid()}');
    appLogger.d('destinationArea: $destinationArea');
    appLogger.d('_selectedRackLevel: $_selectedRackLevel');

    if (!isFormValid()) {
      appLogger.w('폼 유효성 검사 실패');
      // 어떤 필드가 비어있는지 확인
      List<String> missingFields = [];

      if (pltCodeController.text.isEmpty) missingFields.add('HU Number');
      if (sourceBinController.text.isEmpty) missingFields.add('출발지 가상빈 Number');
      if (destinationArea == null) missingFields.add('목적지 구역');
      if (_selectedRackLevel == null) missingFields.add('제품정보 (규격/단수)');
      if (workTimeController.text.isEmpty) missingFields.add('작업시간');
      if (userIdController.text.isEmpty) missingFields.add('사번');

      appLogger.w('누락된 필드: $missingFields');

      // 에러가 있을 때 Exception을 throw해서 UI에서 처리하도록 함
      throw Exception('다음 필드를 입력해주세요:\n${missingFields.join(', ')}');
    }

    setErrorMessage(null);

    /// 상태 관리자에 항목 추가 요청
    try {
      await ref
          .read(inboundOrderListProvider.notifier)
          .addInboundOrder(
            pltNo: pltCodeController.text,
            workStartTime: DateTime.parse(workTimeController.text),
            userId: userIdController.text,
            destinationArea: destinationArea,
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
