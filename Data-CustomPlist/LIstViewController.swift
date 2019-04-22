//
//  ViewController.swift
//  Data-CustomPlist
//
//  Created by 윤성호 on 19/04/2019.
//  Copyright © 2019 윤성호. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 계정을 담은 배열
    var accountlist = [String]()
    
    // 메인 번들에 정의된 PList 내용을 저장할 딕셔너리
    var defaultPList: NSDictionary!
    
    @IBOutlet var account: UITextField!         // 계정
    @IBOutlet var name: UILabel!                // 이름
    @IBOutlet var gender: UISegmentedControl!   // 성별
    @IBOutlet var married: UISwitch!            // 결혼여부
    
    // 컴포넌트의 객수 설정
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 컨포넌트가 가질 목록의 길이 정의
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.accountlist.count
    }
    
    // 컴포넌트의 목록 각 행에 출력될 내용
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.accountlist[row]
    }
    
    // 컴포넌트의 목록을 선택했을 때 이벤트 처리
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 피커 뷰에서 선택된 항목을 화면에 표시
        self.account.text = self.accountlist[row]
        
        // UserDefaults 객체에 선택된 계정 저장
        let plist = UserDefaults.standard
        plist.set(self.accountlist[row], forKey: "selectedAccount")
    }
    
    // 테이블 셀이 선택될 때 호출되는 메소드 (이름 레이블이 선택될 때 호출)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && !(self.account.text?.isEmpty)!{     // 이름을 선택되었고, 계정 텍스트가 비어있지 않을 때
            
            // 이름을 입력받는 알림창
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
            
            // 텍스트 필드 추가
            alert.addTextField {
                // 초기화
                $0.text = self.name.text
            }
            
            // ok 버튼 추가
            alert.addAction(UIAlertAction(title: "OK", style: .default){ (_) in
                
                // 텍스트 필드에 입력된 값
                let value = alert.textFields?[0].text
                
                // 값 저장
                let customPlist = "\(self.account.text!).plist"
                
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let path = paths[0] as NSString
                let plist = path.strings(byAppendingPaths: [customPlist]).first!
                let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPList)
                
                data.setValue(value, forKey: "name")
                data.write(toFile: plist, atomically: true)
                
                // 레이블에 입력 값 전달
                self.name.text = value
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))       // cancel 버튼 추가
            
            // 알림창 띄우기
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 세그먼트 컨트롤러의 값이 변경될 때 호출되는 메소드
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex     // 세그먼트 컨트롤러에서 선택된 인덱스 값
        
        NSLog("gender = \(value)")
        
        // 값 저장
        let customPlist = "\(self.account.text!).plist"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPList)
        
        data.setValue(value, forKey: "gender")
        data.write(toFile: plist, atomically: true)
    }
    
    // 스위치의 값이 변경될 때 호출되는 메소드
    @IBAction func changeMarried(_ sender: UISwitch) {
        let value = sender.isOn                     // 스위치에 선택된 값
        
        print("married : \(value)")
        
        // 값 저장
        let customPlist = "\(self.account.text!).plist"
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        let plist = path.strings(byAppendingPaths: [customPlist]).first!
        let data = NSMutableDictionary(contentsOfFile: plist) ?? NSMutableDictionary(dictionary: self.defaultPList)
        
        data.setValue(value, forKey: "married")
        data.write(toFile: plist, atomically: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 피커 뷰 설정
        self.setPicker()
        
        // 네비게이션 오른쪽 버튼 추가
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newAccount(_:)))
        self.navigationItem.rightBarButtonItem = addBtn

        // UserDefaults 프로퍼티에서
        let plist = UserDefaults.standard
        
        // 메인 번들에 UserInfo.Plist가 포함되어 있으면 이를 읽어와 딕셔너리에 담는다
        if let defaultPListPath = Bundle.main.path(forResource: "UserInfo", ofType: "plist") {
            self.defaultPList = NSDictionary(contentsOfFile: defaultPListPath)
        }
        
        // 계정 리스트 불러오기
        let accountlist = plist.array(forKey: "accountlist") as? [String] ?? [String]()
        self.accountlist = accountlist
        
        // 선택된 계정 정보
        if let account = plist.string(forKey: "selectedAccount") {      // 선택된 계정 정보가 있으면
            self.account.text = account     // 화면에 표시
            
            // 커스텀 프로퍼티에서 해당 값 가져오기
            let customPlist = "\(account).plist"            // 커스텀 프로퍼티 파일명
            
            // 애플리케이션 내에 있는 문서 파일을 읽어온다
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths[0] as NSString
            let clist = path.strings(byAppendingPaths: [customPlist]).first!        // 해당 경로에 파일명을 붙여서 저장할 경로를 만듬
            let data = NSDictionary(contentsOfFile: clist)                          // 해당 경로에 파일을 읽어온다
            
            // 해당 계정의 정보 표시
            self.name.text = data?["name"] as? String
            self.gender.selectedSegmentIndex = data?["gender"] as? Int ?? 0
            self.married.isOn = data?["married"] as? Bool ?? false
        }
        
        if (self.account.text?.isEmpty)! {      // 계정 정보가 비어있으면
            self.account.placeholder = "등록된 계정이 없습니다."
            self.gender.isEnabled = false       // 비활성화
            self.married.isEnabled = false      // 비활성화
        }
    }
    
    // 피커 뷰 설정 메소드
    func setPicker(){
        
        let picker = UIPickerView()         // 피커 뷰 객체 생성
        
        picker.delegate = self              // 피커 뷰의 델리게이트 객체 지정
        self.account.inputView = picker     // 텍스트 필드 입력 방식을 가상 키보드 대신 피커 뷰로 설정
        
        // 툴 바 객체 정의
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = .lightGray
        
        // 액세서리 뷰 영역에 툴 바 표시
        self.account.inputAccessoryView = toolbar
        
        // 신규 계정 등록 버튼
        let new = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(newAccount(_:)))
        
        // 툴 바에 들어갈 닫기 버튼
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerDone(_:)))
        
        // 가변 폭
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 버튼을 툴 바에 추가
        toolbar.setItems([new, flexSpace, done], animated: true)
    }
    
    // 닫기 버튼의 액션 메소드
    @objc func pickerDone(_ sender: Any){
        
        // 입력 뷰 닫기
        self.view.endEditing(true)
        
        // 선택된 계정에 대한 커스텀 프로퍼티 파일을 읽어와 세팅
        if let account = self.account.text {
            let customPlist = "\(account).plist"
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)      // 앱 내의 작성된 문서 디렉터리 경로
            let path = paths[0] as NSString
            let plist = path.strings(byAppendingPaths: [customPlist]).first!
            let data = NSDictionary(contentsOfFile: plist)
            
            self.name.text = data?["name"] as? String
            self.gender.selectedSegmentIndex = data?["gender"] as? Int ?? 0
            self.married.isOn = data?["married"] as? Bool ?? false
            
        }
    }
    
    // 신규 계정 등록 버튼 액션 메소드
    @objc func newAccount(_ sender: Any){
        self.view.endEditing(true)
        
        // 텍스트 필드가 포함된 알림창을 띄워 새로운 계정을 입력 받은 다음 accountlist 배열에 추가
        let alert = UIAlertController(title: nil, message: "계정 이메일을 입력하세요", preferredStyle: .alert)
        
        alert.addTextField {
            // 초기화
            $0.placeholder = "ex) abc@naver.com"
        }
        
        // ok 버튼 추가
        alert.addAction(UIAlertAction(title: "OK", style: .default){ (_) in
            
            if let account = alert.textFields?[0].text {  // 텍스트 필드에 값이 있으면
                
                self.gender.isEnabled = true
                self.married.isEnabled = true
                
                // 계정의 정보 초기화
                self.name.text = ""
                self.gender.selectedSegmentIndex = 0
                self.married.isOn = false
                
                self.accountlist.append(account)        // 계정 배열에 추가
                self.account.text = account
                
                let plist = UserDefaults.standard       // UserDefaults 객체
                
                // 계정 배열과 선택된 계정 정보 저장
                plist.set(self.accountlist, forKey: "accountlist")
                plist.set(account, forKey: "selectedAccount")
                plist.synchronize()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: false, completion: nil)
    }
    
}

