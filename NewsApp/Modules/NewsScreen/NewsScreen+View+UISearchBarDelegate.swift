//
//  NewsScreen+View+UISearchBarDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import UIKit

extension NewsScreen.View: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchQueryChanged(to: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        isSearchExpanded = false
    }
}
