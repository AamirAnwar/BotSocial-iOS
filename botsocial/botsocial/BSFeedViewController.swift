//
//  BSFeedViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import SnapKit

//let kTestImageURL = "https://avatars3.githubusercontent.com/u/12379620?s=460&v=4"
var kTestImageURL:String {
    get {
        return "https://picsum.photos/250/300?random&key=\(arc4random())"
    }
}

var kTestFeaturedImageURL:String {
    get {
        return "https://picsum.photos/808/696?random&key=\(arc4random())"
    }
}

var kTestLargeImageURL:String {
    get {
        return "https://picsum.photos/750/800?random&key=\(arc4random())"
    }
}

class BSFeedViewController: UIViewController {

    let tableView = UITableView.init(frame: .zero, style: .plain)
    var postImages = [String]()
    let kFeedCellReuseIdentifier = "Feed_BSFeedTableViewCell"
    let kFeaturedCellReuseID = "BSFeaturedPostTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<20 {
            postImages += [kTestLargeImageURL]
        }
        print(postImages)
        self.tabBarItem.image = UIImage.init(named: "feed_tab_icon")
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delaysContentTouches = false
        self.tableView.register(BSFeaturedPostTableViewCell.self, forCellReuseIdentifier: self.kFeaturedCellReuseID)
        self.tableView.register(BSFeedTableViewCell.self, forCellReuseIdentifier: self.kFeedCellReuseIdentifier)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension BSFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return postImages.count
            
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: self.kFeaturedCellReuseID)!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: self.kFeedCellReuseIdentifier) as! BSFeedTableViewCell
            cell.setImageURL(postImages[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}
