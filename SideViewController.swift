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
    
    let categoryCellIdentifier = "CategoryCell"
    let sectionCellIdentifier = "SectionCell"
    let exerciseCellIdentifier = "ExerciseCell"
    
    var showMenu = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func notifyDataSetChanged() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        });
    }
    
    func onClickHeader() {
        showMenu = !showMenu
        notifyDataSetChanged()
    }
    
    func timerController() -> TimerController? {
        if let timerController =
            (sideNavigationViewController?.mainViewController as? UINavigationController)?.viewControllers[0] as? TimerController {
                return timerController
        } else {
            return nil
        }
    }
    
    //
    // Return number of sections in the view. This is the sum of categories
    // and sections.
    //
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (showMenu) {
            return 1
        }
        
        return RoutineStream.sharedInstance.routine.categoriesAndSections.count + 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 150
        }
        
        return 45
    }
    
    //
    // Return different view for different sections.
    //
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier) as UITableViewCell!
            
            let gestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onClickHeader")
            gestureRecognizer.delegate = self
            gestureRecognizer.numberOfTapsRequired = 1
            gestureRecognizer.numberOfTouchesRequired = 1
            
            headerCell?.addGestureRecognizer(gestureRecognizer)
            
            return headerCell
        }
        
        let routinePart = RoutineStream.sharedInstance.routine.categoriesAndSections[section - 1] as! LinkedRoutine
        
        switch(routinePart.getType()) {
        case RoutineType.Category:
            let cell = tableView.dequeueReusableCellWithIdentifier(categoryCellIdentifier) as UITableViewCell!
            let category = routinePart as! Category
            
            cell.textLabel?.text = category.title
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(sectionCellIdentifier) as UITableViewCell!
            let section = routinePart as! Section
            
            cell.textLabel?.text = section.title
            cell.detailTextLabel?.text = section.desc
            
            return cell
        }
    }
    
    //
    // Allows to set number of rows in each section.
    // We set category section to have no rows.
    // Each section have number of exercises.
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if (showMenu) {
                return 4
            }
            
            return 0
        }
        
        let linkedRoutine = RoutineStream.sharedInstance.routine.categoriesAndSections[section - 1] as! LinkedRoutine
        let type = linkedRoutine.getType()
        
        switch(type) {
        case RoutineType.Category:
            return 0
            
        default:
            let section = linkedRoutine as! Section
            
            if(section.mode == SectionMode.All) {
                return section.exercises.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (showMenu) {
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
        
        // Recycling of cells
        let cell = tableView.dequeueReusableCellWithIdentifier(exerciseCellIdentifier, forIndexPath: indexPath) as UITableViewCell!
        
        // todo: we should use (if let option) to avoid crashes
        let currentSection = RoutineStream.sharedInstance.routine.categoriesAndSections[indexPath.section - 1] as! Section
        
        if currentSection.getType() == RoutineType.Section {
            let currentExercise = currentSection.exercises[indexPath.row] as! Exercise
            
            if(currentSection.mode == SectionMode.All) {
                cell.textLabel?.text = currentExercise.level
                cell.detailTextLabel?.text = currentExercise.title
            } else {
                cell.textLabel?.text = currentSection.currentExercise?.level
                cell.detailTextLabel?.text = currentSection.currentExercise?.title
            }
        }
        
        return cell
    }
    
    //
    // Delegate implementation
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (showMenu) {
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
        } else {
            let currentSection = RoutineStream.sharedInstance.routine.categoriesAndSections[indexPath.section - 1] as! Section
            if currentSection.getType() == RoutineType.Section {
                let currentExercise = currentSection.exercises[indexPath.row] as! Exercise
                
                if(currentSection.mode == SectionMode.All) {
                    self.timerController()?.changeExercise(currentExercise)
                } else {
                    self.timerController()?.changeExercise(currentSection.currentExercise!)
                }
            }
        }
        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        
        sideNavigationViewController?.toggle()
    }
}