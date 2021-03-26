//
//  ArticleTableViewCell.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/25/21.
//

import Foundation
import UIKit

class LabelWrapper: UIView {
    var label = UILabel()
    
    var text: String? {
        get {
            label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var numberOfLines: Int {
        get {
            label.numberOfLines
        }
        set {
            label.numberOfLines = newValue
        }
    }
    
    func setup() {
        self.fill(with: label)
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LabelStyle {
    var font: UIFont
    var textColor: UIColor = .black
}

extension LabelStyle {
    static let articleTitle: LabelStyle = .init(font: .systemFont(ofSize: 18, weight: .bold))
    static let articleDescription: LabelStyle = .init(
        font: .systemFont(ofSize: 12),
        textColor: .darkGray
    )
}

extension UILabel {
    func applyStyle(_ style: LabelStyle) {
        self.font = style.font
        self.textColor = style.textColor
    }
}

class ArticleTableViewCell: UITableViewCell, SubscriberObject {
    var subscriptionId: Int { id }
    
    let id = UUID().hashValue
    var articleModel: ArticleModel?
    //MARK: - Subviews
    var previewImageView: UIImageView = .init()
    var sourceLabel: UILabel = .init()
    var titleLabel: UILabel = .init()
    var timeLabel: UILabel = .init()
    var descriptionLabel: UILabel = .init(frame: .zero)
    
    var labelsStackView = UIStackView()
    
    var toggleExpanded: (() -> Void)?
    var isExpanded: Bool = false {
        didSet {
            onExpandToggle()
        }
    }
    var expandButton: UILabel?
    
    var expandButtonAdded: Bool { expandButton != nil }
    
    func onExpandToggle() {
        expandButton?.text = isExpanded ? "Collapse" : "Expand"
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
    }
    
    func addExpandButton() {
        if !expandButtonAdded {
            
            let expandButton = UILabel()
            self.expandButton = expandButton
            expandButton.isUserInteractionEnabled = true
            let descriptionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(descriptionTapped(_:)))
            descriptionTapGestureRecognizer.cancelsTouchesInView = true
            expandButton.addGestureRecognizer(descriptionTapGestureRecognizer)
            expandButton.font = .systemFont(ofSize: 14, weight: .semibold)
            expandButton.textColor = .blue
            
            onExpandToggle()
            
            if let index = labelsStackView.arrangedSubviews.firstIndex(of: descriptionLabel) {
                labelsStackView.insertArrangedSubview(expandButton, at: index + 1)
            }
            labelsStackView.layoutIfNeeded()
        }
    }
    
    func hideExpandButton() {
        if let expandButton = self.expandButton {
            labelsStackView.removeArrangedSubview(expandButton)
            expandButton.removeFromSuperview()
            self.expandButton = nil
            labelsStackView.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.descriptionLabel.isTruncated {
            addExpandButton()
            /*descriptionLabel.attributedTruncationToken = NSAttributedString(
                string: "... Show more",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.blue
                ]
            )*/
            /*let appendix = " " + "Show more"
            let string = attributedText.string
            let text = String(string[..<string.index(string.endIndex, offsetBy: -appendix.count)] + appendix)
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.setAttributes([.foregroundColor: UIColor.blue], range: .init(location: text.count - appendix.count, length: appendix.count))
            self.descriptionLabel.attributedText = attributedString*/
        } else if !isExpanded {
            hideExpandButton()
        }
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
            Current.api.subscriptions.cancelAndRelease(from: self)
        } else {
            return
        }
        
        hideExpandButton()
        
        self.articleModel = articleModel
        labelsStackView.arrangedSubviews.forEach {
            labelsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        //labelsStackView.removeAllArrangedSubviews()
        //contentView.subviews.forEach({ $0.removeAllConstraints(); $0.removeFromSuperview() })
        //verticalStackView.removeAllArrangedSubviews()
        var arrangedSubviews = [UIView]()
        if let sourceName = articleModel.source?.name {
            sourceLabel.text = sourceName
            //verticalStackView.addArrangedSubview(sourceLabel)
            arrangedSubviews.append(sourceLabel)
        }
        if let time = articleModel.publishedAt {
            timeLabel.text = time
            arrangedSubviews.append(timeLabel)
            //verticalStackView.addArrangedSubview(timeLabel)
        }
        
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
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
        titleLabel.adjustsFontSizeToFitWidth = true
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
        for arrangedSubview in arrangedSubviews {
            //arrangedSubview.setContentHuggingPriority(.required, for: .vertical)
            //arrangedSubview.heightAnchor.constraint(equalToConstant: max(arrangedSubview.intrinsicContentSize.height, 0)).isActive = true

        }
        arrangedSubviews.forEach { labelsStackView.addArrangedSubview($0) }
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
        contentView.addSubview(labelsStackView)
        contentView.addSubview(previewImageView)
    }
    
    private func configureSubviews() {
        labelsStackView.axis = .vertical
        
        labelsStackView.distribution = .fill
        //stackView.distribution = .fillProportionally
        
        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 3
        descriptionLabel.isUserInteractionEnabled = true
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
        NSLayoutConstraint.activate([
            previewImageView.widthAnchor.constraint(equalTo: previewImageView.heightAnchor, multiplier: 1.0),
            previewImageView.heightAnchor.constraint(equalToConstant: 100),
            previewImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            labelsStackView.rightAnchor.constraint(equalTo: previewImageView.leftAnchor, constant: -horizontalInset),
            labelsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ] + previewImageView.attach(to: contentView, right: 0, top: 0, activated: false) +
        labelsStackView.attach(to: contentView, left: 0, top: 0, activated: false)
        )
        
        previewImageView.contentMode = .scaleAspectFill
    }
    
    private func setup() {
        buildHierarchy()
        configureSubviews()
        setupLayout()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
