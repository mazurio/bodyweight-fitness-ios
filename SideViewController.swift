import UIKit

class SideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    let categoryCellIdentifier = "CategoryCell"
    let sectionCellIdentifier = "SectionCell"
    let exerciseCellIdentifier = "ExerciseCell"
    
    var routine: Routine = PersistenceManager.getRoutine()
    
    func scrollViewDidScroll(scrollView: UIScrollView, floatingView: UIView){
        var frame: CGRect = floatingView.frame
        
        frame.origin.y = scrollView.contentOffset.y
        floatingView.frame = frame;
        
        view.bringSubviewToFront(floatingView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header: HeaderViewController = HeaderViewController()
        header.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150)

        self.addChildViewController(header)
        self.view.addSubview(header.view)

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func notifyDataSetChanged(routine: Routine) {
        self.routine = routine
        
        tableView.reloadData()
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
        return routine.categoriesAndSections.count
    }
    
    //
    // Return different view for different sections.
    //
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let routinePart = routine.categoriesAndSections[section] as! LinkedRoutine
        
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
        // category == 0
        // section == number of exercises
        
        let routinePart = routine.categoriesAndSections[section] as! LinkedRoutine
        let type = routinePart.getType()
        
        switch(type) {
        case RoutineType.Category:
            return 0
            
        default:
            let section = routinePart as! Section
            
            if(section.mode == SectionMode.All) {
                return section.exercises.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Recycling of cells
        let cell = tableView.dequeueReusableCellWithIdentifier(exerciseCellIdentifier, forIndexPath: indexPath) as UITableViewCell!
        
        // todo: we should use (if let option) to avoid crashes
        let currentSection = routine.categoriesAndSections[indexPath.section] as! Section
        
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Close the drawer
        sideNavigationViewController?.toggle()
        
        // get current exercise
        let currentSection = routine.categoriesAndSections[indexPath.section] as! Section
        if currentSection.getType() == RoutineType.Section {
            let currentExercise = currentSection.exercises[indexPath.row] as! Exercise
            
            if(currentSection.mode == SectionMode.All) {
                self.timerController()?.changeExercise(currentExercise)
            } else {
                self.timerController()?.changeExercise(currentSection.currentExercise!)
            }
        }
    }
}