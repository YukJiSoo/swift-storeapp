//
//  ViewController.swift
//  StoreApp
//
//  Created by Yoda Codd on 2019. 3. 25..
//  Copyright © 2019년 Drake. All rights reserved.
//

import UIKit
import os

class ViewController: UIViewController {
    
    @IBOutlet weak var storeItemTableView: UITableView!
    
    /// 스토어아이템 리스트를 생성
    private let dataSourceObject = DataSourceObject(storeItemManager: StoreItemSlot(storeItemList: StoreItemMaker.makeStoreItem()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블뷰에 데이터소스 입력
        self.storeItemTableView.dataSource = dataSourceObject
        
        // end of viewDidLoad
    }
}

