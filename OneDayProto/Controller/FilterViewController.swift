//
//  FilterViewController.swift
//  OneDayProto
//
//  Created by 정화 on 23/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    var dummyData: [String] = []

    //검색을 위한 배열 및 변수
    var matchedEntriesData = [String]()
    var isSearching = false

    //FIXME: 배열 목록에서 다른 구조로 바꾸기
    let filterLabelList = ["즐겨찾기", "태그", "장소", "년", "날씨", "작성 디바이스"]
    let filterIconList = ["filterHeart", "filterTag", "filterPlace", "filterYear", "filterWeather", "filterDevice"]
    let contentsCountList = [0, 0, 0, 0, 0, 0]

    override func viewDidLoad() {
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()

        setupSearchBar()
        setupFilterTableView()
        appendDummyData()
    }
    override var prefersStatusBarHidden: Bool { return true }

    let filterTableView = UITableView()

    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.searchBarStyle = .prominent
        bar.showsCancelButton = true
        bar.sizeToFit()
        bar.backgroundImage = UIImage()
        bar.placeholder = "검색"
        return bar
    }()

}

// MARK: 검색, SearchBar
// searchBar에 쓰인 텍스트가 dummyData에 있는지 검사한다.
extension FilterViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: false, completion: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            filterTableView.reloadData()
        } else {
            isSearching = true

            matchedEntriesData = dummyData.filter {$0.contains(searchBar.text!)}
            filterTableView.reloadData()
        }
    }

}

// MARK: 테이블뷰, TableView
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if isSearching { return 1 } else { return 0 }
        case 1:
            if isSearching { return matchedEntriesData.count } else { return 0 }
        case 2:
            return 0
        case 3:
            if !isSearching { return filterLabelList.count } else { return 0 }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchedCellId", for: indexPath) as? SearchedKeywordCell
            if let keyword = searchBar.text { cell?.titleLabel.text = "\"\(keyword)\"" }
            cell?.countLabel.text = "\(matchedEntriesData.count)"
            return cell!

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "matchingCellId", for: indexPath) as? MatchingEntriesCell
            if isSearching {
                // 서치 키워드 검색 단어 색상 변경
                let range = (matchedEntriesData[indexPath.row] as NSString).range(of: searchBar.text!)
                let attributedText = NSMutableAttributedString(string: matchedEntriesData[indexPath.row])
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.doBlue, range: range)

                cell?.matchingTextLabel.attributedText = attributedText

            }
            return cell!
        case 2:
            //FIXME: 수정
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellId", for: indexPath) as? FilterTableCell
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellId", for: indexPath) as? FilterTableCell
            cell?.selectionStyle = .none
            cell?.filterIcon.image = UIImage(named: filterIconList[indexPath.row])!
            cell?.filterLabel.text = filterLabelList[indexPath.row]
            cell?.contentsCountLabel.text = String(contentsCountList[indexPath.row])
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellId", for: indexPath) as? FilterTableCell
            return cell!

        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if isSearching { return "Keywords" } else { return "" }
        case 1:
            if searchBar.text == nil || searchBar.text == "" {
                return ""
            } else if matchedEntriesData.count != 0 {
                return "Matching Entries"
            } else { return "" }

        case 2:
            if !isSearching { return "Recent"} else { return "" }
        case 3:
            if !isSearching { return "Filter"} else { return "" }
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 70
        } else {
            return 50

        }
    }

}

// MARK: 레이아웃, Layout
extension FilterViewController {
    func setupSearchBar() {
        view.addSubview(searchBar)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.black

        searchBar.delegate = self
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    func setupFilterTableView() {
        view.addSubview(filterTableView)
        filterTableView.translatesAutoresizingMaskIntoConstraints = false

        filterTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        filterTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16).isActive = true
        filterTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        filterTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true

//        filterTableView.separatorStyle = .none
        filterTableView.delegate = self
        filterTableView.dataSource = self

        filterTableView.register(SearchedKeywordCell.self, forCellReuseIdentifier: "searchedCellId")
        filterTableView.register(MatchingEntriesCell.self, forCellReuseIdentifier: "matchingCellId")

        filterTableView.register(FilterTableCell.self, forCellReuseIdentifier: "filterCellId")

    }

}

