import UIKit

class LogWorkoutController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let headerCell = "HeaderCell"
    let setCell = "SetCell"
    let addNewSetCell = "AddNewSetCell"
    
    var numberOfSets = 1
    
    var exercise: RepositoryExercise?
    var routine: RepositoryRoutine?
    
    func setRepositoryRoutine(exercise: Exercise, repositoryRoutine: RepositoryRoutine) {
        if let repositoryExercise = repositoryRoutine.exercises.filter({
            $0.exerciseId == exercise.exerciseId
        }).first {
            self.exercise = repositoryExercise
            self.routine = repositoryRoutine
            
            self.navigationItem.title = self.exercise?.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfSets = (self.exercise?.sets.count)!
        
        let titleDict: NSDictionary = [
            NSForegroundColorAttributeName: UIColor(red:0, green:0.27, blue:0.24, alpha:1)
        ]
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.setBackgroundImage(
            UIImage(),
            forBarMetrics: UIBarMetrics.Default
        )
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func onClickButtonClose(sender: AnyObject) {
        let realm = RepositoryStream.sharedInstance.getRealm()
        
        try! realm.write {
            realm.add(exercise!, update: true)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (tableView.dequeueReusableCellWithIdentifier(headerCell) as UITableViewCell!).contentView
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return numberOfSets + 1
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == numberOfSets) {
            let cell = tableView.dequeueReusableCellWithIdentifier(addNewSetCell, forIndexPath: indexPath) as UITableViewCell!
            
            return cell
        }
        
        let set: RepositorySet = (self.exercise?.sets[indexPath.row])!
        let cell = tableView.dequeueReusableCellWithIdentifier(setCell, forIndexPath: indexPath) as! SetCell
        
        cell.setLabel?.text = String(indexPath.row + 1)
        cell.repsText?.text = String(set.reps)
        cell.weightText?.text = String(set.weight)
        
        // todo: update those values on change
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            numberOfSets -= 1
            
            let realm = RepositoryStream.sharedInstance.getRealm()
            try! realm.write {
                self.exercise?.sets.removeAtIndex(indexPath.row)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == numberOfSets) {
            numberOfSets += 1
            
            let realm = RepositoryStream.sharedInstance.getRealm()
            try! realm.write {
                let repositorySet = RepositorySet()
                repositorySet.exercise = self.exercise!
            
                if(self.exercise?.defaultSet == "weighted") {
                    repositorySet.isTimed = false
                } else {
                    repositorySet.isTimed = true
                }
            
                self.exercise?.sets.append(repositorySet)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            });
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}