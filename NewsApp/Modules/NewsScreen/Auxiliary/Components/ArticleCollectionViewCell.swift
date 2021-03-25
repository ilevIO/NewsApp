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
    
    let showMoreButton = UIButton()
    
    var tapAction: (() -> Void)?
    private let id = UUID().hashValue
    
    private var articleModel: ArticleModel?
    
    func checkLines() {
        if descriptionLabel.requiredNumberOfLines() > descriptionLabel.numberOfLines {
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let arrangedSubviews = contentView.subviews
        for arrangedSubview in arrangedSubviews {
            //arrangedSubview.frame.size.height = arrangedSubview.intrinsicContentSize.height
            arrangedSubview.heightAnchor.constraint(greaterThanOrEqualToConstant: arrangedSubview.intrinsicContentSize.height).isActive = true
        }
    }
    
    func configure(with articleModel: ArticleModel) {
        if self.articleModel?.url != articleModel.url {
            Current.api.subscriptions.cancelAndRelease(from: self)
        }
        
        self.articleModel = articleModel
        contentView.subviews.forEach({ $0.removeAllConstraints(); $0.removeFromSuperview() })
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
        titleLabel.text = articleModel.title
        arrangedSubviews.append(titleLabel)
        //verticalStackView.addArrangedSubview(titleLabel)
        //imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        imageView.image = nil
        imageView.clipsToBounds = true
        //verticalStackView.addArrangedSubview(imageView)
        arrangedSubviews.append(imageView)
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
        
        var prevAnchor = contentView.topAnchor
        for arrangedSubview in arrangedSubviews {
            contentView.addSubview(arrangedSubview)
            arrangedSubview.setContentHuggingPriority(.required, for: .vertical)
            arrangedSubview.translatesAutoresizingMaskIntoConstraints = false
            if arrangedSubview === self.imageView {
                arrangedSubview.attach(to: contentView, left: 0, right: 0)
            } else {
                arrangedSubview.attach(to: contentView, left: 8, right: 8)
            }
            arrangedSubview.topAnchor.constraint(equalTo: prevAnchor, constant: 4).isActive = true
            arrangedSubview.heightAnchor.constraint(greaterThanOrEqualToConstant: arrangedSubview.intrinsicContentSize.height).isActive = true
            prevAnchor = arrangedSubview.bottomAnchor
        }
        arrangedSubviews.last?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8).isActive = true
        
        /*verticalStackView.arrangedSubviews.forEach({
            //$0.translatesAutoresizingMaskIntoConstraints = false
            //$0.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor, multiplier: 1.0).isActive = true
            if !($0 is UIImageView) {
                //$0.setContentHuggingPriority(.defaultHigh, for: .vertical)
                //$0.frame.size.height = $0.intrinsicContentSize.height
                $0.heightAnchor.constraint(greaterThanOrEqualToConstant: $0.intrinsicContentSize.height).isActive = true
            }
        })*/
        
        
        /*descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        timeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true*/
        //self.widthAnchor.constraint(lessThanOrEqualToConstant: 180).isActive = true
        //verticalStackView.backgroundColor = .blue
        //titleLabel.backgroundColor = .red
        
        //titleLabel.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor, multiplier: 1.0).isActive = true
    }
    
    /*override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return contentView.systemLayoutSizeFitting(CGSize(width: self.bounds.size.width, height: 1))
    }*/
    
    private func buildHierarchy() {
        contentView.addSubview(verticalStackView)
    }
    
    private func configureSubviews() {
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .equalSpacing
       // verticalStackView.alignment = .top
        verticalStackView.spacing = 4
        //verticalStackView.alignment = .fill
        
        imageView.contentMode = .scaleAspectFill
        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 3
        verticalStackView.clipsToBounds = false
        //imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        /*descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        timeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true*/
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
