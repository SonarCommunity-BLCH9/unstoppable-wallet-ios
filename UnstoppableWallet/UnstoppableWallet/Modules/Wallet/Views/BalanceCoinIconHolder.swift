import UIKit
import ThemeKit
import HUD
import ComponentKit

class BalanceCoinIconHolder: UIView {
    private let coinIconImageView = UIImageView()
    private let syncSpinner = HUDProgressView(
            progress: 0,
            strokeLineWidth: 2,
            radius: 15,
            strokeColor: .themeGray,
            duration: 2
    )
    private let failedButton = ThemeButton()

    private var onTapError: (() -> ())?

    init() {
        super.init(frame: .zero)

        addSubview(coinIconImageView)
        coinIconImageView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin16)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGFloat.iconSize24)
        }

        addSubview(syncSpinner)
        syncSpinner.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        addSubview(failedButton)
        failedButton.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        failedButton.setImageTintColor(.themeLucian, for: .normal)
        failedButton.setImage(UIImage(named: "warning_2_24"), for: .normal)
        failedButton.addTarget(self, action: #selector(onTapErrorButton), for: .touchUpInside)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    @objc private func onTapErrorButton() {
        onTapError?()
    }

    func bind(coinIcon: UIImage?, spinnerProgress: Int?, indefiniteSearchCircle: Bool, failViewVisible: Bool, onTapError: (() -> ())?) {
        self.onTapError = onTapError

        coinIconImageView.image = coinIcon
        coinIconImageView.isHidden = coinIcon == nil

        if let spinnerProgress = spinnerProgress {
            syncSpinner.set(progress: Float(spinnerProgress) / 100)
            syncSpinner.set(strokeColor: .themeGray)
            syncSpinner.isHidden = false
            syncSpinner.startAnimating()
        } else if indefiniteSearchCircle {
            syncSpinner.set(strokeColor: .themeGray50)
            syncSpinner.set(progress: 0.1)
            syncSpinner.isHidden = false
            syncSpinner.startAnimating()
        } else {
            syncSpinner.isHidden = true
            syncSpinner.stopAnimating()
        }

        failedButton.isHidden = !failViewVisible
    }

}
