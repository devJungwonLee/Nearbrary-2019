//
//  DetailViewController.swift
//  Nearbrary
//
//  Created by 이정원 on 04/06/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

class DetailViewController: UITableViewController {
    
    var selectedBook : book? = nil
    
    @IBOutlet var booktitle: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var publisher: UILabel!
    @IBOutlet var pubdate: UILabel!
    @IBOutlet var isbn: UILabel!
    @IBOutlet var bookImageView: UIImageView!
    @IBAction func NaverLink(_ sender: UIButton) {
        let url = URL(string: selectedBook?.link ?? "")!
        let webVC = SFSafariViewController(url: url)
        present(webVC, animated: true, completion: nil)
    }
    
    @IBOutlet var sogang_status: UILabel!
    @IBOutlet var yonsei_status: UILabel!
    @IBOutlet var ewha_status: UILabel!
    @IBOutlet var hongik_status: UILabel!
    
    @IBOutlet weak var logo_sogang: UIImageView!
    @IBOutlet weak var logo_yonsei: UIImageView!
    @IBOutlet weak var logo_ewha: UIImageView!
    @IBOutlet weak var logo_hongik: UIImageView!
    var lib_link_dictonary = [String:String]()
    
    struct AllInfo: Decodable {
        let sogang: BookInfoWithLink
        let yonsei: BookInfoWithLink
        let ewha: BookInfoWithLink
        let hongik: BookInfoWithLink
    }
    
    struct BookInfoWithLink: Decodable{
        let url:String?
        let books:[BookInfo]
    }
    
    struct BookInfo: Decodable {
        let no: String?
        let location: String?
        let callno: String?
        let id: String?
        let status: String?
        let returndate: String?
    }
    
    struct cellData{
        var opened = Bool()
        var title = String()
        var sectionData = [BookInfo]()
        var univ = String()//의미없는듯
        
        init(opened:Bool, title:String, sectionData:[BookInfo]){
            self.opened = opened
            self.title = title
            self.sectionData = sectionData
        }
    }
    
    struct mappingInfo_libToMap{
        var sogang = [String:String]()
        var yonsei = [String:String]()
        var ewha = [String:String]()
        var hongik = [String:String]()
        var error = "https://m.map.kakao.com/actions/searchView?q=xxxxxxxxxxxx"
        init(){
            self.sogang = ["로욜라도서관":"https://place.map.kakao.com/9102435","법학전문도서관":"https://place.map.kakao.com/23728235"]
            self.yonsei = ["학술정보원":"https://place.map.kakao.com/8476510","법학도서관":"https://place.map.kakao.com/17561869","국학자료실":"https://place.map.kakao.com/8476510","음악대학도서실":"https://place.map.kakao.com/11102292","국제학도서관":"https://place.map.kakao.com/17808657","국학연구원도서실":"https://place.map.kakao.com/17556110","연합신학대학원도서관":"https://place.map.kakao.com/26348257","수학과도서실":"https://place.map.kakao.com/17555971"]
            self.ewha = ["중앙도서관":"https://place.map.kakao.com/17806917","공학도서관":"https://place.map.kakao.com/26773294","법학도서관":"https://place.map.kakao.com/17806917","신학도서관":"https://place.map.kakao.com/8548332","음악도서관":"https://place.map.kakao.com/24582790"]
            self.hongik = ["중앙도서관":"https://place.map.kakao.com/9605494","법학도서관":"https://place.map.kakao.com/17558523"]
        }
    }
    
