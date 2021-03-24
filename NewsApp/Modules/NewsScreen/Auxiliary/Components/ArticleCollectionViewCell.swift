//
//  ArticleCollectionViewCell.swift
//  NewsApp
//
//  Created by Ilya Yelagov on 3/24/21.
//

import UIKit

struct ArticleModel {
    var source: NewsSource?
    var author: String?
    var title: String
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
    
    init(with article: Article) {
        self.title = article.title ?? "no_title".localizedCapitalized
        self.source = article.source
        self.author = article.author
        self.description = article.description
        self.url = article.url
        self.urlToImage = article.urlToImage
        if let publishedAt = article.publishedAt, let date = DateFormatter().date(from: publishedAt) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, YYYY"
            self.publishedAt = formatter.string(from: date)
        }
        self.content = article.content
    }
}

class ArticleCollectionViewCell: UICollectionViewCell {
    let titleLabel: UILabel = .init()
    let descriptionLabel: UILabel = .init()
    let sourceLabel: UILabel = .init()
    let authorLabel: UILabel = .init()
    let timeLabel: UILabel = .init()
    let imageView: UIImageView = .init()
    
    let verticalStackView: UIStackView = .init()
    
    var tapAction: (() -> Void)?
    private let id = UUID().hashValue
    
    private var articleModel: ArticleModel?
    func configure(with articleModel: ArticleModel) {
        if self.articleModel?.url != articleModel.url {
            Current.api.subscriptions.cancelAndRelease(from: self)
        }
        self.articleModel = articleModel
        verticalStackView.removeAllArrangedSubviews()
        
        if let sourceName = articleModel.source?.name {
            sourceLabel.text = sourceName
            verticalStackView.addArrangedSubview(sourceLabel)
        }
        if let time = articleModel.publishedAt {
            timeLabel.text = time
            verticalStackView.addArrangedSubview(timeLabel)
        }
        titleLabel.text = articleModel.title
        verticalStackView.addArrangedSubview(titleLabel)
        
        verticalStackView.addArrangedSubview(imageView)
        imageView.image = nil
        if let urlToImage = articleModel.urlToImage {
            imageView.backgroundColor = .lightGray
            //Keep downloading image after deinit for caching
            _ = Current.image.getImage(urlToImage) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if urlToImage == self.articleModel?.urlToImage {
                        UIView.transition(with: self.imageView, duration: 0.2, options: .transitionCrossDissolve) {
                            self.imageView.backgroundColor = .clear
                            self.imageView.image = image ?? .remove
                        }
                    }
                }
            }
        } else {
            self.imageView.backgroundColor = .clear
            self.imageView.image = .strokedCheckmark
        }
        
        verticalStackView.arrangedSubviews.forEach({
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor, multiplier: 1.0).isActive = true
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: $0.intrinsicContentSize.height).isActive = true
        })
        //verticalStackView.backgroundColor = .blue
        //titleLabel.backgroundColor = .red
        
        //titleLabel.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
            return contentView.systemLayoutSizeFitting(CGSize(width: self.bounds.size.width, height: 1))
        }
    
    private func buildHierarchy() {
        contentView.addSubview(verticalStackView)
    }
    
    private func configureSubviews() {
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .equalSpacing
        verticalStackView.alignment = .leading
        verticalStackView.spacing = 4
        imageView.contentMode = .scaleAspectFill
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        verticalStackView.clipsToBounds = false
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        timeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
    }
    
    private func setupLayout() {
        let verticalMargin: CGFloat = 12
        let horizontalMargin: CGFloat = 8
        contentView.fillLayout(with: verticalStackView, insets: .init(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin))
    }
    
    private func setup() {
        buildHierarchy()
        configureSubviews()
        setupLayout()
        
        self.backgroundColor = .white
        contentView.clipsToBounds = true
        self.dropShadow(opacity: 0.2, offSet: .zero, radius: 4)
    }
    
    override init(frame: CGRect = .init()) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleCollectionViewCell: SubscriberObject {
    var subscriptionId: Int {
        id
    }
    
    
}
