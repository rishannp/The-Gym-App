//
//  ContentView.swift
//  The Gym App
//
//  Created by Rishan Patel on 11/07/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                MyWorkoutsView()
                    .navigationTitle("My Workouts")
            }
            .tabItem {
                Label("My Workouts", systemImage: "list.bullet")
            }
            
            NavigationView {
                AnalyticsView()
                    .navigationTitle("Analytics")
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.bar.fill")
            }
        }
    }
}

struct MyWorkoutsView: View {
    var body: some View {
        VStack {
            Text("My Workouts")
                .font(.largeTitle)
                .padding()
            
            NavigationLink(destination: CreateWorkoutView()) {
                Text("Create New Workout")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct CreateWorkoutView: View {
    @State private var workoutName = ""
    @State private var exerciseName = ""
    @State private var repCount = ""
    @State private var setCount = ""
    @State private var weight = 0.0
    @State private var isKgSelected = true
    @State private var exercises = [Exercise]()

    var body: some View {
        Form {
            Section(header: Text("Workout Name")) {
                TextField("Workout Name", text: $workoutName)
            }
            
            Section(header: Text("Add Exercises")) {
                VStack {
                    TextField("Exercise Name", text: $exerciseName)
                    HStack {
                        TextField("Rep Count", text: $repCount)
                            .keyboardType(.numberPad)
                        TextField("Set Count", text: $setCount)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Slider(value: $weight, in: 0...100, step: 1)
                        Text(String(format: "%.1f", weight))
                            .padding(.leading, 5)
                        Text(isKgSelected ? "kg" : "lbs")
                            .padding(.leading, 5)
                    }
                    Picker(selection: $isKgSelected, label: Text("")) {
                        Text("kg").tag(true)
                        Text("lbs").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Button(action: addExercise) {
                    Text("Add Exercise")
                }
            }
            
            Section(header: Text("Exercises")) {
                List {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            HStack {
                                Text("Rep Count: \(exercise.repCount)")
                                Spacer()
                                Text("Set Count: \(exercise.setCount)")
                                Spacer()
                                Text("Weight: \(exercise.weight, specifier: "%.1f") \(exercise.unit)")
                            }
                        }
                    }
                    .onDelete(perform: deleteExercise)
                }
            }
            
            Section {
                Button(action: saveWorkout) {
                    Text("Save Workout")
                }
            }
        }
        .navigationTitle("Create Workout")
    }
    
    private func addExercise() {
        guard !exerciseName.isEmpty, !repCount.isEmpty, !setCount.isEmpty else {
            return
        }
        
        let unit = isKgSelected ? "kg" : "lbs"
        let newExercise = Exercise(name: exerciseName,
                                   repCount: repCount,
                                   setCount: setCount,
                                   weight: weight,
                                   unit: unit)
        
        exercises.append(newExercise)
        
        // Clear the input fields for the next exercise
        exerciseName = ""
        repCount = ""
        setCount = ""
        weight = 0.0
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    private func saveWorkout() {
        guard !workoutName.isEmpty, !exercises.isEmpty else {
            return
        }
        
        let workout = Workout(name: workoutName, exercises: exercises)
        
        // Convert workout information to a string
        var workoutText = "Workout Name: \(workout.name)\n\n"
        workoutText += "Exercises:\n"
        for exercise in workout.exercises {
            workoutText += "- Exercise Name: \(exercise.name)\n"
            workoutText += "  Rep Count: \(exercise.repCount)\n"
            workoutText += "  Set Count: \(exercise.setCount)\n"
            workoutText += "  Weight: \(exercise.weight) \(exercise.unit)\n\n"
        }
        
        // Get the documents directory path
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        // Create a file URL for the workout text file
        let fileURL = documentsDirectory.appendingPathComponent("workout.txt")
        
        do {
            // Write the workout text to the file
            try workoutText.write(to: fileURL, atomically: true, encoding: .utf8)
            
            print("Workout Saved")
            print("File URL: \(fileURL.absoluteString)")
        } catch {
            print("Failed to save workout: \(error.localizedDescription)")
        }
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let repCount: String
    let setCount: String
    let weight: Double
    let unit: String
}

struct Workout {
    let name: String
    let exercises: [Exercise]
}

struct AnalyticsView: View {
    @State private var searchText = ""
    @State private var showGraph = false
    
    var body: some View {
        VStack {
            
            TextField("Search", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Toggle("Show Graph", isOn: $showGraph)
                .padding()
            
            if showGraph {
                Text("Graph")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            } else {
                Text("Search Results")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
