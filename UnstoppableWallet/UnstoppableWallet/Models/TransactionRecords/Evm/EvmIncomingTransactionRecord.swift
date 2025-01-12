import Foundation
import EthereumKit
import CoinKit

class EvmIncomingTransactionRecord: EvmTransactionRecord {
    let from: String
    let value: CoinValue

    init(fullTransaction: FullTransaction, baseCoin: Coin, amount: Decimal, from: String, token: Coin, foreignTransaction: Bool = false) {
        self.from = from
        value = CoinValue(coin: token, value: amount)

        super.init(fullTransaction: fullTransaction, baseCoin: baseCoin, foreignTransaction: foreignTransaction)
    }

    override var mainValue: CoinValue? {
        value
    }

}
