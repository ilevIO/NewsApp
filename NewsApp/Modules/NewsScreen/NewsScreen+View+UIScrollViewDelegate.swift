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
        guard scrollView !== mainCollectionView else {
            //To prevent 
            scrollView.contentOffset.y = 0
            return
        }
        if !scrollState.lockScroll && _viewDidAppear && false {
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
                        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset//contentOffset
                        prevTopBarVisibleHeight = //Self.topBarHeight +
                            topBarTopConstraint.constant
                        scrollState.scrollingDirection = -1
                    }
                    if abs(contentOffset - scrollState.currentDirectionBeginScrollOffset) > deltaToShowBar || contentOffset <= 0 {
                        if contentOffset <= 1 {
                            topBarTopConstraint.constant = Self.topBarHeight//0
                            UIView.animate(withDuration: 0.4) {
                                self.topBar.clearShadow()
                                //self.view.layoutIfNeeded()
                                //self.view.setNeedsDisplay()
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
                //
                //(scrollView as? UICollectionView)?.collectionViewLayout.invalidateLayout()
                //mainCollectionView.layoutIfNeeded()
                topBar.contentView.alpha = topBarTopConstraint.constant / Self.topBarHeight
                topBar.dropShadow(opacity: 0.2 * Float(1 - topBarTopConstraint.constant / Self.topBarHeight), radius: 20)
                scrollState.prevScrollOffset = scrollView.contentOffset.y
            }
        }
        
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            withTagToSection(tag: scrollView.tag) { section in
                presenter.scrollDidReachBounds(in: section)
            }
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollState.scrollingDirection = 0
        scrollState.prevScrollOffset = scrollView.contentOffset.y
        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
        scrollState.lockScroll = true
        if topBarTopConstraint.constant > Self.topBarHeight/2 {
            topBarTopConstraint.constant = Self.topBarHeight//0
            
            topBar.clearShadow()
            topBar.contentView.alpha = 1
            UIView.animate(withDuration: 0.3) {
                //self.view.layoutIfNeeded()
                //self.view.setNeedsDisplay()
            }
        } else {
            topBarTopConstraint.constant = 0//-Self.topBarHeight
            topBar.contentView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.topBar.dropShadow(opacity: 0.2, radius: 20)
                //self.view.layoutIfNeeded()
                //self.view.setNeedsDisplay()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollState.lockScroll = false
        scrollState.prevScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //Decide to continue showing or hiding bar
        scrollState.scrollingDirection = 0
        scrollState.prevScrollOffset = scrollView.contentOffset.y
        scrollState.currentDirectionBeginScrollOffset = scrollState.prevScrollOffset
        scrollState.lockScroll = false
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
