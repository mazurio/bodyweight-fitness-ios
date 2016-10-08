import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    let routine: Routine = RoutineStream.sharedInstance.routine
    
    var currentIndexPath: NSIndexPath?
    
    var currentExercise: Exercise?
    var rootViewController: WorkoutViewController?
    
    init() {
        super.init(nibName: "DashboardView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.tableView.registerNib(
            UINib(nibName: "DashboardCategoryCell", bundle: nil),
            forCellReuseIdentifier: "DashboardCategoryCell")
        
        self.tableView.registerNib(
            UINib(nibName: "DashboardSectionCell", bundle: nil),
            forCellReuseIdentifier: "DashboardSectionCell")
        
        self.tableView.registerNib(
            UINib(nibName: "DashboardSingleItemCell", bundle: nil),
            forCellReuseIdentifier: "DashboardSingleItemCell")
        
        self.tableView.registerNib(
            UINib(nibName: "DashboardDoubleItemCell", bundle: nil),
            forCellReuseIdentifier: "DashboardDoubleItemCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 0
        self.tableView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
        
        let closeItem = UIBarButtonItem(
            image: UIImage(named: "close"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss))
        
        closeItem.tintColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1)
        
        self.navigationItem.leftBarButtonItem = closeItem
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return routine.categoriesAndSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryOrSection = routine.categoriesAndSections[section]
        
        if let _ = categoryOrSection as? Category {
            return 0
        }
        
        if let section = categoryOrSection as? Section {
            if (section.mode == SectionMode.All) {
                let numberOfExercises = section.exercises.count
                
                return ((numberOfExercises - 1) / 2) + 1
            } else {
                return 1
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let categoryOrSection = routine.categoriesAndSections[section]
        
        if let category = categoryOrSection as? Category {
            let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCategoryCell") as! DashboardCategoryCell
            
            cell.title?.text = category.title
            
            // iPad Bug: Background color has 1px border.
            // http://stackoverflow.com/posts/27325035/revisions
            cell.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
            cell.contentView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
            
            return cell
        }
        
        if let section = categoryOrSection as? Section {
            let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSectionCell") as! DashboardSectionCell
            
            cell.title?.text = section.title
            cell.desc?.text = section.desc
            
            // iPad Bug: Background color has 1px border.
            // http://stackoverflow.com/posts/27325035/revisions
            cell.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
            cell.contentView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
            
            return cell
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        if (rowIndex == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSingleItemCell", forIndexPath: indexPath) as! DashboardSingleItemCell
            
            let section = routine.categoriesAndSections[sectionIndex] as! Section
          
            if (section.mode == SectionMode.All) {
                if let exercise = section.exercises[0] as? Exercise {
                    setCurrentIndex(exercise, indexPath: indexPath)
                    
                    cell.dashboardViewController = self
                    cell.exercise = exercise
                    cell.title?.text = exercise.title
                }
            } else {
                if let exercise = section.currentExercise {
                    setCurrentIndex(exercise, indexPath: indexPath)
                    
                    cell.dashboardViewController = self
                    cell.exercise = exercise
                    cell.title?.text = exercise.title
                }
            }
            
            return cell
        } else {
            let index = (rowIndex - 1) + rowIndex
            
            let section = routine.categoriesAndSections[sectionIndex] as! Section
            let exercise = section.exercises[index] as! Exercise

            if let nextExercise = exercise.next {
                let cell = tableView.dequeueReusableCellWithIdentifier("DashboardDoubleItemCell", forIndexPath: indexPath) as! DashboardDoubleItemCell
                
                cell.dashboardViewController = self
                
                if (nextExercise.section === exercise.section) {
                    setCurrentIndex(exercise, indexPath: indexPath)
                    setCurrentIndex(nextExercise, indexPath: indexPath)
                    
                    cell.leftExercise = exercise
                    cell.rightExercise = nextExercise
                    
                    cell.leftTitle?.text = exercise.title
                    cell.rightTitle?.text = nextExercise.title
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSingleItemCell", forIndexPath: indexPath) as! DashboardSingleItemCell
                    
                    setCurrentIndex(exercise, indexPath: indexPath)
                    
                    cell.dashboardViewController = self
                    cell.exercise = exercise
                    cell.title?.text = exercise.title
                    
                    return cell
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSingleItemCell", forIndexPath: indexPath) as! DashboardSingleItemCell
                
                setCurrentIndex(exercise, indexPath: indexPath)
                
                cell.dashboardViewController = self
                cell.exercise = exercise
                cell.title?.text = exercise.title
                
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let categoryOrSection = routine.categoriesAndSections[section]
        
        if let _ = categoryOrSection as? Category {
            return 100
        }
        
        return 65
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissWithExercise(exercise: Exercise) {
        self.rootViewController?.changeExercise(exercise)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setCurrentIndex(exercise: Exercise, indexPath: NSIndexPath) {
        if let currentExercise = currentExercise {
            if currentExercise === exercise {
                self.currentIndexPath = indexPath
            }
        }
    }
}