    var mappingInfo_libTpMap = mappingInfo_libToMap()
    var tableViewData = [cellData]()
    var flag:Bool = true
    var allinfo:AllInfo?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    func getBookInfoFromLibrary() {
        let lambda_url = "https://kw7eq88ls8.execute-api.ap-northeast-2.amazonaws.com/Prod/libinfo?isbn="
        
        if self.selectedBook!.isbn == nil {
            NSLog("There is no ISBN for this book")
            return;
        }
        
        let isbns = selectedBook?.isbn?.components(separatedBy: " ")
        //let len10 = String(isbns?[0] ?? "")
        let len13 = String(isbns?[1] ?? "")
        
        NSLog("len10:\(String(describing: isbns?[0])) + || + len13:\(String(describing: isbns?[1]))")
        //guard let url_len10 = URL(string: lambda_url + len10) else{return}
        guard let url_len13 = URL(string: lambda_url + len13) else{return}
        
        if len13 != "" {
            URLSession.shared.dataTask(with: url_len13) { (data, response, err) in
                NSLog("len13url : \(url_len13)")
                guard let data = data else {return}
                if data.isEmpty{
                    NSLog("There's No data responsed from Libraries ISBN Number:\(len13)")
                }
                else {
                    do {
                        let allinfo = try JSONDecoder().decode(AllInfo.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            
                            self.allinfo = allinfo
                            print("\(self.allinfo?.sogang.books.count as Optional)")
                            print("\(self.allinfo?.yonsei.books.count as Optional)")
                            print("\(self.allinfo?.ewha.books.count as Optional)")
                            print("\(self.allinfo?.hongik.books.count as Optional)")
                            
                            var flag = -1
                            if self.allinfo?.sogang.books.count ?? 0 > 0 {
                                flag=0
                                NSLog("Library url : \(allinfo.sogang.url ?? "None")")
                                self.lib_link_dictonary["url_sogangLib"] = allinfo.sogang.url ?? "http://library.sogang.ac.kr/search/tot/result?st=EXCT&si=TOTAL&q=xxxxxx"
                                self.allinfo?.sogang.books.forEach{ book in
                                    if book.status == "대출중" {
                                        if flag < 2 {flag=1}
                                    }
                                    else if book.status == "대출가능" {
                                        flag=2
                                    }
                                    self.tableViewData[0].sectionData.append(book)
                                    self.tableViewData[0].univ = "sogang"//무의미
                                }
                            }
                            self.coloring(status: self.sogang_status, flag: flag)
                            
                            flag = -1
                            if self.allinfo?.yonsei.books.count ?? 0 > 0 {
                                flag=0
                                NSLog("Library url : \(allinfo.yonsei.url ?? "None")")
                                self.lib_link_dictonary["url_yonseiLib"] = allinfo.yonsei.url ?? "http://library.sogang.ac.kr/search/tot/result?st=EXCT&si=TOTAL&q=xxxxxx"
                                self.allinfo?.yonsei.books.forEach{ book in
                                    if book.status == "대출중" {
                                        if flag < 2 {flag=1}
                                    }
                                    else if book.status == "대출가능" {
                                        flag=2
                                    }
                                    self.tableViewData[1].sectionData.append(book)
                                    self.tableViewData[1].univ = "yonsei"//무의미
                                }
                            }
                            self.coloring(status: self.yonsei_status, flag: flag)
                            
                            flag = -1
                            if self.allinfo?.ewha.books.count ?? 0 > 0 {
                                flag=0
                                NSLog("Library url : \(allinfo.ewha.url ?? "None")")
                                self.lib_link_dictonary["url_ewhaLib"] = allinfo.ewha.url ?? "http://library.sogang.ac.kr/search/tot/result?st=EXCT&si=TOTAL&q=xxxxxx"
                                self.allinfo?.ewha.books.forEach{ book in
                                    if book.status == "대출중" {
                                        if flag < 2 {flag=1}
                                    }
                                    else if book.status == "대출가능" {
                                        flag=2
                                    }
                                    self.tableViewData[2].sectionData.append(book)
                                    self.tableViewData[2].univ = "ewha"//무의미
                                }
                            }
                            self.coloring(status: self.ewha_status, flag: flag)
                            
                            flag = -1
                            if self.allinfo?.hongik.books.count ?? 0 > 0 {
                                flag=0
                                NSLog("Library url : \(allinfo.hongik.url ?? "None")")
                                self.lib_link_dictonary["url_hongikLib"] = allinfo.hongik.url ?? "http://library.sogang.ac.kr/search/tot/result?st=EXCT&si=TOTAL&q=xxxxxx"
                                self.allinfo?.hongik.books.forEach{ book in
                                    if book.status == "대출중" {
                                        if flag < 2 {flag=1}
                                    }
                                    else if book.status == "대출가능" {
                                        flag=2
                                    }
                                    self.tableViewData[3].sectionData.append(book)
                                    self.tableViewData[3].univ = "hongik"//무의미
                                }
                            }
                            
                            self.activityIndicator.stopAnimating()//스피너 종료.
                            self.coloring(status: self.hongik_status, flag: flag)
                            
                            self.UnivLogoGestureInit(status: self.logo_sogang, url:allinfo.sogang.url)
                            self.UnivLogoGestureInit(status: self.logo_yonsei,url:allinfo.yonsei.url)
                            self.UnivLogoGestureInit(status: self.logo_ewha, url:allinfo.ewha.url)
                            self.UnivLogoGestureInit(status: self.logo_hongik, url:allinfo.hongik.url)
                            self.tableView.reloadData()
                        }
                    } catch let jsonErr {
                        print("Error", jsonErr)
                    }
                }
            }.resume()
        }
    }
    
