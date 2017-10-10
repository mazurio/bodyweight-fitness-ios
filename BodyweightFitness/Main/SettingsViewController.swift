import UIKit
import Eureka

class SettingsViewController: FormViewController {
    let defaults = Foundation.UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        self.createForm()
    }
}

extension SettingsViewController {
    func createForm() {
        let hideWhenRestTimerIsOffCondition = Condition.function(["showRestTimerSwitchRow"], { form in
            return !((form.rowBy(tag: "showRestTimerSwitchRow") as? SwitchRow)?.value ?? false)
        })
        
        form
            +++ Eureka.Section("General")
            <<< SwitchRow() {
                $0.title = "Play Audio"
                $0.value = self.defaults.bool(forKey: "playAudioWhenTimerStops")
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.defaults.set(value, forKey: "playAudioWhenTimerStops")
                    }
                }
            }
            <<< PushRow<String>() {
                $0.title = "Weight Unit"
                $0.value = self.weightUnitLabel()
                $0.options = ["Kilograms (kg)", "Pounds (lbs)"]
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        if value == "Kilograms (kg)" {
                            PersistenceManager.setWeightUnit("kg")
                        } else if value == "Pounds (lbs)" {
                            PersistenceManager.setWeightUnit("lbs")
                        }
                    }
                }
            }
            +++ Eureka.Section("Rest Timer")
            <<< SwitchRow("showRestTimerSwitchRow") {
                $0.title = "Show Rest Timer"
                $0.value = self.defaults.bool(forKey: "showRestTimer")
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.defaults.set(value, forKey: "showRestTimer")
                    }
                }
            }
            <<< PushRow<String>() {
                $0.title = "Default Rest Time"
                $0.hidden = hideWhenRestTimerIsOffCondition
                $0.value = self.restTimeLabel()
                $0.options = [
                    "30 Seconds",
                    "1 Minute",
                    "1 Minute 30 Seconds",
                    "2 Minutes",
                    "2 Minutes 30 Seconds"
                ]
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        let valueInSeconds = self.restTimeInSeconds(value: value)
                        
                        PersistenceManager.setRestTime(valueInSeconds)
                    }
                }
            }
            +++ Eureka.Section("Show Rest Timer") {
                $0.hidden = hideWhenRestTimerIsOffCondition
            }
            <<< SwitchRow() {
                $0.title = "After Warmup"
                $0.hidden = hideWhenRestTimerIsOffCondition
                $0.value = self.defaults.bool(forKey: "showRestTimerAfterWarmup")
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.defaults.set(value, forKey: "showRestTimerAfterWarmup")
                    }
                }
            }
            <<< SwitchRow() {
                $0.title = "After Bodyline Drills"
                $0.hidden = hideWhenRestTimerIsOffCondition
                $0.value = self.defaults.bool(forKey: "showRestTimerAfterBodylineDrills")
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.defaults.set(value, forKey: "showRestTimerAfterBodylineDrills")
                    }
                }
            }
            <<< SwitchRow() {
                $0.title = "After Flexibility Exercises"
                $0.hidden = hideWhenRestTimerIsOffCondition
                $0.value = self.defaults.bool(forKey: "showRestTimerAfterFlexibilityExercises")
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        self.defaults.set(value, forKey: "showRestTimerAfterFlexibilityExercises")
                    }
                }
            }
            +++ Eureka.Section("Author")
            <<< TextRow() {
                $0.title = "Name"
                $0.value = "Damian Mazurkiewicz"
                $0.disabled = true
            }
            <<< TextRow() {
                $0.title = "Email"
                $0.value = "damian@mazur.io"
                $0.disabled = true
            }
            <<< TextRow() {
                $0.title = "GitHub"
                $0.value = "https://github.com/mazurio/"
                $0.disabled = true
            }
            +++ Eureka.Section("About")
            <<< TextRow() {
                $0.title = "Name"
                $0.value = "Bodyweight Fitness"
                $0.disabled = true
            }
            <<< TextRow() {
                $0.title = "Version"
                $0.value = self.versionLabel()
                $0.disabled = true
            }
        
    }
    
    func weightUnitLabel() -> String {
        if PersistenceManager.getWeightUnit() == "lbs" {
            return "Pounds (lbs)"
        } else {
            return "Kilograms (kg)"
        }
    }
    
    func restTimeLabel() -> String {
        switch(PersistenceManager.getRestTime()) {
        case 30:
            return "30 Seconds"
        case 60:
            return "1 Minute"
        case 90:
            return "1 Minute 30 Seconds"
        case 120:
            return "2 Minutes"
        case 150:
            return "2 Minutes 30 Seconds"
        default:
            return "1 Minute"
        }
    }
    
    func restTimeInSeconds(value: String) -> Int {
        switch(value) {
        case "30 Seconds":
            return 30
        case "1 Minute":
            return 60
        case "1 Minute 30 Seconds":
            return 90
        case "2 Minutes":
            return 120
        case "2 Minutes 30 Seconds":
            return 150
        default:
            return 60
        }
    }
    
    func versionLabel() -> String? {
        if let anyObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            if let version: String = anyObject as? String {
                return version
            }
        }
        return nil
    }
}

