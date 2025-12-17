import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/dtos/order_validation_req_dto.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';

import '../providers/inbound_order_list_provider.dart';

enum InputField { huId, sourceBin }

class InboundPopupVm extends ChangeNotifier {
  /// 텍스트 컨트롤러
  final TextEditingController pltCodeController = TextEditingController();
  final TextEditingController sourceBinController = TextEditingController();
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  String? _selectedRackLevel;
  int? destinationArea;
  String? _errorMessage;
  bool _isReserved = false; // 예약 여부

  String? get selectedRackLevel => _selectedRackLevel;

  String? get errorMessage => _errorMessage;

  bool get isReserved => _isReserved;

  /// 스캔데이터 HU / 저장빈 구분 => 필드에 채워줌
  void applyScannedData(String scannedData) {
    if (scannedData.isEmpty) return;

    // 숫자로 시작하면 출발 저장빈
    if (RegExp(r'^\d').hasMatch(scannedData)) {
      sourceBinController.text = scannedData;
    }
    // 문자로 시작하면 HU
    else if (RegExp(r'^[a-zA-Z]').hasMatch(scannedData)) {
      pltCodeController.text = scannedData;
    }
    notifyListeners();
  }

  /// 두 필드가 모두 채워졌는지 확인
  bool areBothFieldsFilled() {
    return pltCodeController.text.isNotEmpty &&
        sourceBinController.text.isNotEmpty;
  }

  /// 랙 레벨 목록
  final List<String> rackLevels = ['기준없음', '1단-001', '2단-002', '3단-003'];

  final Ref _ref;

  InboundPopupVm(this._ref);

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
    _isReserved = false; // 기본값 false

    /// 에러 메시지 클리어
    _errorMessage = null;

    notifyListeners();
  }

  /// Destination Area 지정
  void setDestinationArea(int? area) {
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

  /// 예약 상태 토글
  void toggleReservation(bool? value) {
    _isReserved = value ?? false;

    // 예약 해제 시 현재시간으로 리셋
    if (!_isReserved) {
      final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
      workTimeController.text = currentTime.toString().substring(0, 19);
    }

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
    bool baseValid =
        pltCodeController.text.isNotEmpty &&
        sourceBinController.text.isNotEmpty &&
        _selectedRackLevel != null &&
        userIdController.text.isNotEmpty &&
        destinationArea != null;

    // 예약인 경우에만 작업시간 검증
    if (_isReserved) {
      return baseValid && workTimeController.text.isNotEmpty;
    }

    return baseValid;
  }

  bool _isSaving = false; // 저장 중 상태
  bool get isSaving => _isSaving;

  /// 저장 로직 => 리스트에 담아서 상태 관리해야함 : inbound screen에서 상태에 접근해서 목록 드로잉
  Future<void> saveInboundRegistration(
    WidgetRef ref,
    BuildContext context,
  ) async {
    if (_isSaving) return; // 이미 저장 중이면 리턴

    if (!isFormValid()) {
      // 어떤 필드가 비어있는지 확인
      List<String> missingFields = [];

      if (pltCodeController.text.isEmpty) missingFields.add('HU Number');
      if (sourceBinController.text.isEmpty) missingFields.add('출발지 가상빈 Number');
      if (destinationArea == null) missingFields.add('목적지 구역');
      if (_selectedRackLevel == null) missingFields.add('제품정보 (규격/단수)');
      if (workTimeController.text.isEmpty) missingFields.add('작업시간');
      if (userIdController.text.isEmpty) missingFields.add('사번');

      // 에러가 있을 때 Exception을 throw해서 UI에서 처리하도록 함
      throw Exception('다음 필드를 입력해주세요:\n${missingFields.join(', ')}');
    }

    _isSaving = true;
    notifyListeners(); // 로딩 상태 알림

    try {
      // HuId 중복체크
      final existingOrders = ref.read(inboundOrderListProvider).orders;
      if (existingOrders.any((item) => item.huId == pltCodeController.text)) {
        throw Exception('이미 등록된 HU Number 입니다.');
      }

      // SourceBin 중복체크
      if (existingOrders.any(
        (item) => item.sourceBin == sourceBinController.text,
      )) {
        throw Exception('이미 등록된 가상빈 입니다.');
      }

      // 서버 유효성 검사 요청
      final validationDto = OrderValidationReqDto(
        huId: pltCodeController.text,
        binId: sourceBinController.text,
        employeeId: userIdController.text,
      );

      final repository = ref.read(orderRepositoryProvider);
      final result = await repository.validateOrder(validationDto);

      if (!result.isSuccess) {
        // 유효성 검사 실패 시 에러 메시지 표시 및 중단
        setErrorMessage(
          "HU Number와 출발지 가상빈 정보가 일치하지 않습니다.\n"
          "PLT의 가상빈 위치를 다시 확인해주세요",
        );
        throw Exception(
          "HU Number와 출발지 Bin 정보가 일치하지 않습니다.\n"
          "PLT의 Bin 위치를 확인해주세요",
        );
      }

      setErrorMessage(null);

      /// 상태 관리자에 항목 추가 요청
      await ref
          .read(inboundOrderListProvider.notifier)
          .addInboundOrder(
            huId: pltCodeController.text,
            sourceBin: sourceBinController.text,
            workStartTime: DateTime.parse(workTimeController.text),
            userId: userIdController.text,
            destinationArea: destinationArea,
            selectedRackLevel: _selectedRackLevel,
          );

      pltCodeController.clear();
      _selectedRackLevel = null;
      final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
      workTimeController.text = currentTime.toString().substring(0, 19);
    } catch (e) {
      // 네트워크 에러 등 처리
      if (e is! Exception) {
        throw Exception('서버 통신 중 오류가 발생했습니다.');
      }
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners(); // 저장 완료/실패 후 상태 복구
    }
  }

  /// 폼 초기화
  void resetForm() {
    pltCodeController.clear();
    _selectedRackLevel = null;
    _isReserved = false;
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

final inboundPopupVmProvider =
    ChangeNotifierProvider.autoDispose<InboundPopupVm>((ref) {
      final popupViewModel = InboundPopupVm(ref);
      popupViewModel.initialize();
      return popupViewModel;
    });
