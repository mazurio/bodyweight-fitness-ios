//
// Created by Damian Mazurkiewicz on 10/12/2017.
// Copyright (c) 2017 Damian Mazurkiewicz. All rights reserved.
//

import Foundation

// getEntries
// for 7days

//    return (Calendar.current as NSCalendar).date(byAdding: .day, value: 10, to: Date(), options: [])!

class DataEntriesCompanion {

    func getDataEntries(fromDate: Date, numberOfDays: Int, repositoryRoutines: [RepositoryRoutine]) -> [WorkoutDataEntry] {
        var dataEntries: [WorkoutDataEntry] = []

        for index in 0...(numberOfDays - 1) {
            let date = (Calendar.current as NSCalendar).date(
                    byAdding: .day,
                    value: -index,
                    to: fromDate,
                    options: []
            )!

            print(date)
            print(index)

            dataEntries.append(
                    WorkoutDataEntry(
                            x: Double(index),
                            y: 0,
                            repositoryRoutine: nil
                    )
            )
        }


        return dataEntries
    }
}