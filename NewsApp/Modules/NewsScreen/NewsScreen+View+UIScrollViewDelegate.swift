//
//  NewsScreen+UIScrollViewDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import UIKit

extension NewsScreen.View {
    struct ScrollState {
        var prevScrollOffset: CGFloat = 0
        var scrollingDirection = 0
        var currentDirectionBeginScrollOffset: CGFloat = 0
        var lockScroll = false
    }
}

extension NewsScreen.View {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollState.lockScroll && _viewDidAppear {
            let contentOffset = scrollView.contentOffset.y
    
            let deltaToShowBar: CGFloat = 0
            if (contentOffset) < (scrollView.contentSize.height - scrollView.frame.size.height) || contentOffset < 0 {
                if scrollState.prevScrollOffset < contentOffset && contentOffset > 0 || contentOffset > scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.height {
                    //Scrolled down:
                    if scrollState.scrollingDirection != 1 {
                        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
                        prevTopBarVisibleHeight = //Self.topBarHeight +
                            topBarTopConstraint.constant
                        scrollState.scrollingDirection = 1
                    }
                    if abs(contentOffset - scrollState.currentDirectionBeginScrollOffset) > deltaToShowBar {
                        var delta = topBarTopConstraint.constant
                        if scrollView.contentSize.height > scrollView.frame.height + /*Self.topBarHeight +*/ deltaToShowBar {
                            topBarTopConstraint.constant =
                                max(
                                    topBarTopConstraint.constant - contentOffset - -scrollState.prevScrollOffset, 0//-Self.topBarHeight
                                ) //+ Self.topBarHeight
                        } else {
                            topBarTopConstraint.constant = Self.topBarHeight//0
                        }
                        delta = topBarTopConstraint.constant - delta
                        scrollState.lockScroll = true
                        scrollView.contentOffset.y = max(scrollView.contentOffset.y + delta, 0)
                        scrollState.lockScroll = false
                    }
                } else if scrollState.prevScrollOffset > contentOffset {
                    //Scrolled up:
                    if scrollState.scrollingDirection != -1 {
                        scrollState.currentDirectionBeginScrollOffset = contentOffset
                        prevTopBarVisibleHeight = //Self.topBarHeight +
                            topBarTopConstraint.constant
                        scrollState.scrollingDirection = -1
                    }
                    if abs(contentOffset - scrollState.currentDirectionBeginScrollOffset) > deltaToShowBar || contentOffset <= 0 {
                        if contentOffset <= 0 {
                            topBarTopConstraint.constant = Self.topBarHeight//0
                            UIView.animate(withDuration: 0.4) {
                                self.topBar.clearShadow()
                                self.view.layoutIfNeeded()
                                self.view.setNeedsDisplay()
                            }
                        } else {
                            var delta = topBarTopConstraint.constant
                            topBarTopConstraint.constant = min(
                                topBarTopConstraint.constant - contentOffset - -scrollState.prevScrollOffset, Self.topBarHeight)
                            delta = topBarTopConstraint.constant - delta
                            scrollState.lockScroll = true
                            scrollView.contentOffset.y += delta
                            scrollState.lockScroll = false
                        }
                    }
                }
                searchBar.alpha = topBarTopConstraint.constant / Self.topBarHeight
                topBar.dropShadow(opacity: 0.2 * Float(1 - abs(-topBarTopConstraint.constant) / Self.topBarHeight), radius: 20)
                scrollState.prevScrollOffset = scrollView.contentOffset.y
            }
        }
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            
            presenter.scrollDidReachBounds(withOffset: scrollView.contentOffset.y - scrollView.frame.minY)
        }
    }
    
    /*func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollState.prevScrollOffset = scrollView.contentOffset.y
        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
        scrollState.scrollingDirection = 0
        
        if topBarTopConstraint.constant > Self.topBarHeight/2 {
            topBarTopConstraint.constant = Self.topBarHeight//0
            
            topBar.clearShadow()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.view.setNeedsDisplay()
            }
        } else {
            topBarTopConstraint.constant = 0//-Self.topBarHeight
            UIView.animate(withDuration: 0.3) {
                self.topBar.dropShadow(opacity: 0.2, radius: 20)
                self.view.layoutIfNeeded()
                self.view.setNeedsDisplay()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Decide to continue showing or hiding bar
        scrollState.prevScrollOffset = scrollView.contentOffset.y
        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
        scrollState.scrollingDirection = 0
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }*/
}
