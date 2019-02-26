# OneDay
BoostCamp 2019 iOS A2

넘사벽 저널링 서비스로 알려져 있는 **[DayOne](https://dayone.me/)** 모방 프로젝트

  
[![Video Label](http://img.youtube.com/vi/qcK940kT400/0.jpg)](https://youtu.be/qcK940kT400?t=0s)


## 함께한 사람
Mentor : [Yagom](https://github.com/yagom)

A2 Members
* [Coco : 김주희](https://github.com/caution-dev)
* [Trevi : 서정화](https://github.com/mohok)
* [Hybree : 송원근](https://github.com/yk1028)

## Screen Shot
|TimeLine|Photos|Add New Entry| Editor|
| :--: | :--: | :--: | :--: |
| ![simulator screen shot - iphone xr - 2019-02-26 at 12 21 38](https://user-images.githubusercontent.com/35840155/53389572-31544600-39d3-11e9-84f9-40e618ef5725.png)| ![simulator screen shot - iphone xr - 2019-02-26 at 12 22 00](https://user-images.githubusercontent.com/35840155/53389578-36b19080-39d3-11e9-80f1-688665c30000.png) | ![simulator screen shot - iphone xr - 2019-02-26 at 12 22 52](https://user-images.githubusercontent.com/35840155/53389581-3ca77180-39d3-11e9-82db-ea604c066140.png) | ![simulator screen shot - iphone xr - 2019-02-26 at 12 25 55](https://user-images.githubusercontent.com/35840155/53389591-3f09cb80-39d3-11e9-81ab-f1485e4e8482.png)| 
|Editor detail|Map| Calendar | Collection |
 | ![simulator screen shot - iphone xr - 2019-02-26 at 12 25 58](https://user-images.githubusercontent.com/35840155/53389595-4335e900-39d3-11e9-9519-d131245cb996.png) |![simulator screen shot - iphone xr - 2019-02-26 at 12 27 17](https://user-images.githubusercontent.com/35840155/53389606-4a5cf700-39d3-11e9-8c22-62a5b521597f.png)| ![simulator screen shot - iphone xr - 2019-02-26 at 12 26 11](https://user-images.githubusercontent.com/35840155/53389599-4630d980-39d3-11e9-9d77-0befeac26243.png) | ![simulator screen shot - iphone xr - 2019-02-26 at 12 26 18](https://user-images.githubusercontent.com/35840155/53389604-48933380-39d3-11e9-98cc-74f4dc32a679.png) | 
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
    - [CloudKit 사전조사](https://github.com/boostcamp3-iOS/team-a2/wiki/iCloud-%EC%82%AC%EC%9A%A9%EB%B0%A9%EB%B2%95)
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
  - [UI Transition Animation Enhancement](https://www.notion.so/add39db43b8045828cb6b812ed1573b3)
- Week 3
  - [모아보기](https://www.notion.so/29c24998bbf046f886bd7c3eed1ac765) 
  - 지도
  - 다양한 모드로 일기 보여주기 (화면 구성)
    - 타임라인
    - 캘린더
    - 사진
  - [에디터 하단 뷰](https://github.com/boostcamp3-iOS/team-a2/wiki/%EC%97%90%EB%94%94%ED%84%B0-%ED%95%98%EB%8B%A8-%EB%B7%B0-%EA%B5%AC%ED%98%84%EC%8B%9C-%EA%B3%A0%EB%A0%A4%EC%82%AC%ED%95%AD) 
- Week 4
  - 에디터 마크다운 적용
  - 알리미
  - 탭바 기능 추가
  - Refactoring
