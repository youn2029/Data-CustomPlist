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
    
    @IBOutlet var account: UITextField!         // 계정
    @IBOutlet var name: UILabel!                // 이름
    @IBOutlet var gender: UISegmentedControl!   // 성별
    @IBOutlet var married: UISwitch!            // 결혼여부
    
    // 테이블 셀이 선택될 때 호출되는 메소드 (이름 레이블이 선택될 때 호출)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {     // 이름을 선택했을 때
            
            // 이름을 입력받는 알림창
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요", preferredStyle: .alert)
            
            alert.addTextField {
                $0.text = self.name.text
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default){ (_) in
                let value = self.name.text
                
                // 프로퍼티 리스트에 저장
                let plist = UserDefaults.standard
                plist.set(value, forKey: "name")
                plist.synchronize()
                
                // 레이블에 입력 값 전달
                self.name.text = value
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 세그먼트 컨트롤러의 값이 변경될 때 호출되는 메소드
    @IBAction func changeGender(_ sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex
        
        let plist = UserDefaults.standard
        plist.set(value, forKey: "gender")
        plist.synchronize()
    }
    
    // 스위치의 값이 변경될 때 호출되는 메소드
    @IBAction func changeMarried(_ sender: UISwitch) {
        let value = sender.isOn
        
        let plist = UserDefaults.standard
        plist.set(value, forKey: "married")
        plist.synchronize()
    }
    
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
        
        self.account.text = self.accountlist[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setPicker()
        
        // 기본 저장소 객체 불러오기
        let plist = UserDefaults.standard
        
        self.name.text = plist.string(forKey: "name")
        self.gender.selectedSegmentIndex = plist.integer(forKey: "gender")
        self.married.isOn = plist.bool(forKey: "married")
    }
    
    // 피커 뷰 설정 메소드
    func setPicker(){
        
        let picker = UIPickerView()
        
        picker.delegate = self              // 피커 뷰의 델리게이트 객체 지정
        self.account.inputView = picker     // 텍스트 필드 입력 방식을 가상 키보드 대신 피커 뷰로 설정
        
        // 툴 바 객체 정의
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = .lightGray
        
        // 액세서리 뷰 영역에 툴 바 표시
        self.account.inputAccessoryView = toolbar
        
        // 신규 계정 등록 버튼
        let new = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(NewAccount(_:)))
        
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
    }
    
    // 신규 계정 등록 버튼 액션 메소드
    @objc func NewAccount(_ sender: Any){
        
        // 텍스트 필드가 포함된 알림창을 띄워 새로운 계정을 입력 받은 다음 accountlist 배열에 추가
        let alert = UIAlertController(title: nil, message: "계정 이메일을 입력하세요", preferredStyle: .alert)
        
        alert.addTextField {
            $0.placeholder = "ex) abc@naver.com"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default){ (_) in
            if let value = alert.textFields?[0].text {  // 텍스트 필드에 값이 있으면
                
                // 초기화
                self.name.text = ""
                self.gender.selectedSegmentIndex = 0
                self.married.isOn = false
                
                self.accountlist.append(value)
                self.account.text = value
                self.view.endEditing(true)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: false, completion: nil)
    }


}

