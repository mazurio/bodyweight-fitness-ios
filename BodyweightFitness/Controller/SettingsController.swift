import UIKit

class SettingsController: UITableViewController {
    @IBOutlet var playAudioWhenTimerStops: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.objectForKey("playAudioWhenTimerStops") != nil) {
            self.playAudioWhenTimerStops.on = defaults.boolForKey("playAudioWhenTimerStops")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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