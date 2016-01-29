import Foundation
import StoreKit

class SupportDeveloperViewController: UIViewController, SKProductsRequestDelegate {
    let productIdentifiers = Set([
        "com.bodyweight.fitness.donation", "com.bodyweight.fitness.gold"
    ])
    
    var donationProduct: SKProduct?
    var subscribeProduct: SKProduct?
    
    var productsArray = Array<SKProduct>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestProductData()
    }
    
    @IBAction func onClickDonation(sender: AnyObject) {
        if let product = donationProduct {
            let payment = SKPayment(product: product)
            
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }
    
    @IBAction func onClickSubscribe(sender: AnyObject) {
        if let product = subscribeProduct {
            let payment = SKPayment(product: product)
            
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }
    
    @IBAction func onClickRestore(sender: AnyObject) {
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func requestProductData() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            print("Cannot make payments, enable in settings!!!!")
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products = response.products

        if (products.count != 0) {
            for product in products {
                if(product.localizedTitle == "Donation") {
                    donationProduct = product
                } else {
                    subscribeProduct = product
                }
                
                print(product.price)
                print(product.localizedTitle)
                print(product.localizedDescription)
                
                productsArray.append(product)
            }
        } else {
            print("No products found")
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as! [SKPaymentTransaction] {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                
                self.deliverProduct(transaction)
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed")
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("Transactions Restored")
        
        for transaction:SKPaymentTransaction in queue.transactions {
            deliverProduct(transaction)
        }
        
        print("restored!")
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        if transaction.payment.productIdentifier == "com.bodyweight.fitness.donation" {
            print("Donation!!!! Thanks!!!!")
        } else if transaction.payment.productIdentifier == "com.bodyweight.fitness.gold" {
            print("Gold purchased!!!!!!!")
        }
    }
}