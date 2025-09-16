import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_registration_item.dart';

import '../../../login/presentation/login_viewmodel.dart';

/// provider 선언
final inboundRegistrationPopupViewModelProvider = ChangeNotifierProvider((ref) {
  final viewModel = InboundRegistrationPopupViewModel();
  final loginState = ref.watch(loginViewModelProvider);

  /// 뷰모델 초기화
  viewModel.initialize(loginState);

  return viewModel;
});

/// inbound_popup viewmodel에서 관리하는 상태 모음
class InboundRegistrationPopupViewModel extends ChangeNotifier {
  /// 입고작업 리스트
  final List<InboundRegistrationItem> inboundRegistrations = [];

  /// 텍스트 컨트롤러
  final TextEditingController pltCodeController = TextEditingController();
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  /// 선택된 랙 레벨
  String? _selectedRackLevel;

  String? get selectedRackLevel => _selectedRackLevel;

  /// 랙 레벨 목록
  final List<String> rackLevels = ['1단 - 001', '2단 - 002', '3단 - 003', '기준없음'];

  /// 초기화
  void initialize(LoginState loginState) {
    /// 현재 시간을 작업시간으로 설정
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
    workTimeController.text = currentTime.toString().substring(0, 19);

    /// userId 로 사번 업데이트
    userIdController.text = loginState.userId ?? '';

    /// 이하 더미 데이터들. 테스트용, 삭제예정
    pltCodeController.text = 'P180047852-020001';
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

  /// 폼 유효성 검사
  bool isFormValid() {
    return pltCodeController.text.isNotEmpty &&
        _selectedRackLevel != null &&
        workTimeController.text.isNotEmpty &&
        userIdController.text.isNotEmpty;
  }

  /// 저장 로직 => 리스트에 담아서 상태 관리해야함 : inbound screen에서 상태에 접근해서 목록 드로잉
  void saveInboundRegistration() {
    logger('saveInboundRegistration 호출됨');

    if (isFormValid()) {
      final isDuplicate = inboundRegistrations.any(
        (item) => item.pltNo == pltCodeController.text,
      );
      if (isDuplicate) {
        logger('중복된 PLT Number: ${pltCodeController.text}');
        return; // 중복된 항목이 있으면 저장하지 않고 종료
      }

      // 저장 로직 구현
      final newItem = InboundRegistrationItem(
        pltNo: pltCodeController.text,
        workStartTime: DateTime.parse(workTimeController.text),
        selectedRackLevel: _selectedRackLevel!,
        userId: userIdController.text,
      );

      inboundRegistrations.add(newItem);

      logger('Inbound Registration Saved Successfully!: ${newItem.toString()}');
      Logger().d('Total Registrations: ${inboundRegistrations.length}');

      // 저장 후 폼 초기화
      pltCodeController.clear();
      _selectedRackLevel = null;
      final currentTime = DateTime.now().toUtc().add(const Duration(hours: 9));
      workTimeController.text = currentTime.toString().substring(0, 19);
      notifyListeners();
    } else {
      // 폼이 유효하지 않을 때 처리
      // 예: 사용자에게 오류 메시지 표시
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
