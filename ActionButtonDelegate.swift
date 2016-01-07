 import UIKit
 
 class ActionButtonDelegate: NSObject, UIActionSheetDelegate {
    let timerController: TimerController
    
    init(timerController: TimerController) {
        self.timerController = timerController
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 0) {
            return
        } else if(buttonIndex == 1) {
            // Buy Equipment
            print("Buy Equipment")
        } else if(buttonIndex == 2) {
            // YouTube
            print("Watch on YouTube")
        } else if(buttonIndex == 3) {
            if let exercises = self.timerController.current?.section?.exercises {
                let sheet = UIActionSheet(
                    title: nil,
                    delegate: self.timerController.chooseProgressionDelegate,
                    cancelButtonTitle: "Cancel",
                    destructiveButtonTitle: nil)
                
                sheet.tintColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1)
                
                for anyExercise in exercises {
                    if let exercise = anyExercise as? Exercise {
                        if(exercise.section?.mode == SectionMode.Levels) {
                            sheet.addButtonWithTitle("\(exercise.level): \(exercise.title)")
                        } else {
                            sheet.addButtonWithTitle("\(exercise.title)")
                        }
                    }
                }
                
                sheet.showInView(self.timerController.view)
            }
        }
    }
 }
