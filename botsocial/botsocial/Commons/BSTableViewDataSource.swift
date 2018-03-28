//
//  BSTableViewDataSource.swift
//  botsocial
//
//  Created by Aamir  on 27/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit

class BSTableViewDataSource: NSObject,UITableViewDataSource {
    var isLoading = false
    var showsLoadingCell = false
    var emptyStateTitle = "Nothing here"
    var dataModel:[AnyObject] = []
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.isLoading == false else {return 1}
        return 1 + self.dataModel.count
  }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.isLoading == false else {return 1}
        return self.dataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.isLoading == false else {
            return tableView.dequeueReusableCell(withIdentifier: kLoadingCellReuseID)!
        }
        return UITableViewCell()
    }
}
