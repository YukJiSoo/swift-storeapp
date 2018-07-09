//
//  ViewController.swift
//  SwiftShoppingApp
//
//  Created by GwakDoyoung on 08/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Toaster

// # MARK - ViewController

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let model: StoreModel = StoreModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 불러온 데이터를 테이블뷰에 표시
        tableView.reloadData()
        
        // 데이터 불러오기
        model.loadData() { success in
            DispatchQueue.main.async {
                if success {
                    // 불러온 데이터를 테이블뷰에 표시
                    self.tableView.reloadData()
                } else {
                    print("something is fail")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.itemCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreItemCell", for: indexPath)
        if let productCell = cell as? StoreItemCell,
            let item = model.item(with: indexPath.section, with: indexPath.row) {
            productCell.setProductInfo(info: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreSectionHeader", for: IndexPath())
        if let sectionHeader = cell as? StoreSectionHeader {
            if let sectionInfo = model.section(with: section) {
                sectionHeader.set(info: sectionInfo)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = model.item(with: indexPath.section, with: indexPath.row) {
            Toast(text: "\(item.title)\n\(item.s_price)").show()
        }
    }
}



// # MARK: - View

class StoreItemCell: UITableViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var subheadLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var salePriceLabel: UILabel!
    
    var tagViews: [UILabel] = []
    
    func setProductInfo(info: StoreItem) {
        headLabel.text = info.title
        subheadLabel.text = info.description
        originalPriceLabel.text = "7,500"
        salePriceLabel.text = info.s_price
        
        mainImageView.layer.cornerRadius = mainImageView.frame.width/2
        mainImageView.layer.masksToBounds = true
        
        
        for tagView in tagViews { tagView.removeFromSuperview() }
        tagViews = []
        let fixedHeight: CGFloat = 22
        var labelX = headLabel.frame.origin.x
        let labelY = salePriceLabel.frame.origin.y + salePriceLabel.frame.height + 6.0
        let labelGap: CGFloat = 3.0
        let labelMargin: CGFloat = -2.0
        for deliveryType in info.delivery_type {
            let label = UILabel(frame: .zero)
            label.text = deliveryType
            label.backgroundColor = UIColor(red: 170.0/255.0, green: 116.0/255.0, blue: 191.0/255.0, alpha: 1.0)
            label.sizeToFit()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = .white
            
            label.frame = CGRect(x: labelX, y: labelY,
                                 width: label.frame.width + labelMargin*2,
                                 height: fixedHeight)
            self.addSubview(label)
            tagViews.append(label)
            
            labelX += label.frame.width + labelGap
        }
    }
}


class StoreSectionHeader: UITableViewCell {
    @IBOutlet weak var subtitleLabel: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    func set(info sectionInfo: StoreSection) {
        subtitleLabel.setTitle(sectionInfo.subtitle, for: .normal)
        titleLabel.text = sectionInfo.title
    }
    
    override func awakeFromNib() {
        subtitleLabel.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
        subtitleLabel.layer.borderWidth = 1
    }
    
    override func prepareForReuse() {
        // cell 재사용전에 호출되는 함수
    }
}

// # MARK - Model

class StoreModel {
    
    struct Constant {
        static let mainURL: String = "http://crong.codesquad.kr:8080/woowa/main"
        static let soupURL: String = "http://crong.codesquad.kr:8080/woowa/soup"
        static let sideURL: String = "http://crong.codesquad.kr:8080/woowa/side"
    }
    
    private let sectionInfos: Array<Dictionary<String, String>> = [
        [
            "section_url": Constant.mainURL,
            "section_subtitle": "메인반찬",
            "section_title": "한그릇 뚝딱 메인 요리"
        ], [
            "section_url": Constant.soupURL,
            "section_subtitle": "국.찌게",
            "section_title": "김이 모락모락 국.찌게"
        ], [
            "section_url": Constant.sideURL,
            "section_subtitle": "밑반찬",
            "section_title": "언제 먹어도 든든한 밑반찬"
        ]
    ]
    
    var mySections: Array<StoreSection> = []
    
    func loadData(reloadUI: @escaping (Bool)->()) {
        mySections = sectionInfos.map { sectionInfo in
            guard let sectionURL = sectionInfo["section_url"],
                let sectionTitle = sectionInfo["section_title"],
                let sectionSubtitle = sectionInfo["section_subtitle"] else {
                    return nil
            }
            let mySection = StoreSection(title: sectionTitle, subtitle: sectionSubtitle, items: [])
            self.loadData(from: sectionURL) { (productItems)  in
                
                if let productItems = productItems {
                    mySection.myitems = productItems
                    reloadUI(true)
                } else {
                    reloadUI(false)
                }
            }
            return mySection
        }.compactMap{ $0 }
    }
    
    private func loadData(from url: String, completion: @escaping ([StoreItem]?)->()) {
        guard let url = URL(string: url) else { completion(nil); return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with:url) { (data, response, error) in
            guard let data = data else { completion(nil); return }
            do {
                let productItems: [StoreItem] = try self.loadData(from: data as Data)
                completion(productItems)
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    private func loadData(from data: Data) throws -> [StoreItem] {
        let decoder = JSONDecoder()
        let productItems: [StoreItem] = try decoder.decode([StoreItem].self, from: data as Data)
        return productItems
    }
    
    var count: Int {
        return mySections.count
    }
    
    func itemCount(section: Int) -> Int {
        guard 0 <= section && section < count else {
            return 0
        }
        return mySections[section].count
    }
    
    func section(with section: Int) -> StoreSection? {
        guard 0 <= section && section < count else {
            return nil
        }
        return mySections[section]
    }
    func item(with section: Int, with row: Int) -> StoreItem? {
        guard section < count else {
            return nil
        }
        return mySections[section].item(with: row)
    }
}

class StoreSection {
    
    private(set) var title: String
    private(set) var subtitle: String
    var myitems: Array<StoreItem> = []
    
    init(title: String, subtitle: String, items: Array<StoreItem>) {
        self.myitems = items
        self.title = title
        self.subtitle = subtitle
    }
    
    var count: Int {
        return myitems.count
    }
    
    func item(with index: Int) -> StoreItem? {
        guard 0 <= index && index < count else {
            return nil
        }
        return myitems[index]
    }
}

struct StoreItem {
    let alt: String
    let delivery_type: [String]
    let description: String
    let detail_hash: String
    let image: String
    let s_price: String
    let title: String
}

extension StoreItem: Decodable { }