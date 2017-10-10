import Foundation
import UIKit

class ProgressPageViewController: UITableViewController {
    var parentController: UIViewController?
    
    var category: RepositoryCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(
            UINib(nibName: "ProgressSectionCell", bundle: nil),
            forCellReuseIdentifier: "ProgressSectionCell")
        
        self.tableView.register(
            UINib(nibName: "ProgressCardCell", bundle: nil),
            forCellReuseIdentifier: "ProgressCardCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let category = self.category {
            return category.sections.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let category = self.category {
            let exercises = category.sections[section].exercises.filter { (exercise) in
                self.isVisible(exercise)
            }
            
            return exercises.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 166
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressSectionCell") as! ProgressSectionCell
        
        cell.parentController = parentController
        
        cell.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
        cell.contentView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
        
        if let category = self.category {
            let section = category.sections[section]
            
            cell.title.text = section.title
        }
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCardCell", for: indexPath) as! ProgressCardCell
        
        cell.parentController = parentController
        
        if let category = self.category {
            
            
            let exercises = category.sections[indexPath.section].exercises
            
        
            
            let filteredExercises = Array(exercises).filter { (exercise) in
                self.isVisible(exercise)
            }
            
            let exercise = filteredExercises[indexPath.row]
            
            cell.current = exercise
            
            cell.title.text = exercise.title
            cell.subtitle.text = exercise.desc
        }
        
        return cell
    }

    func isVisible(_ exercise: RepositoryExercise) -> Bool {
        let firstSet = exercise.sets[0]

        if (exercise.sets.count > 1) {
            return true
        } else {
            if (firstSet.seconds > 0 || firstSet.reps > 0) {
                return true
            }
        }

        return exercise.visible
    }
}
