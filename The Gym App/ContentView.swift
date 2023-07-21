import SwiftUI

struct ContentView: View {
    @State private var savedWorkouts = [Workout]()  // Array to store saved workouts
    
    var body: some View {
        TabView {
            NavigationView {
                MyWorkoutsView(savedWorkouts: $savedWorkouts)  // Pass the saved workouts array
                    .navigationTitle("My Workouts")
            }
            .tabItem {
                Label("My Workouts", systemImage: "list.bullet")
            }
            
            NavigationView {
                AnalyticsView(savedWorkouts: savedWorkouts)  // Pass the saved workouts array
                    .navigationTitle("Analytics")
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.bar.fill")
            }
        }
    }
}

struct MyWorkoutsView: View {
    @Binding var savedWorkouts: [Workout]  // Binding to the saved workouts
    
    var body: some View {
        VStack {
            Text("My Workouts")
                .font(.largeTitle)
                .padding()
            
            NavigationLink(destination: CreateWorkoutView(savedWorkouts: $savedWorkouts)) {
                Text("Create New Workout")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            ForEach(savedWorkouts.indices, id: \.self) { index in
                VStack {
                    Text(savedWorkouts[index].name)
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .padding(.horizontal)
                    
                    ForEach(savedWorkouts[index].exercises.indices, id: \.self) { exerciseIndex in
                        VStack {
                            HStack {
                                Text(savedWorkouts[index].exercises[exerciseIndex].name)
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    addNewWeight(savedWorkoutIndex: index, exerciseIndex: exerciseIndex)
                                }) {
                                    Text("Add Weight")
                                        .padding(.horizontal)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            HStack {
                                Text("Rep Count: \(savedWorkouts[index].exercises[exerciseIndex].repCount)")
                                Spacer()
                                Text("Set Count: \(savedWorkouts[index].exercises[exerciseIndex].setCount)")
                                Spacer()
                                Text("Weight: \(savedWorkouts[index].exercises[exerciseIndex].weight, specifier: "%.1f") \(savedWorkouts[index].exercises[exerciseIndex].unit)")
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func addNewWeight(savedWorkoutIndex: Int, exerciseIndex: Int) {
        let newWeight = Double.random(in: 50...100)  // Generate a random weight for demonstration
        
        savedWorkouts[savedWorkoutIndex].exercises[exerciseIndex].weight = newWeight
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
    @Binding var savedWorkouts: [Workout]  // Binding to the saved workouts
    
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
        
        savedWorkouts.append(workout)  // Append the new workout to the saved workouts array
        
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
        
        // Create a file URL with the workout name as the filename
        let fileURL = documentsDirectory.appendingPathComponent("\(workoutName).txt")
        
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

struct EditExerciseView: View {
    @Binding var savedWorkouts: [Workout]  // Binding to the saved workouts
    let workoutIndex: Int
    let exerciseIndex: Int
    
    var body: some View {
        Form {
            Section(header: Text("Exercise Name")) {
                TextField("Exercise Name", text: $savedWorkouts[workoutIndex].exercises[exerciseIndex].name)
            }
            
            Section(header: Text("Exercise Details")) {
                VStack(alignment: .leading) {
                    Text("Rep Count:")
                    TextField("Rep Count", text: $savedWorkouts[workoutIndex].exercises[exerciseIndex].repCount)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Set Count:")
                    TextField("Set Count", text: $savedWorkouts[workoutIndex].exercises[exerciseIndex].setCount)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Weight:")
                    HStack {
                        TextField("Weight", value: $savedWorkouts[workoutIndex].exercises[exerciseIndex].weight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .frame(width: 70)
                            .multilineTextAlignment(.trailing)
                        
                        Text(savedWorkouts[workoutIndex].exercises[exerciseIndex].unit)
                    }
                }
            }
            
            Section {
                Button(action: saveExercise) {
                    Text("Save Exercise")
                }
            }
        }
        .navigationTitle("Edit Exercise")
    }
    
    private func saveExercise() {
        // Get the documents directory path
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        // Create a file URL with the workout name as the filename
        let workoutFileURL = documentsDirectory.appendingPathComponent("\(savedWorkouts[workoutIndex].name).txt")
        
        do {
            // Convert workout information to a string
            var workoutText = "Workout Name: \(savedWorkouts[workoutIndex].name)\n\n"
            workoutText += "Exercises:\n"
            for exercise in savedWorkouts[workoutIndex].exercises {
                workoutText += "- Exercise Name: \(exercise.name)\n"
                workoutText += "  Rep Count: \(exercise.repCount)\n"
                workoutText += "  Set Count: \(exercise.setCount)\n"
                workoutText += "  Weight: \(exercise.weight) \(exercise.unit)\n\n"
            }
            
            // Write the updated workout text to the file
            try workoutText.write(to: workoutFileURL, atomically: true, encoding: .utf8)
            
            print("Exercise Updated")
            print("File URL: \(workoutFileURL.absoluteString)")
        } catch {
            print("Failed to update exercise: \(error.localizedDescription)")
        }
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var repCount: String
    var setCount: String
    var weight: Double
    var unit: String
}

struct Workout {
    var name: String
    var exercises: [Exercise]
}

struct LineChartView: View {
    let dataPoints: [Double]
    
    var body: some View {
        // Implement your line chart view here
        Text("Line Chart")
    }
}

struct AnalyticsView: View {
    let savedWorkouts: [Workout]  // Array of saved workouts
    @State private var selectedWorkoutIndex = 0
    @State private var showGraph = false
    
    var body: some View {
        VStack {
            Picker("Select Workout", selection: $selectedWorkoutIndex) {
                ForEach(savedWorkouts.indices, id: \.self) { index in
                    Text(savedWorkouts[index].name).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button(action: {
                showGraph.toggle()
            }) {
                Text(showGraph ? "Hide Graph" : "Show Graph")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if showGraph {
                LineChartView(dataPoints: savedWorkouts[selectedWorkoutIndex].exercises.map { $0.weight })
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
