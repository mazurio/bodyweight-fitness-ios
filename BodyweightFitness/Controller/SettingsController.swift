import UIKit

class SettingsController: UITableViewController {
    @IBOutlet var playAudioWhenTimerStops: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("playAudioWhenTimerStops") != nil) {
            self.playAudioWhenTimerStops.on = defaults.boolForKey("playAudioWhenTimerStops")
        }
    }
    
    @IBAction func onClickNavigationItem(sender: AnyObject) {
        self.sideNavigationViewController?.toggle()
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