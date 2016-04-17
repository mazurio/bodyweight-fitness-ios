import UIKit

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

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
        
        let menuItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss))
        
        menuItem.tintColor = UIColor.primaryDark()
        
        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.title = "Settings"
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
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
    
    func automaticallyLogTimedExercises(sender: UISwitch) {
        if sender.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "automaticallyLogTimedExercises")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "automaticallyLogTimedExercises")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        } else if (section == 3) {
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
            return "About"
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
            } else {
                cell.textLabel?.text = "Automatic Logging"
                cell.detailTextLabel?.text = "Automatically log timed exercises"
                
                let defaults = NSUserDefaults.standardUserDefaults()
                if (defaults.objectForKey("automaticallyLogTimedExercises") != nil) {
                    toggle.on = defaults.boolForKey("automaticallyLogTimedExercises")
                }
                
                toggle.addTarget(self, action: #selector(automaticallyLogTimedExercises), forControlEvents: UIControlEvents.ValueChanged)
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
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsActionCell", forIndexPath: indexPath) as UITableViewCell!
                
                cell.textLabel?.text = "Rate the app in iTunes Store"
                
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
                if let requestUrl = NSURL(string: "https://www.github.com/mazurio") {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }
                
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}