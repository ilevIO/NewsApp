//
//  NewsScreen+View+UITableView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import UIKit

extension NewsScreen.View: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.newsCellTapped(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! ArticleTableViewCell
        cell.selectionStyle = .none
        cell.configure(with: news[indexPath.row])
        cell.toggleExpanded = { [weak self] in
            self?.presenter.news[indexPath.row].isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return cell
    }
    
    
}
