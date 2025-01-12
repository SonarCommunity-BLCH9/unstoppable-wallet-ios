import UIKit
import CoinKit
import EthereumKit
import SectionsTableView
import ThemeKit

protocol ISwapSettingsDataSource: AnyObject {
    func viewDidLoad()
    func buildSections() -> [SectionProtocol]

    var onOpen: ((UIViewController) -> ())? { get set }
    var onClose: (() -> ())? { get set }
    var onReload: (() -> ())? { get set }
}

class SwapSettingsModule {

    static func viewController(dataSourceManager: ISwapDataSourceManager, dexManager: ISwapDexManager) -> UIViewController? {
        let viewModel = SwapSettingsViewModel(dexManager: dexManager)
        let viewController = SwapSettingsViewController(
                viewModel: viewModel,
                dataSourceManager: dataSourceManager
        )

        return ThemeNavigationController(rootViewController: viewController)
    }

}

extension SwapSettingsModule {

    enum AddressError: Error {
        case invalidAddress
    }

    enum SlippageError: Error {
        case zeroValue
        case tooLow(min: Decimal)
        case tooHigh(max: Decimal)
    }

    enum DeadlineError: Error {
        case zeroValue
    }

}