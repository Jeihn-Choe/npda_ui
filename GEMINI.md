## Workflow for Feature Implementation

When a new feature is requested, the following step-by-step process will be followed:

1.  **User Feature Request**
2.  **Agent's Overall Implementation Plan (Code Excluded):** The agent will present a high-level, step-by-step plan for the entire feature, without providing any code.
3.  **User-Agent Feature Discussion/Agreement:** The user and agent will discuss and agree upon the overall feature implementation plan.
4.  **Agent's Detailed Step-by-Step Explanation (Code Excluded):** Once the overall plan is agreed upon, the agent will provide a detailed explanation for each individual step, still without providing any code.
5.  **User-Agent Detailed Step Discussion/Agreement:** The user and agent will discuss and agree upon the details of the specific step.
6.  **Agent's Code Proposal (For Current Step):** Only after the detailed explanation for a step is agreed upon, the agent will provide the actual code for that specific step.

---

### 프로젝트 UI 기본 구조 샘플 (최종 확정)

```
[your_project]/
└── lib/
    └── features/
        └── [feature_name]/  (예: outbound)
            ├── data/
            │   └── ...
            ├── domain/
            │   └── ...
            └── presentation/
                ├── providers/
                │   └── common_providers.dart         // ⚙️ 공통 의존성 Provider
                ├── widgets/
                │   └── ...                         // 🎨 화면 전용 위젯
                │
                ├── [data_name]_provider.dart       // 묶음 1: 데이터 상태 관리
                ├── [data_name_2]_provider.dart     // 묶음 2: 데이터 상태 관리
                │
                ├── [screen_name]_screen_viewmodel.dart // 👑 화면 총괄 ViewModel
                │
                └── [screen_name]_screen.dart       // 🖼️ 최종 UI 위젯
```
---
### 코드 변경 제안 시 규칙
- 코드 변경 사항을 제안할 때, 변경되거나 추가된 부분에 주석과 이모지를 사용하여 명확하게 표시합니다. (예: `// ✨ 변경된 부분` 또는 `// 🚀 추가된 부분`)
- 사용자는 이 주석을 실제 코드에 반영하지 않으므로, 설명 목적으로만 사용합니다.