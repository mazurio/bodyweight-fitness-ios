import UIKit

class BuyEquipmentNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class BuyEquipmentController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let titleCellIdentifier = "TitleCell"
    let imageCellIdentifier = "ImageCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "ImageCell", bundle: nil)
        
        tableView.registerNib(nibName, forCellReuseIdentifier: "ImageCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(titleCellIdentifier) as UITableViewCell!

        cell.textLabel?.text = "Title"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            imageCellIdentifier,
            forIndexPath: indexPath
        ) as UITableViewCell!
        
        cell.textLabel?.text = "Cell"
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}