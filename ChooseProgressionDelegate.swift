import UIKit

class ChooseProgressionDelegate: NSObject, UIActionSheetDelegate {
    let timerController: TimerController
    
    init(timerController: TimerController) {
        self.timerController = timerController
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let exercise = self.timerController.current?.section?.exercises[buttonIndex - 1] as? Exercise {
            self.timerController.routine.setProgression(exercise)
            self.timerController.changeExercise(exercise)
            
            PersistenceManager.storeRoutine(self.timerController.routine)
            
            let sideViewController = self.timerController.sideNavigationViewController?.sideViewController as? SideViewController
            sideViewController?.notifyDataSetChanged(self.timerController.routine)
        }
    }
}