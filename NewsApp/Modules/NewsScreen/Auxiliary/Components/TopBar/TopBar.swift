//
//  TopBar.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/27/21.
//

import Foundation
import UIKit

class NewsTopBarView: UIView {
    
    struct SearchControlHandlers {
        var onSearchButtonTapped: (() -> Void)? = nil
        var onSearchCancelTapped: (() -> Void)? = nil
        var onSearchQueryChanged: ((String) -> Void)? = nil
    }

    var searchControlHandlers: SearchControlHandlers
    //MARK: - Subviews
    var contentView: UIView = .init()
    
    var categoriesStackView: CategoriesStackView = .init()
    var categoriesScrollView: UIScrollView = .init()
    var searchButton: UIButton = .init()
    var searchBar: UISearchBar = .init()
    
    //MARK: - Constraints
    var expandedSearchConstraints: [NSLayoutConstraint] = []
    var collapsedSearchConstraints: [NSLayoutConstraint] = []
    
    //MARK: - Handlers
    @objc func searchButtonTapped(_ sender: UIButton) {
        searchControlHandlers.onSearchButtonTapped?()
        enableExpandedSearchLayout()
        searchBar.becomeFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.setNeedsDisplay()
        }
    }
    
    func enableExpandedSearchLayout() {
        searchBar.isHidden = false
        searchButton.isHidden = true
        NSLayoutConstraint.deactivate(collapsedSearchConstraints)
        NSLayoutConstraint.activate(expandedSearchConstraints)
    }
    
    func enableCollapsedSearchLayout() {
        searchBar.isHidden = true
        searchButton.isHidden = false
        NSLayoutConstraint.deactivate(expandedSearchConstraints)
        NSLayoutConstraint.activate(collapsedSearchConstraints)
    }
    
    //MARK: - Setup
    private func buildHierarhy() {
        addSubview(contentView)
        contentView.addSubview(categoriesScrollView)
        categoriesScrollView.addSubview(categoriesStackView)
        contentView.addSubview(searchBar)
        contentView.addSubview(searchButton)
    }
    
    private func configureSubviews() {
        categoriesStackView.axis = .horizontal
        categoriesStackView.alignment = .bottom
        categoriesScrollView.showsHorizontalScrollIndicator = false
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        
        searchBar.showsCancelButton = true
        searchBar.backgroundImage = .init()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
    }
    
    private func setupLayout() {
        fillLayout(with: contentView)
        
        categoriesScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoriesScrollView.attach(to: contentView, left: 0, top: 0, bottom: 0)
        
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.attach(to: categoriesScrollView, left: 0, right: 0)
        categoriesStackView.attach(to: contentView, bottom: 0)
        categoriesStackView.attach(to: searchBar, top: 0)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            categoriesScrollView.rightAnchor.constraint(equalTo: searchBar.leftAnchor, constant: 0)
        ])
        searchBar.attach(to: contentView, right: 0, bottom: 0)
        expandedSearchConstraints = [
            searchBar.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ]
        collapsedSearchConstraints = [
            searchBar.widthAnchor.constraint(equalTo: searchBar.heightAnchor, multiplier: 1.0)
        ]
        enableCollapsedSearchLayout()
        searchBar.fillLayout(with: searchButton)
    }
    
    private func setup() {
        buildHierarhy()
        configureSubviews()
        setupLayout()
    }
    
    init(searchControlHandlers: SearchControlHandlers, frame: CGRect = .init()) {
        self.searchControlHandlers = searchControlHandlers
        
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewsTopBarView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchControlHandlers.onSearchQueryChanged?(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endEditing(true)
        searchControlHandlers.onSearchCancelTapped?()
        enableCollapsedSearchLayout()
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.setNeedsDisplay()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        endEditing(true)
    }
}
