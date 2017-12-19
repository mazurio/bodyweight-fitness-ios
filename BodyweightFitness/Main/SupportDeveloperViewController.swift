import UIKit
import StoreKit
import Crashlytics

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        
        return formatter.string(from: self.price)!
    }
    
    func currency() -> String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        
        return formatter.internationalCurrencySymbol
    }
}

class SupportDeveloperViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var restorePurchasesButton: UIButton!
    
    var product: SKProduct?
    var productID = "bodyweight.fitness.gold"
    
    override func viewDidLoad() {
        self.setNavigationBar()
        
        SKPaymentQueue.default().add(self)
        
        self.getProductInfo()
    }
    
    func getProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let set = NSSet(objects: self.productID) as! Set<String>
            let request = SKProductsRequest(productIdentifiers: set)
            
            request.delegate = self
            request.start()
        } else {
            self.showAlert()
            
            self.buyButton.isEnabled = false
            self.restorePurchasesButton.isHidden = true
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var products = response.products
        
        if (products.count != 0) {
            product = products[0]

            if let product = product {
                buyButton.setTitle("Buy \(product.localizedPrice())", for: UIControlState())
            }
            
            self.buyButton.isEnabled = true
            self.restorePurchasesButton.isHidden = false
        } else {
            self.buyButton.isEnabled = false
            self.restorePurchasesButton.isHidden = true
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.purchased()
                
                if let product = product {
                    Answers.logPurchase(
                        withPrice: product.price,
                        currency: product.currency(),
                        success: true,
                        itemName: "Bodyweight Fitness Gold",
                        itemType: "IAP",
                        itemId: "bodyweight.fitness.gold",
                        customAttributes: nil)
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                self.purchased()
                
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func purchased() {
        self.buyButton.setTitle("Purchased, thank you!", for: UIControlState())
        self.buyButton.isEnabled = false
        
        self.restorePurchasesButton.isHidden = true
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "IAP Disabled",
            message: "Please enable In App Purchases in Settings",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buyProduct(_ sender: AnyObject) {
        if let product = product {
            let payment = SKPayment(product: product)
            
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @IBAction func restorePurchases(_ sender: AnyObject) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            self.showAlert()
        }
    }
}
