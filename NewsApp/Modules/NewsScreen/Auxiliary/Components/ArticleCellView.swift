//
//  ArticleCellView.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/26/21.
//

import Foundation
import UIKit

class RefreshableStackView: UIStackView {
    override var bounds: CGRect {
        didSet {
            self.arrangedSubviews.forEach({
                ($0 as? UILabel)?.preferredMaxLayoutWidth = self.bounds.width
                $0.bounds.size.width = self.bounds.size.width
                ($0 as? UILabel)?.invalidateIntrinsicContentSize()
            })
            print(bounds)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class ArticleCellView: UIView, SubscriberObject {
    let id = UUID().hashValue
    var subscriptionId: Int { id }
    
    var articleModel: ArticleModel?
    //MARK: - Subviews
    var previewImageView: UIImageView = .init()
    var sourceLabel: UILabel = .init()
    var titleLabel: UILabel = .init()
    var timeLabel: UILabel = .init()
    var descriptionLabel: UILabel = .init(frame: .zero)
    
    var labelsStackView = RefreshableStackView()
    
    var toggleExpanded: (() -> Void)?
    var isExpanded: Bool = false {
        didSet {
            onExpandToggle()
        }
    }
    var expandButton: UIButton?
    
    var expandButtonAdded: Bool { expandButton != nil }
    
    func onExpandToggle() {
        expandButton?.setTitle(isExpanded ? "Collapse" : "Expand", for: .normal)
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
    }
    
    override var bounds: CGRect {
        didSet {
            if self.descriptionLabel.isTruncated {
                if (articleModel?.title.contains("Apple wants Tim")) ?? false {
                    print(descriptionLabel.frame)
                }
                addExpandButton()
            } else if !isExpanded {
                if (articleModel?.title.contains("Apple wants Tim")) ?? false {
                    print(descriptionLabel.frame)
                }
                if (articleModel?.title.contains("Apple launches")) ?? false {
                    print(descriptionLabel.frame)
                }
                hideExpandButton()
            } else {
                if (articleModel?.title.contains("Apple launches")) ?? false {
                    print(descriptionLabel.frame)
                }
                print(self.descriptionLabel.frame)
            }
            labelsStackView.arrangedSubviews.forEach {
                $0.sizeToFit()
                $0.layoutIfNeeded()
            }
            /*self.sourceLabel.sizeToFit()
            self.titleLabel.sizeToFit()
            self.descriptionLabel.sizeToFit()
            self.expandButton?.sizeToFit()
            self.descriptionLabel.layoutSubviews()
            self.descriptionLabel.layoutIfNeeded()*/
            labelsStackView.layoutIfNeeded()
            labelsStackView.layoutSubviews()
        }
    }
    
    func addExpandButton() {
        if !expandButtonAdded {
            
            let expandButton = UIButton()
            self.expandButton = expandButton
            expandButton.backgroundColor = .red
            //expandButton.isUserInteractionEnabled = true
            
            let descriptionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(descriptionTapped(_:)))
            descriptionTapGestureRecognizer.cancelsTouchesInView = true
            expandButton.addGestureRecognizer(descriptionTapGestureRecognizer)
            //expandButton.font = .systemFont(ofSize: 14, weight: .semibold)
            //expandButton.textColor = .blue
            expandButton.setContentCompressionResistancePriority(.required, for: .vertical)
            onExpandToggle()
            
            if let index = labelsStackView.arrangedSubviews.firstIndex(of: descriptionLabel) {
                labelsStackView.insertArrangedSubview(expandButton, at: index + 1)
            }
            labelsStackView.layoutIfNeeded()
        }
    }
    
    func hideExpandButton() {
        if (articleModel?.title.contains("Apple launches")) ?? false {
            print(descriptionLabel.frame)
        }
        if let expandButton = self.expandButton {
            labelsStackView.removeArrangedSubview(expandButton)
            expandButton.removeFromSuperview()
            self.expandButton = nil
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        if (articleModel?.title.contains("Apple launches")) ?? false {
            print(descriptionLabel.frame)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //descriptionLabel.sizeToFit()
        //sourceLabel.sizeToFit()
        if (articleModel?.title.contains("Apple launches")) ?? false {
            print(descriptionLabel.frame)
        }
        //descriptionLabel.invalidateIntrinsicContentSize()
        //descriptionLabel.frame.size.width = self.labelsStackView.bounds.width
        //descriptionLabel.invalidateIntrinsicContentSize()
        /*titleLabel.frame.size.width = self.labelsStackView.bounds.width
        descriptionLabel.frame.size.width = self.labelsStackView.bounds.width
        descriptionLabel.invalidateIntrinsicContentSize()
        descriptionLabel.frame.size.height = descriptionLabel.intrinsicContentSize.height*/
        //descriptionLabel.frame.size.height = descriptionLabel.intrinsicContentSize.height + 5
        if self.descriptionLabel.isTruncated {
            if (articleModel?.title.contains("Apple wants Tim")) ?? false {
                print(descriptionLabel.frame)
            }
            addExpandButton()
        } else if !isExpanded {
            if (articleModel?.title.contains("Apple wants Tim")) ?? false {
                print(descriptionLabel.frame)
            }
            if (articleModel?.title.contains("Apple launches")) ?? false {
                print(descriptionLabel.frame)
            }
            hideExpandButton()
        } else {
            if (articleModel?.title.contains("Apple launches")) ?? false {
                print(descriptionLabel.frame)
            }
            print(self.descriptionLabel.frame)
        }
        labelsStackView.arrangedSubviews.forEach {
            $0.sizeToFit()
            $0.layoutIfNeeded()
        }
        labelsStackView.layoutIfNeeded()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    @objc func descriptionTapped(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: descriptionLabel)
        if (isExpanded || descriptionLabel.isTruncated) && true || location.y > descriptionLabel.bounds.height - descriptionLabel.font.lineHeight {
            isExpanded.toggle()
            
            descriptionLabel.layoutIfNeeded()
            toggleExpanded?()
            //descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabel.intrinsicContentSize.height).isActive = true
        }
    }
    
    func configure(with articleCellModel: ArticleCellModel) {
        let articleModel = articleCellModel.model
        if self.articleModel?.url != articleModel.url {
            //isExpanded = false
            Current.api.subscriptions.cancelAndRelease(from: self)
        } else {
            return
        }
        self.articleModel = articleModel
        
        hideExpandButton()
    
        labelsStackView.arrangedSubviews.forEach {
            //labelsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        /*let emptyLabel = UILabel()
        emptyLabel.text = "____"
        emptyLabel.textColor = .clear
        labelsStackView.addArrangedSubview(emptyLabel)*/
        //labelsStackView.removeAllArrangedSubviews()
        //contentView.subviews.forEach({ $0.removeAllConstraints(); $0.removeFromSuperview() })
        //verticalStackView.removeAllArrangedSubviews()
        //sourceLabel.frame.size.height = 1000
        //descriptionLabel.frame.size.height = 1000
        //titleLabel.frame.size.height = 1000
        var arrangedSubviews = [UIView]()
        if let sourceName = articleModel.source?.name {
            sourceLabel.text = sourceName
            sourceLabel.textColor = .black
            //verticalStackView.addArrangedSubview(sourceLabel)
            arrangedSubviews.append(sourceLabel)
        }
        if let time = articleModel.publishedAt {
            timeLabel.text = time
            arrangedSubviews.append(timeLabel)
            //verticalStackView.addArrangedSubview(timeLabel)
        }
        //titleLabel.preferredMaxLayoutWidth = labelsStackView.bounds.width
        titleLabel.text = articleModel.title
        arrangedSubviews.append(titleLabel)
        
        if let description = articleModel.description {
            descriptionLabel.text = description
            arrangedSubviews.append(descriptionLabel)
            //verticalStackView.addArrangedSubview(timeLabel)
        }
        
        //verticalStackView.addArrangedSubview(titleLabel)
        //imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        
        titleLabel.numberOfLines = 3
        //titleLabel.setContentHuggingPriority(.required, for: .vertical)
        isExpanded = articleCellModel.isExpanded
        previewImageView.image = nil
        previewImageView.clipsToBounds = true
        //verticalStackView.addArrangedSubview(imageView)
        if let urlToImage = articleModel.urlToImage {
            previewImageView.backgroundColor = .lightGray
            //Keep downloading image after deinit for caching
            _ = Current.image.getImage(urlToImage) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if urlToImage == self.articleModel?.urlToImage {
                        //UIView.transition(with: self.previewImageView, duration: 0.2, options: .transitionCrossDissolve) {
                            self.previewImageView.backgroundColor = .clear
                            self.previewImageView.image = image ?? .remove
                       // }
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
        //layoutSubviews()
        /*labelsStackView.setNeedsUpdateConstraints()
        labelsStackView.setNeedsLayout()
        setNeedsUpdateConstraints()
        setNeedsLayout()*/
        //layoutSubviews()
        /*var prevAnchor = contentView.topAnchor
        var constraints = [NSLayoutConstraint]()
        for arrangedSubview in arrangedSubviews {
            contentView.addSubview(arrangedSubview)
            
            arrangedSubview.translatesAutoresizingMaskIntoConstraints = false
            if arrangedSubview === self.imageView {
                constraints += arrangedSubview.attach(to: contentView, left: 0, right: 0, activated: false)
            } else {
                //arrangedSubview.setContentHuggingPriority(.required, for: .vertical)
                constraints += arrangedSubview.attach(to: contentView, left: 8, right: 8, activated: false)
                //arrangedSubview.heightAnchor.constraint(equalToConstant: max(arrangedSubview.intrinsicContentSize.height, 0)).isActive = true
            }
            let topConstraint = arrangedSubview.topAnchor.constraint(equalTo: prevAnchor, constant: 4)
            topConstraint.priority = .defaultHigh
            constraints += [topConstraint]
            
            prevAnchor = arrangedSubview.bottomAnchor
        }
        (arrangedSubviews.last?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)).flatMap({ constraints += [$0] })
        
        let imageViewConstraint = previewImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8)
        constraints += [imageViewConstraint]
        NSLayoutConstraint.activate(constraints)*/
    }
    
    private func buildHierarchy() {
        addSubview(labelsStackView)
        addSubview(previewImageView)
        labelsStackView.addArrangedSubview(sourceLabel)
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func configureSubviews() {
        labelsStackView.axis = .vertical
        
        labelsStackView.alignment = .leading
        labelsStackView.distribution = .fillProportionally
        labelsStackView.spacing = 2
        
        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 3
        descriptionLabel.applyStyle(.articleDescription)
        titleLabel.applyStyle(.articleTitle)
    }
    
    private func setupLayout() {
        //contentView.fillLayout(with: stackView)
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        /*stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])*/
        //labelsStackView.setContentHuggingPriority(.required, for: .vertical)
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
        constraints.forEach( { $0.priority = .init(1000) })
        NSLayoutConstraint.activate(
            constraints
        )
        
        [
        labelsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ].forEach({ $0.isActive = true })
        previewImageView.contentMode = .scaleAspectFill
        //labelsStackView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setup() {
        buildHierarchy()
        configureSubviews()
        setupLayout()
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
