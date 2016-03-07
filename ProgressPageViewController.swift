import Foundation
import UIKit

class ProgressPageViewController: UITableViewController {
    var parentController: UIViewController?
    
    var category: RepositoryCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(
            UINib(nibName: "SectionViewCell", bundle: nil),
            forCellReuseIdentifier: "SectionViewCell")
        
        self.tableView.registerNib(
            UINib(nibName: "CardViewCell", bundle: nil),
            forCellReuseIdentifier: "CardViewCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let category = self.category {
            return category.sections.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let category = self.category {
            let exercises = category.sections[section].exercises.filter { (exercise) in
                exercise.visible == true
            }
            
            return exercises.count
        }
        
        return 0
    }
    @IBAction func onClickRemove(sender: AnyObject) {
    }
    @IBAction func onClickExport(sender: AnyObject) {
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 166
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("SectionViewCell") as! SectionViewCell
        
        cell.parentController = parentController
        
        if let category = self.category {
            let section = category.sections[section]
            
            cell.title.text = section.title
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CardViewCell", forIndexPath: indexPath) as! CardViewCell
        
        cell.parentController = parentController
        
        if let category = self.category {
            let exercises = category.sections[indexPath.section].exercises.filter { (exercise) in
                exercise.visible == true
            }
            
            let exercise = exercises[indexPath.row]
            
            cell.exercise = exercise
            
            cell.title.text = exercise.title
            cell.subtitle.text = exercise.desc
        }
        
        return cell
    }
}
