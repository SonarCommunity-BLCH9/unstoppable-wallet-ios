import Foundation
import CurrencyKit
import MarketKit

class CoinOverviewViewItemFactory {
    private let coinFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private func roundedFormat(coinCode: String, value: Decimal?) -> String? {
        guard let value = value, !value.isZero, let formattedValue = coinFormatter.string(from: value as NSNumber) else {
            return nil
        }

        return "\(formattedValue) \(coinCode)"
    }

    private func roiTitle(timePeriod: TimePeriod) -> String {
        switch timePeriod {
        case .all: return "n/a".localized
        case .hour1: return "coin_page.roi.hour1".localized
        case .dayStart: return "n/a".localized
        case .hour24: return "coin_page.roi.hour24".localized
        case .day7: return "coin_page.roi.day7".localized
        case .day14: return "coin_page.roi.day14".localized
        case .day30: return "coin_page.roi.day30".localized
        case .day200: return "coin_page.roi.day200".localized
        case .year1: return "coin_page.roi.year1".localized
        }
    }

    private func performanceViewItems(info: MarketInfoOverview) -> [[CoinOverviewViewModel.PerformanceViewItem]] {
        var viewItems = [[CoinOverviewViewModel.PerformanceViewItem]]()

        var titleRow = [CoinOverviewViewModel.PerformanceViewItem]()
        titleRow.append(.title("coin_page.return_of_investments".localized))

        var timePeriods = [TimePeriod]()
        for row in info.performance {
            for (timePeriod, _) in row.changes {
                if !timePeriods.contains(timePeriod) {
                    timePeriods.append(timePeriod)
                }
            }
        }

        timePeriods.sort()
        timePeriods.forEach { titleRow.append(.subtitle(roiTitle(timePeriod: $0))) }

        viewItems.append(titleRow)

        info.performance.forEach { performanceRow in
            var row = [CoinOverviewViewModel.PerformanceViewItem]()
            row.append(.content("vs \(performanceRow.base.rawValue.uppercased())"))

            timePeriods.forEach { timePeriod in
                row.append(.value(performanceRow.changes[timePeriod]))
            }
            viewItems.append(row)
        }

        return viewItems
    }

    private func categories(info: MarketInfoOverview) -> [String]? {
        let categories = info.categories
        return categories.isEmpty ? nil : categories.map { $0.name }
    }

    private func contractViewItems(fullCoin: FullCoin) -> [CoinOverviewViewModel.ContractViewItem]? {
        let contracts: [CoinOverviewViewModel.ContractViewItem] = fullCoin.platforms.compactMap { platform in
            switch platform.coinType {
            case .erc20(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "ethereum_24", reference: address, explorerUrl: "https://etherscan.io/token/\(address)")
            case .bep20(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "binance_smart_chain_24", reference: address, explorerUrl: "https://bscscan.com/token/\(address)")
            case .bep2(let symbol): return CoinOverviewViewModel.ContractViewItem(iconName: "binance_chain_24", reference: symbol, explorerUrl: "https://explorer.binance.org/asset/\(symbol)")
            case .arbitrumOne(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .avalanche(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .fantom(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .harmonyShard0(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .huobiToken(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .iotex(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .moonriver(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .okexChain(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .polygonPos(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .solana(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .sora(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .tomochain(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            case .xdai(let address): return CoinOverviewViewModel.ContractViewItem(iconName: "", reference: address, explorerUrl: "")
            default: return nil
            }
        }

        return contracts.isEmpty ? nil : contracts
    }

    private func linkTitle(type: LinkType, url: String) -> String {
        switch type {
        case .website:
            if let url = URL(string: url), let host = url.host {
                return host.stripping(prefix: "www.")
            } else {
                return "coin_page.website".localized
            }
        case .whitepaper: return "coin_page.whitepaper".localized
        case .reddit: return "Reddit"
        case .twitter: return url.stripping(prefix: "https://twitter.com/")
        case .telegram: return "Telegram"
        case .github: return "Github"
        default: return ""
        }
    }

    private func linkIconName(type: LinkType) -> String {
        switch type {
        case .website: return "globe_20"
        case .whitepaper: return "clipboard_20"
        case .reddit: return "reddit_20"
        case .twitter: return "twitter_20"
        case .telegram: return "telegram_20"
        case .github: return "github_20"
        default: return ""
        }
    }

    private func linkUrl(type: LinkType, url: String) -> String {
        switch type {
        case .website, .whitepaper, .reddit, .github: return url
        case .twitter:
            if url.hasPrefix("https://") {
                return url
            } else {
                return "https://twitter.com/\(url)"
            }
        case .telegram:
            if url.hasPrefix("https://") {
                return url
            } else {
                return "https://t.me/\(url)"
            }

        default: return ""
        }
    }

    private func links(info: MarketInfoOverview) -> [CoinOverviewViewModel.LinkViewItem] {
        let linkMap = info.links
        let linkTypes: [LinkType] = [.website, .whitepaper, .reddit, .twitter, .telegram, .github]

        return linkTypes.compactMap { linkType in
            guard let url = linkMap[linkType], !url.isEmpty else {
                return nil
            }

            return CoinOverviewViewModel.LinkViewItem(
                    title: linkTitle(type: linkType, url: url),
                    iconName: linkIconName(type: linkType),
                    url: linkUrl(type: linkType, url: url)
            )
        }
    }

}

extension CoinOverviewViewItemFactory {

    func viewItem(item: CoinOverviewService.Item, currency: Currency, fullCoin: FullCoin) -> CoinOverviewViewModel.ViewItem {
        let info = item.info
        let coinCode = fullCoin.coin.code

        return CoinOverviewViewModel.ViewItem(
                marketCapRank: info.marketCapRank.map { "#\($0)" },
                marketCap: info.marketCap.flatMap { CurrencyCompactFormatter.instance.format(currency: currency, value: $0) },
                totalSupply: roundedFormat(coinCode: coinCode, value: info.totalSupply),
                circulatingSupply: roundedFormat(coinCode: coinCode, value: info.circulatingSupply),
                volume24h: info.volume24h.flatMap { CurrencyCompactFormatter.instance.format(currency: currency, value: $0) },
                dilutedMarketCap: info.dilutedMarketCap.flatMap { CurrencyCompactFormatter.instance.format(currency: currency, value: $0) },
                tvl: info.tvl.flatMap { CurrencyCompactFormatter.instance.format(currency: currency, value: $0) },
                genesisDate: info.genesisDate.map { DateHelper.instance.formatFullDateOnly(from: $0) },

                performance: performanceViewItems(info: info),
                categories: categories(info: info),
                contracts: contractViewItems(fullCoin: fullCoin),
                description: info.description,
                guideUrl: item.guideUrl,
                links: links(info: info)
        )
    }

}
