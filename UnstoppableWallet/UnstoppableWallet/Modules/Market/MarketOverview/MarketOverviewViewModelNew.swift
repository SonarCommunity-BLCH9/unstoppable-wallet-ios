import RxSwift
import RxRelay
import RxCocoa
import CurrencyKit
import MarketKit

class MarketOverviewViewModelNew {
    private let service: MarketOverviewServiceNew
    private let disposeBag = DisposeBag()

    private let viewItemsRelay = BehaviorRelay<[ViewItem]?>(value: nil)
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<String?>(value: nil)

    init(service: MarketOverviewServiceNew) {
        self.service = service

        subscribe(disposeBag, service.stateObservable) { [weak self] in self?.sync(state: $0) }

        sync(state: service.state)
    }

    private func sync(state: MarketOverviewServiceNew.State) {
        switch state {
        case .loading:
            viewItemsRelay.accept(nil)
            loadingRelay.accept(true)
            errorRelay.accept(nil)
        case .loaded(let items):
            viewItemsRelay.accept(items.map { viewItem(item: $0) })
            loadingRelay.accept(false)
            errorRelay.accept(nil)
        case .failed:
            viewItemsRelay.accept(nil)
            loadingRelay.accept(false)
            errorRelay.accept("market.sync_error".localized)
        }
    }

    private func viewItem(item: MarketOverviewServiceNew.Item) -> ViewItem {
        ViewItem(
                listType: item.listType,
                imageName: imageName(listType: item.listType),
                title: title(listType: item.listType),
                listViewItems: item.marketInfos.map { listViewItem(marketInfo: $0) }
        )
    }

    private func listViewItem(marketInfo: MarketInfo) -> MarketModule.ListViewItem {
        MarketModule.ListViewItem(marketInfo: marketInfo, marketField: .price, currency: service.currency)
    }

    private func imageName(listType: MarketOverviewServiceNew.ListType) -> String {
        switch listType {
        case .topGainers: return "circle_up_20"
        case .topLosers: return "circle_down_20"
        }
    }

    private func title(listType: MarketOverviewServiceNew.ListType) -> String {
        switch listType {
        case .topGainers: return "market.top.section.header.top_gainers".localized
        case .topLosers: return "market.top.section.header.top_losers".localized

        }
    }

}

extension MarketOverviewViewModelNew {

    var viewItemsDriver: Driver<[ViewItem]?> {
        viewItemsRelay.asDriver()
    }

    var loadingDriver: Driver<Bool> {
        loadingRelay.asDriver()
    }

    var errorDriver: Driver<String?> {
        errorRelay.asDriver()
    }

    var marketTops: [String] {
        MarketModule.MarketTop.allCases.map { $0.title }
    }

    func marketTop(listType: MarketOverviewServiceNew.ListType) -> MarketModule.MarketTop {
        service.marketTop(listType: listType)
    }

    func marketTopIndex(listType: MarketOverviewServiceNew.ListType) -> Int {
        let marketTop = service.marketTop(listType: listType)
        return MarketModule.MarketTop.allCases.firstIndex(of: marketTop) ?? 0
    }

    func onSelect(marketTopIndex: Int, listType: MarketOverviewServiceNew.ListType) {
        let marketTop = MarketModule.MarketTop.allCases[marketTopIndex]
        service.set(marketTop: marketTop, listType: listType)
    }

    func refresh() {
        service.refresh()
    }

}

extension MarketOverviewViewModelNew {

    struct ViewItem {
        let listType: MarketOverviewServiceNew.ListType
        let imageName: String
        let title: String
        let listViewItems: [MarketModule.ListViewItem]
    }

}