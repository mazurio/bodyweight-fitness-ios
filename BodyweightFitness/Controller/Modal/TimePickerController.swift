import UIKit
import RealmSwift

class TimePickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var timePickerView: UIPickerView!
    
    var minutes: Int = 1
    var seconds: Int = 15
    
    init() {
        super.init(nibName: "TimePickerModalView", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(nibName: "TimePickerModalView", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timePickerView.dataSource = self;
        self.timePickerView.delegate = self;
        
        self.timePickerView.selectRow(minutes, inComponent: 0, animated: true)
        self.timePickerView.selectRow(seconds, inComponent: 1, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0) {
            return 16
        } else {
            return 60
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0) {
            return String(row)
        } else {
            return String(row)
        }
    }
    
    func setDefaultTimer(let seconds: Int) {
        if(seconds <= 5) {
            (_, self.minutes, self.seconds) = secondsToHoursMinutesSeconds(5)
        }
        
        (_, self.minutes, self.seconds) = secondsToHoursMinutesSeconds(seconds)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func getTotalSeconds() -> Int {
        let minutes = self.timePickerView.selectedRowInComponent(0)
        let seconds = self.timePickerView.selectedRowInComponent(1)
        
        var totalSeconds = (minutes * 60) + seconds
        
        if(totalSeconds < 5) {
            totalSeconds = 5
        }
        
        return totalSeconds
    }
}
