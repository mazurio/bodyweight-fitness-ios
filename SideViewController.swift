import UIKit

class HeaderCell: UITableViewCell {
    @IBOutlet weak var arrowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var tableView: UITableView!
    
    var appDelegate: AppDelegate?
    
    var headerCell: UITableViewCell?
    
    let menuCellIdentifier = "MenuCell"
    let headerCellIdentifier = "HeaderCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func timerController() -> TimerController? {
        if let timerController =
            (sideNavigationViewController?.mainViewController as? UINavigationController)?.viewControllers[0] as? TimerController {
                return timerController
        } else {
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 150
        }
        
        return 45
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier) as UITableViewCell!
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(menuCellIdentifier, forIndexPath: indexPath) as UITableViewCell!
        
        switch(indexPath.row) {
        case 0:
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            
            cell.textLabel?.text = "Home"
            break;
            
        case 1:
            cell.textLabel?.text = "Workout Log"
            break;
            
        case 2:
            cell.textLabel?.text = "Support Developer"
            break;
            
        case 3:
            cell.textLabel?.text = "Settings"
            break;
            
        default:
            break;
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.row) {
            case 0:
                // Home
                
                if(sideNavigationViewController?.mainViewController == (appDelegate?.mainViewController)!) {
                    break;
                }
                
                sideNavigationViewController?.transitionFromMainViewController(
                    (appDelegate?.mainViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            case 1:
                // Workout Log
                
                if(sideNavigationViewController?.mainViewController == (appDelegate?.calendarViewController)!) {
                    break;
                }
                
                sideNavigationViewController?.transitionFromMainViewController(
                    (appDelegate?.calendarViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            case 2:
                // Support Developer
                
                if(sideNavigationViewController?.mainViewController == (appDelegate?.supportViewController)!) {
                    break;
                }
                
                sideNavigationViewController?.transitionFromMainViewController(
                    (appDelegate?.supportViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            case 3:
                // Settings
                
                if(sideNavigationViewController?.mainViewController == (appDelegate?.settingsViewController)!) {
                    break;
                }
                
                sideNavigationViewController?.transitionFromMainViewController(
                    (appDelegate?.settingsViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            default:
                break;
        }
        
        sideNavigationViewController?.toggle()
    }
}