//FIXME: 더미 데이터, dummy data
extension FilterViewController {
    func appendDummyData() {
        dummyData.append("닭고기를 조각내어 밀가루 등을 묻히고 기름에 튀긴 요리이다. ")
        dummyData.append("현재는 조각내지 않고 튀기거나, 기름에 튀기지 않는 방식의 요리도 치킨이라 불리고 있으며")
        dummyData.append("그 외 다양한 변형들이 만들어지고 있다. ")
        dummyData.append("즉, 프라이드 치킨의 줄임말로 시작했지만 튀김 방식이 아닌 새로운 닭요리를 통칭하는 용어로 사용되고 있다.")
        dummyData.append("때문에 치킨과 통닭을 같은 뜻으로 사용하는 사람도 많아졌다.")
        dummyData.append(" 강냉이와 옥수수를 같은 뜻으로 이해하는 것과 비슷하다.")
        dummyData.append("패스트푸드 삼대장인 피자, 햄버거, 치킨 중 압도적인 원탑의 위치를 점하고 있다. ")
        dummyData.append("출출해지는 밤을 달래주는 한국인들의 주요 야식 중 하나이다. ")
        dummyData.append("밤에 TV나 영화를 보며 먹는 치맥(또는 치콜)은 그야말로 최고의 요깃거리라 할 수 있다. ")
        dummyData.append("한국의 프라이드 치킨은 배달 문화와 맞물려 널리 퍼져나갔으며")
        dummyData.append("다양한 방식과 맛으로 변화를 거치면서 짜장면처럼 로컬라이징된 한국 특유의 음식으로 각광받고 있다.")
        dummyData.append("원조는 밑에 서술되어있는 미국 흑인들의 닭 튀김이다.")
        dummyData.append("주한미군이 추수감사절에 칠면조 대신 닭을 튀겨먹은 것이 퍼져나가 오늘날 국내의 치킨 요리가 되었다는 설이 보통 우세하지만")
        dummyData.append("이른바 '시장에서 튀기는 통닭'을 국내 치킨 요리의 기원으로 꼽기도 한다")
        dummyData.append("예전부터 전통 재래 시장마다 꼭 하나씩 있던 닭집에서는 생닭 뿐만 아니라 닭튀김 요리도 같이 팔았는데")
        dummyData.append("닭이 비쌌던 그 시절의 통닭 요리는 아버지의 월급날 혹은 소풍날 생기는 큰 행사 중 하나였다.")
        dummyData.append("중장년층들은 어린 시절에 아부지 월급날이면 어무니 손 잡고 시장 가서 통닭을 사오곤 했다 라고 회상하는 경우가 많다. ")
        dummyData.append("물론 그 이전에도 닭을 부위별로 토막내어 프라이팬에 기름으로 튀기는 방식의 닭튀김은 일반 가정에서도 흔했지만.")
        dummyData.append("1960년에는 최초의 전기구이 통닭 전문점인 명동 영양센타가 개업했다. ")
        dummyData.append("당시 영화나 소설에 심심치 않게 명동 영양센타가 등장할 정도로 영양센타의 전기구이는 이른바 대세를 이루던 고급 음식이였고,")
        dummyData.append(" 이는 70년대 중후반 전기구이 통닭 열풍이 사그라들 때까지 이어지게 된다.")
        dummyData.append("1960년대 말, 경제 개발 5개년 계획을 통해 국민 소득이 증가함과 동시에 국내 양계장의 생산량이 10배 이상 증가하면서 닭요리는 이젠 국민들이 쉽게 접할 수 있는 흔한 음식이 되었다.")
        dummyData.append("그리고 1971년에는 해표 식용유가 국내 최초로 출시되면서 닭과 기름의 양산화가 모두 갖추어져 본격적인 프라이드 치킨의 시대가 도래한다.")
        dummyData.append("1977년 한국 최초의 프라이드 치킨집인 림스치킨이 신세계 백화점에 개업했고, 1979년에는 롯데리아에서 조각 치킨을 판매하기 시작했으며, 1980년대 초부터 중소규모의 프라이드 치킨집들이 생겨났다.")
        dummyData.append("1984년, 두산을 통해 KFC가 서울 종로구에 들어왔다. 당시 KFC의 치킨 가격은 매우 비싼 축에 속했으나 청춘들의 미팅 장소로 각광받으며 특유의 매콤하고 기름진 맛이 차츰 국내에서 유행하기 시작했다.")
        dummyData.append("1985년에는 대구의 계성통닭과 대전의 페리카나에서 최초로 양념치킨을 선보이며 소위 '양념 반 후라이드 반'의 시대를 열었다.")
            dummyData.append("멕시칸치킨 (1986), 처갓집 양념통닭 (1988), 이서방 양념통닭 (1989), 스모프 양념통닭 (1989), 멕시카나 (1989), 사또치킨 (1990), BBQ (1995), 네네치킨 (1999)[2], 호식이 두마리치킨 (1999), 부어치킨 (2005)")
        dummyData.append("1990년대부터 본격적으로 치킨 체인점 광고가 TV나 라디오 등의 전파를 타면서, 전기구이 통닭은 촌스러운 것으로 여겨져 점점 시장점유율을 내주게 되었고 그나마 명맥을 이어간 극소수의 전문점을 제외하면 1993년부터 등장한 트럭 장작 구이 및 숯불 바비큐 치킨으로 명맥을 이어가게 되었다.")
        dummyData.append(" 또한 1995년 등장한 BBQ가 매장 내 금연, 주류 포장 판매 원칙을 내세우며 폭발적으로 성장하자, 이에 영향을 받은 치킨집들이 이전의 호프집 이미지를 벗어나기 시작한다.")
        dummyData.append("ㅊㅋㅊㅋ")
        dummyData.append("나랑 ㅊㅋ먹을래?")
        dummyData.append("치킨 시켜주세요")
        dummyData.append("흐아앙오아으앙")
        dummyData.append("교촌 치킨 먹고 싶다")
        dummyData.append("KFC 버거는 맛이 없다")
        dummyData.append("BBQ는 황금올리브치킨이지")
        dummyData.append("호오호오호호호호호")
        dummyData.append("ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ")
        dummyData.append("ㅏㅑㅓㅕㅗㅛㅜㅠㅡㅣ")

    }
}
