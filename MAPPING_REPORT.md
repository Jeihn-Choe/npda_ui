# 상세설계서 매핑 리포트 (Codebase Mapping Report)

> 이 문서는 엑셀 상세설계서의 `Level 3` 항목에 매핑되는 실제 코드의 클래스와 메서드를 정리한 것입니다.

## 1. 입고/복귀 작업 관리 (Inbound)

| Level 3 (기능 항목) | 담당 클래스 (Class) | 주요 메서드 (Method) |
| :--- | :--- | :--- |
| **스캐너 활성화 기능** | `InboundPage` | `_onFocusChange` |
| **작업 팝업** | `InboundPopupVm` | `applyScannedData`, `saveInboundRegistration` |
| **작업 리스트 생성** | `InboundOrderListNotifier` | `addInboundOrder` |
| **개별 작업 별 유효성검사(API)** | `InboundPopupVm` | `saveInboundRegistration` (내부 `validateOrder` 호출) |
| **입고 작업 전송** | `InboundOrderListNotifier` | `requestInboundWork` |
| **작업 리스트의 세부 항목 삭제** | `InboundOrderListNotifier` | `deleteSelectedOrders` |
| **성공, 실패 여부 메시지 반환** | `InboundOrderListNotifier` | `requestInboundWork` (UI에서 try-catch로 Alert 표시) |

---

## 2. 출고 작업 관리 (Outbound)

| Level 3 (기능 항목) | 담당 클래스 (Class) | 주요 메서드 (Method) |
| :--- | :--- | :--- |
| **스캐너 활성화 기능** | `OutboundPage` | `_onFocusChange` |
| **각 작업 UI -> 작업 시 필수 요소 입력 UI 기능** | `OutboundPopupVM` | `saveOrder` (DO No, 저장빈 입력 및 유효성 검사) |
| **입,출고, 1층출고 리스트 생성** | `OutboundOrderListNotifier` | `addOrderToList` |
| **개별 작업 별 유효성검사(API)** | `OutboundPopupVM` | `saveOrder` (중복 체크 포함) |
| **작업 리스트의 세부 항목 삭제** | `OutboundOrderListNotifier` | `deleteSelectedOrders` |
| **전송** | `OutboundOrderListNotifier` | `requestOutboundOrder` |
| **성공, 실패 여부 메시지 반환** | `OutboundOrderListNotifier` | `requestOutboundOrder` (UI에서 Alert 표시) |

---

## 3. 1층 출고 작업 관리 (Outbound 1F)

| Level 3 (기능 항목) | 담당 클래스 (Class) | 주요 메서드 (Method) |
| :--- | :--- | :--- |
| **스캐너 활성화 기능** | `Outbound1FPage` | `_onFocusChange` |
| **각 작업 UI -> 작업 시 필수 요소 입력 UI 기능** | `Outbound1FPopupVM` | `saveOrder` (출발/도착 구역, 수량 입력) |
| **입,출고, 1층출고 리스트 생성** | `Outbound1FOrderListNotifier` | `addOrderToList` |
| **개별 작업 별 유효성검사(API)** | `Outbound1FPopupVM` | `saveOrder` |
| **작업 리스트의 세부 항목 삭제** | `Outbound1FOrderListNotifier` | `deleteSelectedOrders` |
| **전송** | `Outbound1FOrderListNotifier` | `requestOutbound1FOrder` |
| **성공, 실패 여부 메시지 반환** | `Outbound1FOrderListNotifier` | `requestOutbound1FOrder` (UI에서 Alert 표시) |

---

## 4. 미션 관리 (Common)

| Level 3 (기능 항목) | 담당 클래스 (Class) | 주요 메서드 (Method) |
| :--- | :--- | :--- |
| **미션 리스트** | `InboundMissionListNotifier` (입고)<br>`OutboundMissionListNotifier` (출고) | `state.missions` (List 상태 관리) |
| **미션 상세 보기 기능** | `InboundMissionListNotifier` | `selectMission` (상세 정보 탭 바인딩) |
| **펜딩 미션 리스트 개별 삭제 기능** | `InboundMissionListNotifier` | `deleteSelectedInboundMissions` |

