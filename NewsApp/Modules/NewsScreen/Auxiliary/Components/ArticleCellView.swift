//
//  ArticleCellView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/26/21.
//

import Foundation
import UIKit

class ArticleCellView: UIView, SubscriberObject {
    let id = UUID().hashValue
    var subscriptionId: Int { id }
    
    var articleModel: ArticleModel?
    
    var toggleExpanded: (() -> Void)?
    var isExpanded: Bool = false {
        didSet {
            onExpandToggle()
        }
    }
    
    var expandButtonAdded: Bool { expandButton != nil }
    
    //MARK: - Subviews
    var previewImageView: UIImageView = .init()
    var sourceLabel: UILabel = .init()
    var titleLabel: UILabel = .init()
    var timeLabel: UILabel = .init()
    var descriptionLabel: UILabel = .init(frame: .zero)
    
    var labelsStackView = UIStackView()
    var headerStackView = UIStackView()
    
    var expandButton: UIButton?
    
    //MARK: - Handlers
    @objc func expandButtonTapped(_ sender: UIButton) {
        isExpanded.toggle()
        descriptionLabel.layoutIfNeeded()
        
        toggleExpanded?()
    }
    
    @objc func descriptionTapped(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: descriptionLabel)
        if (isExpanded || descriptionLabel.isTruncated) && true || location.y > descriptionLabel.bounds.height - descriptionLabel.font.lineHeight {
            isExpanded.toggle()
            
            descriptionLabel.layoutIfNeeded()
            toggleExpanded?()
        }
    }
    
    //MARK: - Methods
    
    func onExpandToggle() {
        expandButton?.setAttributedTitle(.init(string: isExpanded ? "Collapse" : "Expand", attributes: [.foregroundColor: UILabel.LabelStyle.expandButton.textColor, .font: UILabel.LabelStyle.expandButton.font]), for: .normal)
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
    }
    
    private func addExpandButton() {
        if !expandButtonAdded {
            
            let expandButton = UIButton()
            self.expandButton = expandButton
            //expandButton.isUserInteractionEnabled = true
            expandButton.addTarget(self, action: #selector(expandButtonTapped(_:)), for: .touchUpInside)
            expandButton.contentHorizontalAlignment = .leading
            //expandButton.titleLabel?.font = LabelStyle.expandButton.font
            /*let descriptionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(descriptionTapped(_:)))
            descriptionTapGestureRecognizer.cancelsTouchesInView = true
            expandButton.addGestureRecognizer(descriptionTapGestureRecognizer)*/
            //expandButton.font = .systemFont(ofSize: 14, weight: .semibold)
            //expandButton.textColor = .blue
            expandButton.setContentCompressionResistancePriority(.required, for: .vertical)
            onExpandToggle()
            
            if let index = labelsStackView.arrangedSubviews.firstIndex(of: descriptionLabel) {
                labelsStackView.insertArrangedSubview(expandButton, at: index + 1)
            }
           // labelsStackView.layoutIfNeeded()
        }
    }
    
    private func hideExpandButton() {
        if let expandButton = self.expandButton {
            labelsStackView.removeArrangedSubview(expandButton)
            expandButton.removeFromSuperview()
            self.expandButton = nil
        }
    }
    
    override func isBeingPresented() {
        super.isBeingPresented()
        
        checkAddButton()
    }
    
    func checkAddButton() {
        if self.descriptionLabel.isTruncated {
            addExpandButton()
        } else if !isExpanded {
            hideExpandButton()
        }
    }
    
    
    func configure(with articleCellModel: ArticlePresentationModel) {
        let articleModel = articleCellModel.model
        if self.articleModel?.url != articleModel.url {
            Current.api.subscriptions.cancelAndRelease(from: self)
        } else {
            return
        }
        
        self.articleModel = articleModel
        
        hideExpandButton()
    
        labelsStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        labelsStackView.addArrangedSubview(headerStackView)
        var arrangedSubviews = [UIView]()
        if let sourceName = articleModel.source?.name {
            sourceLabel.text = sourceName
            headerStackView.addArrangedSubview(sourceLabel)
        }
        if let time = articleModel.publishedAt {
            timeLabel.text = time
            headerStackView.addArrangedSubview(timeLabel)
        }
        titleLabel.text = articleModel.title
        arrangedSubviews.append(titleLabel)
        
        if let description = articleModel.description {
            descriptionLabel.text = description
            arrangedSubviews.append(descriptionLabel)
        }
        
        titleLabel.numberOfLines = 3
        isExpanded = articleCellModel.isExpanded
        previewImageView.image = nil
        previewImageView.clipsToBounds = true
        
        if let urlToImage = articleModel.urlToImage {
            previewImageView.backgroundColor = .lightGray
            
            //Keep downloading image after deinit for caching
            _ = Current.image.getImage(urlToImage) { [weak self] image in
                guard let self = self,
                      let imageData = image?.jpegData(compressionQuality: 0.0) else { return }
                let image = UIImage.init(data: imageData)
                DispatchQueue.main.async {
                    if urlToImage == self.articleModel?.urlToImage {
                        UIView.transition(with: self.previewImageView, duration: 0.2, options: .transitionCrossDissolve) {
                            self.previewImageView.backgroundColor = .clear
                            self.previewImageView.image = image ?? .remove
                            self.previewImageView.setNeedsDisplay()
                        }
                    }
                }
            }
        } else {
            self.previewImageView.backgroundColor = .clear
            self.previewImageView.image = .strokedCheckmark
        }
        
        arrangedSubviews.forEach {
            labelsStackView.addArrangedSubview($0)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        //Requesting layoutSubvies after presentation
        setNeedsLayout()
    }
    
    private func buildHierarchy() {
        addSubview(labelsStackView)
        addSubview(previewImageView)
    }
    
    private func configureSubviews() {
        labelsStackView.axis = .vertical
        
        labelsStackView.distribution = .fillProportionally
        labelsStackView.spacing = 2
        
        headerStackView.axis = .horizontal
        headerStackView.distribution = .equalSpacing
        
        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 3
        descriptionLabel.applyStyle(.articleDescription)
        titleLabel.applyStyle(.articleTitle)
        timeLabel.applyStyle(.articleTime)
        
        previewImageView.layer.cornerRadius = 8
    }
    
    private func setupLayout() {
        let horizontalInset: CGFloat = 12
        
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            previewImageView.widthAnchor.constraint(equalTo: previewImageView.heightAnchor, multiplier: 1.0),
            previewImageView.heightAnchor.constraint(equalToConstant: 100),
            previewImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ]
        + [
            labelsStackView.rightAnchor.constraint(equalTo: previewImageView.leftAnchor, constant: -horizontalInset),
            labelsStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ]
        + previewImageView.attach(to: self, right: 0, top: 0, activated: false)
        + self.attach(to: labelsStackView, left: 0, top: 0, activated: false)
        
        constraints.forEach( { $0.priority = .required })
        
        NSLayoutConstraint.activate(constraints)
        
        labelsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        previewImageView.contentMode = .scaleAspectFill
    }
    
    private func setup() {
        buildHierarchy()
        configureSubviews()
        setupLayout()
    }
    
    deinit {
        Current.api.subscriptions.cancelAndRelease(from: self)
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
