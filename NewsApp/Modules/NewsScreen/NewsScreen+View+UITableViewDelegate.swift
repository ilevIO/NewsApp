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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            cell.configure(with: self.news[indexPath.row])
        }
        cell.toggleExpanded = { [weak self] in
            self?.presenter.news[indexPath.row].isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            print("xxx")
        }
        //contentView.subviews.first?.layoutSubviews()
        /*(cell.contentView.subviews.first as? ArticleCellView)?.labelsStackView.arrangedSubviews.forEach { $0.layoutSubviews() }
        cell.contentView.subviews.first?.setNeedsLayout()
        cell.contentView.subviews.first?.layoutIfNeeded()
        cell.contentView.layoutIfNeeded()
        cell.contentView.layoutSubviews()
        cell.layoutIfNeeded()
        cell.layoutSubviews()*/
        //tableView.reloadRows(at: [indexPath], with: .none)
    }
}
