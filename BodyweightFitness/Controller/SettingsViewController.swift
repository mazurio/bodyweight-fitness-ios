import UIKit
import StoreKit

class SettingsToggleCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SettingsActionCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SettingsActionSubtitleCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SettingsTextCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension UIViewController {
    func registerNib(tableView: UITableView, nibName: String) {
        tableView.registerNib(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKStoreProductViewControllerDelegate {
    @IBOutlet var tableView: UITableView!
    
    init() {
        super.init(nibName: "SettingsView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setNavigationBar()
        
        self.registerNib(self.tableView, nibName: "SettingsSectionCell")
        self.registerNib(self.tableView, nibName: "SettingsToggleCell")
        self.registerNib(self.tableView, nibName: "SettingsActionCell")
        self.registerNib(self.tableView, nibName: "SettingsActionSubtitleCell")
        self.registerNib(self.tableView, nibName: "SettingsTextCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.title = "Settings"
    }

    func playAudioWhenTimerStops(sender: UISwitch) {
        if sender.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "playAudioWhenTimerStops")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "playAudioWhenTimerStops")
        }
    }

    func openStoreProductWithiTunesItemIdentifier(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self

        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProductWithParameters(parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self?.presentViewController(storeViewController, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 4) {
            return 2
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General"
        case 1:
            return "Weight Measurement"
        case 2:
            return "Developed by"
        case 3:
            return "Credits"
        case 4:
            return "About"
        case 5:
            return "Version"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Any music playing in the background will automatically resume."
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsToggleCell", forIndexPath: indexPath) as! SettingsToggleCell
            let toggle = UISwitch()
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Play Audio"
                cell.detailTextLabel?.text = "Play audio when timer stops"
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if (defaults.objectForKey("playAudioWhenTimerStops") != nil) {
                    toggle.on = defaults.boolForKey("playAudioWhenTimerStops")
                }
                
                toggle.addTarget(self, action: #selector(playAudioWhenTimerStops), forControlEvents: UIControlEvents.ValueChanged)
            }
            
            cell.accessoryView = toggle
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
            
            if PersistenceManager.getWeightUnit() == "lbs" {
                cell.textLabel?.text = "Pounds (lbs)"
            } else {
                cell.textLabel?.text = "Kilograms (kg)"
            }
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionSubtitleCell", forIndexPath: indexPath) as UITableViewCell!
            
            cell.textLabel?.text = "Damian Mazurkiewicz"
            cell.detailTextLabel?.text = "github.com/mazurio"
            
            return cell
        }

        if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionSubtitleCell", forIndexPath: indexPath) as UITableViewCell!

                cell.textLabel?.text = "Ruben Dantuma"
                cell.detailTextLabel?.text = "Logo Design"

                return cell
            }
        }
        
        if indexPath.section == 4 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
                
                cell.textLabel?.text = "Rate the app in iTunes Store"
                
                return cell
            }

            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!

                cell.textLabel?.text = "Frequently Asked Questions"

                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsTextCell", forIndexPath: indexPath) as UITableViewCell!
        
        if let anyObject = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] {
            if let version: String = anyObject as? String {
                cell.textLabel?.text = "Bodyweight Fitness"
                cell.detailTextLabel?.text = version
            }
        } else {
            cell.textLabel?.text = "Bodyweight Fitness"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
            
            if PersistenceManager.getWeightUnit() == "lbs" {
                cell.textLabel?.text = "Pounds (lbs)"
            } else {
                cell.textLabel?.text = "Kilograms (kg)"
            }
            
            let alertController = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .ActionSheet)
            
            alertController.modalPresentationStyle = .Popover
            
            if let presenter = alertController.popoverPresentationController {
                presenter.sourceView = cell;
                presenter.sourceRect = cell.bounds;
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Kilograms (kg)", style: .Default) { (action) in
                PersistenceManager.setWeightUnit("kg")
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            alertController.addAction(UIAlertAction(title: "Pounds (lbs)", style: .Default) { (action) in
                PersistenceManager.setWeightUnit("lbs")
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }

        if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let requestUrl = NSURL(string: "https://www.github.com/mazurio") {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }

        if indexPath.section == 3 {
            if indexPath.row == 0 {
                if let requestUrl = NSURL(string: "http://dantuma.co.za") {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }

                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }

        if indexPath.section == 4 {
            if indexPath.row == 0 {
                self.openStoreProductWithiTunesItemIdentifier("1018863605")
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }

            if indexPath.row == 1 {
                if let requestUrl = NSURL(string: "http://www.reddit.com/r/bodyweightfitness/wiki/faq") {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }

                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
