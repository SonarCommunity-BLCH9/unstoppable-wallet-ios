import UIKit
import SnapKit

class ChartDoubleLineView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(titleColor: UIColor = .themeOz, titleFont: UIFont = .captionSB, subtitleColor: UIColor = .themeGray, subtitleFont: UIFont = .caption, textAlignment: NSTextAlignment = .left) {
        super.init(frame: .zero)

        addSubview(titleLabel)
        addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalToSuperview().inset(CGFloat.margin4)
        }
        subtitleLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(titleLabel.snp.bottom).offset(6)
        }

        titleLabel.textColor = titleColor
        titleLabel.font = titleFont
        titleLabel.textAlignment = textAlignment
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.font = subtitleFont
        subtitleLabel.textAlignment = textAlignment
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    func bind(title: String?, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

}