    func UnivLogoGestureInit(status: UIImageView, url:String?){
        status.isUserInteractionEnabled = true
        let tappy = UnivLogoTapGesture(target: self, action: #selector(self.openUnivLibpage))
        tappy.url = (url ?? nil)!
        status.addGestureRecognizer(tappy)
    }
    
    @objc func openUnivLibpage(sender:UnivLogoTapGesture){
        if sender.url != ""{
            self.openSafariView(urlString: sender.url)
        }
        else{
            let alert = UIAlertController(title: "해당 도서는 비치되어 있지 않습니다.", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler : nil )
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func coloring(status: UILabel, flag: Int) {
        if flag < 0 {
            status.text = "책없음"
            status.textColor = UIColor.black
        }
        else if flag == 1 {
            status.text = "대출중"
            status.textColor = UIColor.orange
        }
        else if flag == 2 {
            status.text = "대출가능"
            status.textColor = UIColor.colorWithRGBHex(hex: 0x00994c, alpha: 1.0)
        }
        else {
            status.text = "대출불가"
            status.textColor = UIColor.red
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        booktitle.text = selectedBook?.title
        author.text = selectedBook?.author
        publisher.text = selectedBook?.publisher
        pubdate.text = selectedBook?.pubdate
        let cut_isbn = selectedBook?.isbn?.components(separatedBy: " ")
        isbn.text = cut_isbn?[1]
        //link.text = selectedBook?.link
        bookImageView.image = selectedBook?.image
        
        sogang_status.textColor = UIColor.white
        yonsei_status.textColor = UIColor.white
        ewha_status.textColor = UIColor.white
        hongik_status.textColor = UIColor.white
        
        tableViewData = [
            cellData(opened: false, title: "서강대학교", sectionData: []),
            cellData(opened: false, title: "연세대학교", sectionData: []),
            cellData(opened: false, title: "이화여자대학교", sectionData: []),
            cellData(opened: false, title: "홍익대학교", sectionData: [])
        ]
        
        //MARK : spinner 추가.
        self.view.addSubview(self.activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.activityIndicator.startAnimating()//lambda에 요청하기 전에 스피너 애니메이션 시작.
        
        getBookInfoFromLibrary()//내부에서 정보 다 가져오면 종료
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        }
        else {
            return 1
        }
    }
    
    
    //MARK : 위치정보가 담긴 라벨을 클릭하면 해당 도서관 위치를 나타내는 카카오 지도 사파리뷰를 열어주는 함수. sender에 속성값으로 section번호:어디학교인가? 와 location값 받아옴.
    @objc func openKakaoMap(sender:MyTapGesture){
        var parsedloc:String!
        var urlString:String!
        NSLog("Section Num : \(sender.univ_sectionNum)")
        switch sender.univ_sectionNum{
        case 0:
            parsedloc = sender.location.components(separatedBy: " ")[0]
            if parsedloc.range(of:"법학전문도서관") != nil {
                urlString = self.mappingInfo_libTpMap.sogang["법학전문도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.isEmpty != true{
                urlString = self.mappingInfo_libTpMap.sogang["로욜라도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else{
                urlString = self.mappingInfo_libTpMap.error
            }
            ; break
        case 1:
            var tmp = sender.location.components(separatedBy:["]","/"])
            NSLog("section1 univ parsed:"+tmp[0] + ":" + tmp[1] + ":" + tmp[2])
            parsedloc = tmp[1]
            if parsedloc.contains("학술정보원") || parsedloc.contains("국학자료실") { // 두 곳은 모두 같은 건물에 있다.
                urlString = self.mappingInfo_libTpMap.yonsei["학술정보원"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("법학도서관") {
                urlString = self.mappingInfo_libTpMap.yonsei["법학도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("음악도서관"){
                urlString = self.mappingInfo_libTpMap.yonsei["음악대학도서실"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("국제학도서관"){
                urlString = self.mappingInfo_libTpMap.yonsei["국제학도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("국학연구원도서실"){
                urlString = self.mappingInfo_libTpMap.yonsei["국학연구원도서실"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("연합신학대학원도서관"){
                urlString = self.mappingInfo_libTpMap.yonsei["연합신학대학원도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("수학과도서실"){
                urlString = self.mappingInfo_libTpMap.yonsei["수학과도서실"] ?? self.mappingInfo_libTpMap.error
            }
            else{
                urlString = self.mappingInfo_libTpMap.error
            }; break
        case 2:
            var tmp = sender.location.components(separatedBy:["]","/"," "])
            //NSLog("section2 univ parsed:"+tmp[0] + ":" + tmp[1])
            parsedloc = tmp[0]
            if parsedloc.contains("중앙도서관") || parsedloc.contains("법학도서관") { // 세곳은 모두 같은 건물에 있다.
                urlString = self.mappingInfo_libTpMap.ewha["중앙도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("신학도서관") {
                urlString = self.mappingInfo_libTpMap.ewha["신학도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("공학도서관"){
                urlString = self.mappingInfo_libTpMap.ewha["공학도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("음악도서관"){
                urlString = self.mappingInfo_libTpMap.ewha["음악도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else{
                urlString = self.mappingInfo_libTpMap.error
            }; break
        case 3:
            var tmp = sender.location.components(separatedBy:["]","/"," "])
            //NSLog("section3 univ parsed:"+tmp[0] + ":" + tmp[1])
            parsedloc = tmp[0]
            if parsedloc.contains("중앙도서관"){
                urlString = self.mappingInfo_libTpMap.hongik["중앙도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else if parsedloc.contains("법학도서관"){
                urlString = self.mappingInfo_libTpMap.hongik["법학도서관"] ?? self.mappingInfo_libTpMap.error
            }
            else{
                urlString = self.mappingInfo_libTpMap.error
            };break
        default:
            NSLog("Sender Number is Invalid")
            urlString = self.mappingInfo_libTpMap.error
        }
//        let url = URL(string:urlString)!
//        let webVC = SFSafariViewController(url: url)
//        present(webVC, animated: true, completion: nil)
        openSafariView(urlString: urlString)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_header")as! LibInfoHeaderCell? else {
                return UITableViewCell()
            }
            cell.univ.text = tableViewData[indexPath.section].title
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_content")as! LibInfoContentCell? else {
                return UITableViewCell()
            }
            let bookinfo : BookInfo = tableViewData[indexPath.section].sectionData[dataIndex]
            guard let location = bookinfo.location, let callno = bookinfo.callno, let id = bookinfo.id, let returndate = bookinfo.returndate, let status = bookinfo.status else {
                return cell
            }
            
            //label과 클릭이벤트 : 지도 띄워주기를 연결해주는 부분.
            cell.location.isUserInteractionEnabled = true
            let tappy = MyTapGesture(target: self, action: #selector(self.openKakaoMap))
            tappy.location = "\(location)"
            tappy.univ_sectionNum = indexPath.section
            cell.location.addGestureRecognizer(tappy)
            
            cell.location.text = "\(location)"
            cell.callno.text = "\(callno)"
            cell.id.text = "\(id)"
            cell.returndate.text = "\(returndate)"
            cell.status.text = "\(status)"
            if "\(status)"=="대출중" {
                cell.status.textColor=UIColor.orange
            }
            else if "\(status)"=="대출가능" {
                cell.status.textColor=UIColor.colorWithRGBHex(hex: 0x00994c, alpha: 1.0)
            }
            else {
                cell.status.textColor=UIColor.red
            }
            return cell
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if self.tableViewData[indexPath.section].opened == true {
                self.tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                self.tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
    }
    
    func openSafariView(urlString:String){
        let url = URL(string:urlString)!
        let webVC = SFSafariViewController(url: url)
        present(webVC, animated: true, completion: nil)
    }
}

extension UIColor {
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}

class MyTapGesture: UITapGestureRecognizer {
    var location = String()
    var univ_sectionNum = Int()
}

class UnivLogoTapGesture: UITapGestureRecognizer{
    var url = String()
}
