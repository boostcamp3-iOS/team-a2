# OneDay
BoostCamp 2019 iOS A2

넘사벽 저널링 서비스로 알려져 있는 **[DayOne](https://dayone.me/)** 모방 프로젝트

## 함께한 사람
Mentor : [Yagom](https://github.com/yagom)

A2 Members
* [Trevi : 서정화](https://github.com/mohok)
* [Hybree : 송원근](https://github.com/yk1028)
* [Coco : 김주희](https://github.com/caution-dev)

## Screen Shot
|TimeLine|Photos|Add New Entry| Editor|
| :--: | :--: | :--: | :--: |
| ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_1.png) | ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_2.png) | ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_3.png) | ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_4.png)| 
|Calendar|Add New Entry| 모아보기 |  |
 | ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_5.png) | ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_6.png) | ![image](https://github.com/caution-dev/team-a2/raw/master/resources/screenshot_7.png) | |
## 핵심 기능
- 일기 작성
- 일기 검색 및 필터
- 다양한 모드로 일기 보여주기
  - 타임라인
  - 캘린더
  - 지도
  - 사진
- 저널 단위로 일기 관리
- iCloud 동기화

## 사용 기술
* **Core Data**   : 사용자의 데이터를 로컬에 저장하고 불러옵니다.
* **Core Location**   : 사용자의 현재 위치를 불러옵니다.
* **[DarkSky API](https://github.com/boostcamp3-iOS/team-a2/wiki/%EB%82%A0%EC%94%A8-API-%EC%A0%95%EB%A6%AC)**   : 사용자 위치에 따른 현재 날씨 정보를 불러옵니다.
* **MapKit**   : 사용자의 현재 위치 및 일기가 작성된 위치들을 보여줍니다.
* **CloudKit**   : iCloud를 통해 데이터를 동기화하고 백업합니다.
* **AutoLayout**

## 주차별 목표
**모든 활동 기록 및 중간산출물은 [Wiki](https://github.com/boostcamp3-iOS/team-a2/wiki) 에 저장합니다.**
- Week 1
  - **기능 분석** : 전체적인 앱 기능 분석 및 우선 순위 결정
    - [DayOne 기능정리](https://github.com/boostcamp3-iOS/team-a2/wiki/DayOne-%EA%B8%B0%EB%8A%A5%EC%A0%95%EB%A6%AC) 
    - [OneDay 기능명세](https://docs.google.com/spreadsheets/d/1ZsYx74p-QbSNbjjnoEGnU3S3vZ9cZ-T_bV6MNB_x7nY/edit#gid=1928828845)
    - [날씨 API 정리](https://github.com/boostcamp3-iOS/team-a2/wiki/날씨-API-정리)  
    - [키 컬러](https://github.com/boostcamp3-iOS/team-a2/wiki/키-컬러)
  - **프로토타이핑** : 앱 개발에 필요한 요소들 사전 조사 및 프로토타입 개발
    - [CloudKit 적용](https://github.com/boostcamp3-iOS/team-a2/wiki/iCloud-%EC%82%AC%EC%9A%A9%EB%B0%A9%EB%B2%95)
    - [프로토타입](https://github.com/boostcamp3-iOS/team-a2/tree/develop/OneDay) 프로젝트
- Week 2
  - CoreData 적용
    - CoreData Model 생성
    - Test Case 생성
  - [캘린더](https://www.notion.so/cbaa44b5997548369c48a95c1f545ef2)
  - 일기 데이터 추가 : 시간, 날씨, 장소
  - 사이드 메뉴 화면 구성
  - 일기 에디터 : 사진, 글
  - 저널 단위로 일기 관리
  - UI Transition Animation Enhancement
- Week 3
  - [모아보기](https://www.notion.so/29c24998bbf046f886bd7c3eed1ac765) 
  - 지도
  - 다양한 모드로 일기 보여주기 (화면 구성)
    - 타임라인
    - 캘린더
    - 사진
  - iCloud 동기화 : 전체 데이터 저장
  - iCloud 동기화 : 저장할 데이터 선택
- Week 4
  - 에디터 마크다운 적용
  - 알리미
  - 탭바 기능 추가
  - Refactoring
