import UIKit
import ComponentKit

class TweetCell: BaseSelectableThemeCell {
    private static let bodyFont: UIFont = .subhead2

    private let stackView = UIStackView()

    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let titleImage = UIImageView()

    private let textView = MarkdownTextView()
    private let attachmentView = TweetAttachmentView()
    private let referencedTweetView = ReferencedTweetView()

    private let dateLabel = UILabel()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(CGFloat.margin16)
        }

        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = .margin12

        let headerView = UIView()
        stackView.addArrangedSubview(headerView)

        headerView.addSubview(titleImage)
        titleImage.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.height.width.equalTo(CGFloat.iconSize24)
        }

        titleImage.cornerRadius = 12

        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.leading.equalTo(titleImage.snp.trailing).offset(CGFloat.margin8)
            maker.trailing.equalToSuperview()
        }

        titleLabel.font = .body
        titleLabel.textColor = .themeOz

        headerView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(3)
            maker.leading.equalTo(titleLabel.snp.leading)
            maker.bottom.equalToSuperview()
        }

        subTitleLabel.font = .caption
        subTitleLabel.textColor = .themeGray

        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(attachmentView)
        stackView.addArrangedSubview(referencedTweetView)

        stackView.addArrangedSubview(dateLabel)
        dateLabel.font = .micro
        dateLabel.textColor = .themeGray50
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(viewItem: CoinTweetsViewModel.ViewItem) {
        titleImage.af.cancelImageRequest()
        if let url = URL(string: viewItem.titleImageUrl) {
            titleImage.af.setImage(withURL: url)
        }

        titleLabel.text = viewItem.title
        subTitleLabel.text = viewItem.subTitle

        let attributedString = NSMutableAttributedString(string: viewItem.text, attributes: [
            .foregroundColor: UIColor.themeLeah,
            .font: Self.bodyFont
        ])
        
        for entity in TwitterText.entities(in: viewItem.text) {
            switch entity.type {
                case .url, .hashtag, .screenName, .listname: attributedString.addAttribute(.foregroundColor, value: UIColor.themeIssykBlue, range: entity.range)
            default: ()
            }
        }

        textView.attributedText = attributedString

        if let attachment = viewItem.attachment {
            attachmentView.bind(attachment: attachment)
            attachmentView.isHidden = false
        } else {
            attachmentView.isHidden = true
        }

        if let referencedTweet = viewItem.referencedTweet {
            referencedTweetView.bind(tweet: referencedTweet)
            referencedTweetView.isHidden = false
        } else {
            referencedTweetView.isHidden = true
        }

        dateLabel.text = viewItem.date
    }

    static func height(viewItem: CoinTweetsViewModel.ViewItem, containerWidth: CGFloat) -> CGFloat {
        let textWidth: CGFloat = containerWidth - .margin16 * 4
        let textHeight = viewItem.text.height(forContainerWidth: textWidth, font: bodyFont)
        var height: CGFloat = .margin16 + 37 + .margin12 + textHeight + .margin12 + 12 + .margin16

        if let attachment = viewItem.attachment {
            height += .margin12 + TweetAttachmentView.height(attachment: attachment, containerWidth: textWidth)
        }

        if let referencedTweet = viewItem.referencedTweet {
            height += .margin12 + ReferencedTweetView.height(tweet: referencedTweet, containerWidth: textWidth)
        }

        return height
    }

}