//
//  NewsScreen+UIScrollViewDelegate.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import UIKit

extension NewsScreen.View {
    struct ScrollState {
        enum ScrollDirection {
            case none
            case up
            case down
        }
        
        var prevScrollOffset: CGFloat = 0
        var scrollingDirection: ScrollDirection = .none
        var currentDirectionBeginScrollOffset: CGFloat = 0
        var lockScroll = false
    }
}

extension NewsScreen.View: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView !== mainCollectionView else {
            //To prevent from bidirectional scroll
            scrollView.contentOffset.y = 0
            return
        }
        
        //Changes height of topBar based on scroll offset
        if shouldHideTopBarOnScroll && !scrollState.lockScroll && _viewDidAppear {
            let contentOffset = scrollView.contentOffset.y
    
            let deltaToShowBar: CGFloat = 0
            if (contentOffset) < (scrollView.contentSize.height - scrollView.frame.size.height) || contentOffset < 0 {
                if scrollState.prevScrollOffset < contentOffset && contentOffset > 0 || contentOffset > scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.height {
                    //Scrolled down:
                    if scrollState.scrollingDirection != .down {
                        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
                        prevTopBarVisibleHeight = topBarTopConstraint.constant
                        scrollState.scrollingDirection = .down
                    }
                    if abs(contentOffset - scrollState.currentDirectionBeginScrollOffset) > deltaToShowBar {
                        var delta = topBarTopConstraint.constant
                        if scrollView.contentSize.height > scrollView.frame.height + deltaToShowBar {
                            topBarTopConstraint.constant =
                                max(topBarTopConstraint.constant - contentOffset - -scrollState.prevScrollOffset, 0)
                        } else {
                            topBarTopConstraint.constant = Self.topBarHeight
                        }
                        delta = topBarTopConstraint.constant - delta
                        scrollState.lockScroll = true
                        scrollView.contentOffset.y = max(scrollView.contentOffset.y + delta, 0)
                        scrollState.lockScroll = false
                    }
                } else if scrollState.prevScrollOffset > contentOffset {
                    //Scrolled up:
                    if scrollState.scrollingDirection != .up {
                        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
                        prevTopBarVisibleHeight = topBarTopConstraint.constant
                        scrollState.scrollingDirection = .up
                    }
                    if abs(contentOffset - scrollState.currentDirectionBeginScrollOffset) > deltaToShowBar || contentOffset <= 0 {
                        if contentOffset <= 1 {
                            topBarTopConstraint.constant = Self.topBarHeight
                            UIView.animate(withDuration: 0.4) {
                                self.topBar.clearShadow()
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
                
                topBar.contentView.alpha = topBarTopConstraint.constant / Self.topBarHeight
                topBar.dropShadow(opacity: 0.2 * Float(1 - topBarTopConstraint.constant / Self.topBarHeight), radius: 20)
                scrollState.prevScrollOffset = scrollView.contentOffset.y
            }
        }
        
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            withTagToCategory(tag: scrollView.tag) { section in
                presenter.scrollDidReachBounds(in: section)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollState.scrollingDirection = .none
        scrollState.prevScrollOffset = scrollView.contentOffset.y
        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
        scrollState.lockScroll = true
        if topBarTopConstraint.constant > Self.topBarHeight/2 {
            topBarTopConstraint.constant = Self.topBarHeight//0
            
            topBar.clearShadow()
            topBar.contentView.alpha = 1
        } else {
            topBarTopConstraint.constant = 0//-Self.topBarHeight
            topBar.contentView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.topBar.dropShadow(opacity: 0.2, radius: 20)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollState.lockScroll = false
        scrollState.prevScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Decide to continue showing or hiding bar
        scrollState.scrollingDirection = .none
        scrollState.prevScrollOffset = scrollView.contentOffset.y
        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
        scrollState.lockScroll = false
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
