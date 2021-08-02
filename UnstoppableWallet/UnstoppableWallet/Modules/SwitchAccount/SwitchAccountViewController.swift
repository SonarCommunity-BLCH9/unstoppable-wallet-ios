import UIKit
import ThemeKit
import SectionsTableView
import SnapKit
import RxSwift
import RxCocoa
import ComponentKit

class SwitchAccountViewController: ThemeActionSheetController {
    private let viewModel: SwitchAccountViewModel
    private let disposeBag = DisposeBag()

    private let titleView = BottomSheetTitleView()
    private let tableView = SelfSizedSectionsTableView(style: .grouped)

    init(viewModel: SwitchAccountViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(titleView)
        titleView.snp.makeConstraints { maker in
            maker.leading.top.trailing.equalToSuperview()
        }

        titleView.bind(
                title: "Switch Wallet",
                subtitle: "Select wallet for quick switch",
                image: UIImage(named: "switch_wallet_24"),
                tintColor: .themeGray
        )
        titleView.onTapClose = { [weak self] in
            self?.dismiss(animated: true)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(titleView.snp.bottom)
            maker.bottom.equalToSuperview().inset(CGFloat.margin16)
        }

        tableView.registerCell(forClass: G4Cell.self)
        tableView.sectionDataSource = self

        tableView.buildSections()

        subscribe(disposeBag, viewModel.finishSignal) { [weak self] in self?.dismiss(animated: true) }
    }

}

extension SwitchAccountViewController: SectionsDataSource {

    func buildSections() -> [SectionProtocol] {
        [
            Section(
                    id: "main",
                    rows: viewModel.viewItems.enumerated().map { index, viewItem in
                        let isFirst = index == 0
                        let isLast = index == viewModel.viewItems.count - 1

                        return Row<G4Cell>(
                                id: "item_\(index)",
                                height: .heightDoubleLineCell,
                                bind: { cell, _ in
                                    cell.set(backgroundStyle: .transparent, isFirst: isFirst, isLast: isLast)
                                    cell.titleImage = viewItem.selected ? UIImage(named: "circle_radioon_24")?.tinted(with: .themeJacob) : UIImage(named: "circle_radiooff_24")
                                    cell.title = viewItem.title
                                    cell.subtitle = viewItem.subtitle
                                },
                                action: { [weak self] _ in
                                    self?.viewModel.onSelect(accountId: viewItem.accountId)
                                }
                        )
                    }
            )
        ]
    }

}