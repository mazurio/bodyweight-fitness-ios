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
            (sideNavigationController?.rootViewController as? UINavigationController)?.viewControllers[0] as? TimerController {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier) as UITableViewCell!
        
        cell.backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        cell.contentView.backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        return cell
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
                
                if(sideNavigationController?.rootViewController == (appDelegate?.mainViewController)!) {
                    break;
                }
                
                sideNavigationController?.transitionFromRootViewController(
                    (appDelegate?.mainViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            case 1:
                // Workout Log
                
                if(sideNavigationController?.rootViewController == (appDelegate?.calendarViewController)!) {
                    break;
                }
                
                sideNavigationController?.transitionFromRootViewController(
                    (appDelegate?.calendarViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            case 2:
                // Support Developer
                
                if(sideNavigationController?.rootViewController == (appDelegate?.supportViewController)!) {
                    break;
                }
                
                sideNavigationController?.transitionFromRootViewController(
                    (appDelegate?.supportViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            case 3:
                // Settings
                
                if(sideNavigationController?.rootViewController == (appDelegate?.settingsViewController)!) {
                    break;
                }
                
                sideNavigationController?.transitionFromRootViewController(
                    (appDelegate?.settingsViewController)!,
                    duration: 0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: nil,
                    completion: nil)
                
                break;
                
            default:
                break;
        }
        
        sideNavigationController?.toggleLeftView()
    }
}