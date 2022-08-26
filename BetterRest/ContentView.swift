//
//  ContentView.swift
//  BetterRest
//
//  Created by Yuri Gerasimchuk on 13.05.2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var calculateBedTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
            
        } catch {
            return "Sorry there was a problem calculating your bedtime."
        }
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Text("When do you want to wake up?")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .listRowBackground(Color.cyan)
                    
                    DatePicker("Set the time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .padding([.top, .bottom], 10)

                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Desired amount of sleep")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .listRowBackground(Color.cyan)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...12, step: 0.25)
                        .padding([.top, .bottom], 10)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Daily coffee intake")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .listRowBackground(Color.cyan)
                    
                    // Another option with Stepper
                    // Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text($0, format: .number)
                        }
                    }
                    .padding([.top, .bottom], 10)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Your ideal bed time is")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .listRowBackground(Color.cyan)
                    HStack {
                        Spacer()
                        Text("\(calculateBedTime)")
                            .font(.system(size: 50))
                            .fontWeight(.semibold)
                            .padding([.top, .bottom], 30)
                        Spacer()
                    }
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 mini")
            .previewLayout(.device)
    }
}
