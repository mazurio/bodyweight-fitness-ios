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
            if let youTubeId = self.timerController.current?.youTubeId {
                if let requestUrl = NSURL(string: "https://www.youtube.com/watch?v=" + youTubeId) {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }
            }
        } else if(buttonIndex == 2) {
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
