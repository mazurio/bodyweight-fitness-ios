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

    func showRestTimer(sender: UISwitch) {
        if sender.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "showRestTimer")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "showRestTimer")
        }
        
        self.tableView.reloadData()
    }
    
    func showRestTimerAfterWarmup(sender: UISwitch) {
        if sender.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "showRestTimerAfterWarmup")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "showRestTimerAfterWarmup")
        }
    }
    
    func showRestTimerAfterBodylineDrills(sender: UISwitch) {
        if sender.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "showRestTimerAfterBodylineDrills")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "showRestTimerAfterBodylineDrills")
        }
    }
    
    func showRestTimerAfterFlexibilityExercises(sender: UISwitch) {
        if sender.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "showRestTimerAfterFlexibilityExercises")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "showRestTimerAfterFlexibilityExercises")
        }
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
        return 7
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) {
            return 5
        }
        if (section == 5) {
            return 2
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General"
        case 1:
            return "Rest Timer"
        case 2:
            return "Weight Measurement"
        case 3:
            return "Developed by"
        case 4:
            return "Credits"
        case 5:
            return "About"
        case 6:
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
    
    func restTimerEnabled() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("showRestTimer")
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
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsToggleCell", forIndexPath: indexPath) as! SettingsToggleCell
                let toggle = UISwitch()
                
                cell.textLabel?.text = "Show rest timer"
                cell.detailTextLabel?.text = "Shows rest timer after logging any exercise"
                    
                let defaults = NSUserDefaults.standardUserDefaults()
                if (defaults.objectForKey("showRestTimer") != nil) {
                    toggle.on = defaults.boolForKey("showRestTimer")
                }
                
                toggle.addTarget(self, action: #selector(showRestTimer), forControlEvents: UIControlEvents.ValueChanged)
                
                cell.accessoryView = toggle
                
                return cell
            }
            
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
                
                cell.textLabel?.text = "Default Rest Time"
                
                if (!restTimerEnabled()) {
                    cell.userInteractionEnabled = false
                    cell.contentView.alpha = 0.5
                } else {
                    cell.userInteractionEnabled = true
                    cell.contentView.alpha = 1.0
                }
                
                return cell
            }
            
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsToggleCell", forIndexPath: indexPath) as! SettingsToggleCell
                let toggle = UISwitch()
                
                cell.textLabel?.text = "Show rest timer after Warmup"
                cell.detailTextLabel?.text = "Bodyweight Fitness - Warmup"
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if (defaults.objectForKey("showRestTimerAfterWarmup") != nil) {
                    toggle.on = defaults.boolForKey("showRestTimerAfterWarmup")
                }
                
                toggle.addTarget(self, action: #selector(showRestTimerAfterWarmup), forControlEvents: UIControlEvents.ValueChanged)
                
                cell.accessoryView = toggle
                
                if (!restTimerEnabled()) {
                    cell.userInteractionEnabled = false
                    cell.contentView.alpha = 0.5
                } else {
                    cell.userInteractionEnabled = true
                    cell.contentView.alpha = 1.0
                }
                
                return cell
            }
            
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsToggleCell", forIndexPath: indexPath) as! SettingsToggleCell
                let toggle = UISwitch()
                
                cell.textLabel?.text = "Show rest timer after Bodyline Drills"
                cell.detailTextLabel?.text = "Bodyweight Fitness - Bodyline Drills"
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if (defaults.objectForKey("showRestTimerAfterBodylineDrills") != nil) {
                    toggle.on = defaults.boolForKey("showRestTimerAfterBodylineDrills")
                }
                
                toggle.addTarget(self, action: #selector(showRestTimerAfterBodylineDrills), forControlEvents: UIControlEvents.ValueChanged)
                
                cell.accessoryView = toggle
                
                if (!restTimerEnabled()) {
                    cell.userInteractionEnabled = false
                    cell.contentView.alpha = 0.5
                } else {
                    cell.userInteractionEnabled = true
                    cell.contentView.alpha = 1.0
                }
                
                return cell
            }
            
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsToggleCell", forIndexPath: indexPath) as! SettingsToggleCell
                let toggle = UISwitch()
                
                cell.textLabel?.text = "Show rest timer after Flexibility Exercises"
                cell.detailTextLabel?.text = "Starting Stretching and Molding Mobility"
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if (defaults.objectForKey("showRestTimerAfterFlexibilityExercises") != nil) {
                    toggle.on = defaults.boolForKey("showRestTimerAfterFlexibilityExercises")
                }
                
                toggle.addTarget(self, action: #selector(showRestTimerAfterFlexibilityExercises), forControlEvents: UIControlEvents.ValueChanged)
                
                cell.accessoryView = toggle
                
                if (!restTimerEnabled()) {
                    cell.userInteractionEnabled = false
                    cell.contentView.alpha = 0.5
                } else {
                    cell.userInteractionEnabled = true
                    cell.contentView.alpha = 1.0
                }
                
                return cell
            }
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
            
            if PersistenceManager.getWeightUnit() == "lbs" {
                cell.textLabel?.text = "Pounds (lbs)"
            } else {
                cell.textLabel?.text = "Kilograms (kg)"
            }
            
            return cell
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionSubtitleCell", forIndexPath: indexPath) as UITableViewCell!
            
            cell.textLabel?.text = "Damian Mazurkiewicz"
            cell.detailTextLabel?.text = "github.com/mazurio"
            
            return cell
        }

        if indexPath.section == 4 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionSubtitleCell", forIndexPath: indexPath) as UITableViewCell!

                cell.textLabel?.text = "Ruben Dantuma"
                cell.detailTextLabel?.text = "Logo Design"

                return cell
            }
        }
        
        if indexPath.section == 5 {
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
        if indexPath.section == 1 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
            
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
            
            alertController.addAction(UIAlertAction(title: "30 Seconds", style: .Default) { (action) in
                PersistenceManager.setRestTime(30)
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            
            alertController.addAction(UIAlertAction(title: "1 Minute", style: .Default) { (action) in
                PersistenceManager.setRestTime(60)
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            
            alertController.addAction(UIAlertAction(title: "1 Minute 30 Seconds", style: .Default) { (action) in
                PersistenceManager.setRestTime(90)
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            
            alertController.addAction(UIAlertAction(title: "2 Minutes", style: .Default) { (action) in
                PersistenceManager.setRestTime(120)
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            
            alertController.addAction(UIAlertAction(title: "2 Minutes 30 Seconds", style: .Default) { (action) in
                PersistenceManager.setRestTime(150)
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.reloadData()
            })
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
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

        if indexPath.section == 3 {
            if indexPath.row == 0 {
                if let requestUrl = NSURL(string: "https://www.github.com/mazurio") {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }

        if indexPath.section == 4 {
            if indexPath.row == 0 {
                if let requestUrl = NSURL(string: "http://dantuma.co.za") {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }

                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }

        if indexPath.section == 5 {
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
