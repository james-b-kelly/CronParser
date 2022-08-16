//
//  Script.swift
//  CronParser
//
//  Created by Jamie Kelly on 14/08/2022.
//

import Foundation

class Script {
    
    func processLines(_ lines: [String], time: String) -> [Result]? {
        guard let time = processInputTime(time) else {
            return nil
        }
        let results = lines.compactMap({ processLine($0, currentHour: time.hour, currentMinute: time.minute) })
        return results
    }
    
    func processInputTime(_ time: String) -> (hour: Int, minute: Int)? {
        let digits = time.components(separatedBy: ":")
        guard digits.count == 2 else {
            return nil
        }
        let hourString = digits[0]
        let minuteString = digits[1]

        guard
            hourString.isNumber, minuteString.isNumber,
            let hour = Int(hourString),
            let minute = Int(minuteString) else {
            return nil
        }
        
        if hour < 0 || hour > 23 || minute < 0 || minute > 59 {
            return nil
        }
        return (hour, minute)
    }
    
    struct Result {
        let scriptName: String
        let nextCallHour: Int
        let nextCallMinute: Int
        let isToday: Bool
        
        var displayString: String {
            let todayString = isToday ? "today" : "tomorrow"
            let hourString = String(format: "%02d", nextCallHour)
            let minuteString = String(format: "%02d", nextCallMinute)
            return "\(hourString):\(minuteString) \(todayString) \(scriptName)"
        }
    }
    
    func processLine(_ line: String, currentHour: Int, currentMinute: Int) -> Result?  {
        guard let components = splitLine(line) else {
            return nil
        }
        
        let nextCalledHour: Int
        let nextCalledMinute: Int
        let isToday: Bool
        
        if let hour = components.hour {
            //Specific hour.
            if hour == currentHour {
                if let minute = components.minute {
                    if minute >= currentMinute {
                        //This hour, but later minute.
                        nextCalledHour = hour
                        nextCalledMinute = minute
                        isToday = true
                    }
                    else {
                        //This hour, but minute has passed, so tomorrow.
                        nextCalledHour = hour
                        nextCalledMinute = minute
                        isToday = false
                    }
                }
                else {
                    //All minutes, but in current hour.
                    nextCalledHour = hour
                    nextCalledMinute = currentMinute
                    isToday = true
                }
            }
            else {
                //Not this hour, either later today, or tomorrow.
                isToday = hour > currentHour
                nextCalledHour = hour
                nextCalledMinute = components.minute ?? 0
            }
        }
        else {
            //Wildcard hour.
            if let minute = components.minute {
                //Every hour, specific minute.
                if minute >= currentMinute {
                    //Every hour, later minute than now.
                    nextCalledHour = currentHour
                    nextCalledMinute = minute
                    isToday = true
                }
                else if currentHour < 23 {
                    //Minute has passed, so check if we have at least one more hour to catch the minute today.
                    nextCalledHour = currentHour + 1
                    nextCalledMinute = minute
                    isToday = true
                }
                else {
                    nextCalledHour = 0
                    nextCalledMinute = minute
                    isToday = false
                }
            }
            else {
                //Every minute, every hour.
                nextCalledMinute = currentMinute
                nextCalledHour = currentHour
                isToday = true
            }
        }
        
        let result = Result(scriptName: components.scriptName,
                            nextCallHour: nextCalledHour,
                            nextCallMinute: nextCalledMinute,
                            isToday: isToday)
        return result
    }
    
    /// Splits input config line into hour, minute, and script name.
    /// - Parameter line: Line with 3 components: an hour (wildcard or int), a minute (wildcard or int), and a script name.
    /// - Returns: If hour or minute are wild card they will be returned as nil.
    func splitLine(_ line: String) -> (hour: Int?, minute: Int?, scriptName: String)? {
        let components = line.components(separatedBy: .whitespaces).filter({ $0.count > 0 })
        guard components.count == 3 else {
            print("Invalid line in input file - '\(line)'")
            return nil
        }
        let wildCard = "*"
        let hour = components[1]
        let minute = components[0]
        let scriptName = components[2]

        guard hour.isNumber || hour == wildCard, minute.isNumber || minute == wildCard else {
            print("Invalid time in input file - `\(line)`")
            return nil
        }
        
        return (hour == wildCard ? nil : Int(hour),
                minute == wildCard ? nil : Int(minute),
                scriptName)
    }
    
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
