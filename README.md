# 🧭 Guide AI (가이드아이)
3D 비전 AI 및 넥 마운트 기반 시각장애인용 고정밀 보행 보조 시스템 > Development of a High-Precision Walking Assistive System for the Visually Impaired Using 3D Vision AI and a Neck Mount

## 📌 프로젝트 개요 (Project Overview)
현대 도심 환경은 전동 킥보드, 배달 로봇, 비정형 포트홀 등 예측 불가능한 동적 장애물들로 가득 차 있으며, 기존의 흰 지팡이는 이러한 환경 변화에 대응하는 데 물리적 한계가 있습니다. Guide AI는 스마트폰의 온디바이스(On-Device) AI와 인체공학적 넥 마운트 구조를 결합하여, 시각장애인에게 실시간으로 정밀한 보행 가이드를 제공하는 차세대 보조 공학 솔루션입니다.

## ✨ 핵심 기능 (Key Features)
### 1. 넥 마운트 기반 안정적 POV (Neck-Mounted Stability)
- 핸즈프리 환경: 사용자의 양손을 자유롭게 하여 기존 보조 기구(지팡이 등) 사용을 방해하지 않습니다.
- 진동 흡수: 경추와 상부 흉추에 지지되는 구조를 통해 보행 주기(Gait Cycle)에서 발생하는 진동을 효과적으로 흡수하고 안정적인 1인칭 시점(POV)을 제공합니다.

### 2. 고정밀 3D 비전 및 6DoF 인지 (High-Precision 3D Vision)
- 6DoF 자세 추정: 객체의 정체뿐만 아니라 3차원 공간에서의 정확한 방향, 규모, 위치 정보를 도출하여 단순 경보 이상의 능능동적 환경 해석을 가능케 합니다.
- 기하학적 충돌 벡터 계산: 6자유도 데이터를 기반으로 사용자의 예상 경로와 장애물의 점유 공간이 교차하는지를 실시간으로 연산하여 위험도를 수치화합니다.

### 3. 하이브리드 딥러닝 기반 경로 예측 (Trajectory Prediction)
- CNN-LSTM 결합: ResNet 기반의 CNN으로 공간 특징을 추출하고, LSTM으로 시간적 문맥을 분석하여 1초 후 보행자가 발을 내디딜 위치를 예측합니다.
- 자기중심적 경로 예측: 사용자의 이동 궤적과 운동 모멘텀을 분석하여 선제적으로 위험을 감지합니다.

### 4. 온디바이스 최적화 및 센서 융합 (On-Device Optimization)
- 모델 양자화: 32비트 가중치를 16비트로 변환하여 모바일 환경에서 2Hz 이상의 추론 속도를 유지하고 발열을 최소화합니다.
- ARLO 알고리즘: IMU 센서 데이터와 시각적 지평선을 교차 참조하여 카메라 각도 비틀림을 실시간으로 보정합니다.

## 🛠 기술 스택 (Tech Stack)
- AI/DL: Python, YOLOv8n, ResNet, LSTM, TFLite, 6DoF Pose Estimation
- Mobile: iOS (Swift, Swift Concurrency, AVFoundation)
- Algorithms: Depth Estimation, ARLO
- Tools: Roboflow, AI Hub Dataset, Google Drive (Collaboration)

## 🏗 시스템 아키텍처 (System Architecture)
<img width="720" height="360" alt="image" src="https://github.com/user-attachments/assets/33ea7adb-41a8-4ace-9122-9ba17e887aa8" />

## 📈 위험 단계별 피드백 (Multimodal Feedback)
장애물의 위험도 수치에 따라 차별화된 피드백을 제공합니다.

| 위험 단계 | 상황 설명 | 햅틱 패턴 | 음성 안내 특성 |
| --- | --- | --- | --- |
| 저위험 | 경로 근처 원거리 장애물 | 간헐적 저주파 진동 | 부드러운 알림 |
| 중위험 | 경로 상의 정적 장애물 | 규칙적인 중간 세기 진동 | 명확한 방향 정보 |
| 저위험 | 즉각 충돌 예상/동적 위험 | 연속적인 고주파 진동 | 고음량 및 급박한 경고 |

## 🚀 기대 효과 (Expected Impact)
- 기술의 민주화: 범용 스마트폰 활용을 통해 정보 격차 및 기술 불평등을 해소합니다.
- 사회적 통합: 시각장애인의 활동 반경을 넓히고 사회적 참여 기회를 확대하여 경제적 자립을 돕습니다.
- 스마트 시티 연동: 향후 V2X 기술과 통합되어 가시거리 밖 위험 정보까지 선제적으로 방어하는 시스템으로 확장 가능합니다.

## 📄 참고 논문 (References)
[3D 비전 AI 및 넥 마운트 기반 시각장애인용고정밀 보행 보조 시스템의 개발과 기술적 통합에 관한 종합적 고찰](https://drive.google.com/file/d/1SlsnoH6eH6TUFAutxqqoXYT3wAt6R1tf/view)
