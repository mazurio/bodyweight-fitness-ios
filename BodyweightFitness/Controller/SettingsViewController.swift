import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet var playAudioWhenTimerStops: UISwitch!
    
    init() {
        super.init(nibName: "SettingsView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setNavigationBar()
        
        let menuItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss))
        
        menuItem.tintColor = UIColor.primaryDark()
        
        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.title = "Settings"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("playAudioWhenTimerStops") != nil) {
            self.playAudioWhenTimerStops.on = defaults.boolForKey("playAudioWhenTimerStops")
        }
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
    
    @IBAction func playAudioWhenTimerStopsChanged(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if self.playAudioWhenTimerStops.on {
            defaults.setBool(true, forKey: "playAudioWhenTimerStops")
        } else {
            defaults.setBool(false, forKey: "playAudioWhenTimerStops")
        }
    }
}