import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var routine: Routine = RoutineStream.sharedInstance.routine
    
    init() {
        super.init(nibName: "DashboardView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.tableView.registerNib(
            UINib(nibName: "DashboardCategoryViewCell", bundle: nil),
            forCellReuseIdentifier: "DashboardCategoryViewCell")
        
        self.tableView.registerNib(
            UINib(nibName: "DashboardSectionViewCell", bundle: nil),
            forCellReuseIdentifier: "DashboardSectionViewCell")
        
        self.tableView.registerNib(
            UINib(nibName: "DashboardSingleItemViewCell", bundle: nil),
            forCellReuseIdentifier: "DashboardSingleItemViewCell")
        
        self.tableView.registerNib(
            UINib(nibName: "DashboardDoubleItemViewCell", bundle: nil),
            forCellReuseIdentifier: "DashboardDoubleItemViewCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None;
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        let r = UIBarButtonItem(title: "Title", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        
        self.navigationItem.leftBarButtonItem = r
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
            let cell = tableView.dequeueReusableCellWithIdentifier("DashboardCategoryViewCell") as! DashboardCategoryViewCell
            
            cell.title?.text = category.title
            
            return cell
        }
        
        if let section = categoryOrSection as? Section {
            let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSectionViewCell") as! DashboardSectionViewCell
            
            cell.title?.text = section.title
            cell.desc?.text = section.desc
            
            return cell
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        if (rowIndex == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSingleItemViewCell", forIndexPath: indexPath) as! DashboardSingleItemViewCell
            
            let section = routine.categoriesAndSections[sectionIndex] as! Section
          
            if (section.mode == SectionMode.All) {
                if let exercise = section.exercises[0] as? Exercise {
                    cell.title?.text = exercise.title
                }
            } else {
                if let exercise = section.currentExercise {
                    cell.title?.text = exercise.title
                }
            }
            
            return cell
        } else {
            let index = (rowIndex - 1) + rowIndex
            
            let section = routine.categoriesAndSections[sectionIndex] as! Section
            let exercise = section.exercises[index] as! Exercise

            if let nextExercise = exercise.next {
                let cell = tableView.dequeueReusableCellWithIdentifier("DashboardDoubleItemViewCell", forIndexPath: indexPath) as! DashboardDoubleItemViewCell
                
                if (nextExercise.section === exercise.section) {
                    cell.leftTitle?.text = exercise.title
                    cell.rightTitle?.text = nextExercise.title
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSingleItemViewCell", forIndexPath: indexPath) as! DashboardSingleItemViewCell
                    
                    cell.title?.text = exercise.title
                    
                    return cell
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("DashboardSingleItemViewCell", forIndexPath: indexPath) as! DashboardSingleItemViewCell
                
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
}