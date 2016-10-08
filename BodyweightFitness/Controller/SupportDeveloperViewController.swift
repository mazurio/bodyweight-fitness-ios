import UIKit
import StoreKit
import Crashlytics

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NSNumberFormatter()
        
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = self.priceLocale
        
        return formatter.stringFromNumber(self.price)!
    }
    
    func currency() -> String {
        let formatter = NSNumberFormatter()
        
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = self.priceLocale
        
        return formatter.internationalCurrencySymbol
    }
}

class SupportDeveloperViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var restorePurchasesButton: UIButton!
    
    var product: SKProduct?
    var productID = "bodyweight.fitness.gold"
    
    init() {
        super.init(nibName: "SupportDeveloperView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setNavigationBar()
        
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.title = "Support Developer"
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
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
            
            self.buyButton.enabled = false
            self.restorePurchasesButton.hidden = true
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        var products = response.products
        
        if (products.count != 0) {
            product = products[0]

            if let product = product {
                buyButton.setTitle("Buy \(product.localizedPrice())", forState: .Normal)
            }
            
            self.buyButton.enabled = true
            self.restorePurchasesButton.hidden = false
        } else {
            self.buyButton.enabled = false
            self.restorePurchasesButton.hidden = true
        }
    }

    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                self.purchased()
                
                if let product = product {
                    Answers.logPurchaseWithPrice(
                        product.price,
                        currency: product.currency(),
                        success: true,
                        itemName: "Bodyweight Fitness Gold",
                        itemType: "IAP",
                        itemId: "bodyweight.fitness.gold",
                        customAttributes: nil)
                }
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case .Restored:
                self.purchased()
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case .Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func purchased() {
        self.buyButton.setTitle("Purchased, thank you!", forState: .Normal)
        self.buyButton.enabled = false
        
        self.restorePurchasesButton.hidden = true
    }
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "IAP Disabled",
            message: "Please enable In App Purchases in Settings",
            preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buyProduct(sender: AnyObject) {
        if let product = product {
            let payment = SKPayment(product: product)
            
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }
    
    @IBAction func restorePurchases(sender: AnyObject) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        } else {
            self.showAlert()
        }
    }
}
