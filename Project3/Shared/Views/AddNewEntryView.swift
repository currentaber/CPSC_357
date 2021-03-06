//
//  AddNewEntryView.swift
//  Project #3
//
//  Created by Curren Taber and Aviv Zohman on 11/30/21.
//

import SwiftUI
import PencilKit
import Foundation

// Add Item View
struct AddNewEntryView: View {
    
    // Needed for custom back navigation button
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    // Core Data Variables for Dreams
    @State private var dreamTitle = ""
    @State private var dreamEntry = ""
    @State private var dreamCanvas = PKCanvasView()
    private let dreamDate = Date()
    
    // Core Data Manager
    let coreDM: CoreDataManager
    
    // Array of Dream objects
    @State private var dreams: [Dream] = [Dream]()
    
    // Populates an array of Dreams
    private func populateDreams() {
        dreams = coreDM.getAllDreams()
    }
    
    // Only works if dreamTitle and dreamEntry are not empty
    private func saveDream() {
        if !dreamTitle.isEmpty && !dreamEntry.isEmpty {
            coreDM.saveDream(title: dreamTitle, entry: dreamEntry, canvas: dreamCanvas.drawing.dataRepresentation(), date: dreamDate)
            populateDreams()
            self.mode.wrappedValue.dismiss()
        }
    }
    
    // Body
    var body: some View {
        ZStack(alignment: .top) {
            // Background Color
            Color.purple_light.edgesIgnoringSafeArea(.all)
            
            // Rest of Views in a VStack
            VStack(alignment: .leading) {
                Text("New Entry")
                    .font(.h1)
                    .foregroundColor(.purple_dark)
                    .padding(.leading, 30)
                
                Spacer()
                    .frame(height: 10)
                
                // Sketch Header and Clear Canvas Button
                HStack {
                    Text("Sketch")
                        .font(.h2)
                        .foregroundColor(.purple_dark)
                    Spacer()
                    Button(action: deleteDrawing, label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.purple_dark)
                    })
                }
                .padding(.leading, 30)
                .padding(.trailing, 20)
                
                // Canvas View For Sketching
                CanvasView(canvasView: $dreamCanvas, onSaved: saveDrawing)
                    .frame(height: 300)
                    .cornerRadius(20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .background(Color.purple_light)
                
                DataInput(title: "Name of Dream", userInput: $dreamTitle)
                
                DataInput(title: "Description", userInput: $dreamEntry)
                
                Spacer()
                    .frame(height: 40)
                
                Button(action: saveDream, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 203, height: 64)
                            .foregroundColor(.purple_dark)
                        Text("Save")
                            .font(.butn)
                            .foregroundColor(.blue_light)
                    }
                })
                .padding(.leading, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            Image(systemName: "arrow.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
        })
    }
}

// Extensions for drawing in this view
private extension AddNewEntryView {
    // For saving drawing
    // From tutorial, but not really necessary for this app
    func saveDrawing() {
        let _ = dreamCanvas.drawing.image(from: dreamCanvas.bounds, scale: UIScreen.main.scale)
    }

    // For clearing the canvas
    func deleteDrawing() {
        dreamCanvas.drawing = PKDrawing()
    }
}


// Preview Structure
struct AddNewEntryView_Previews: PreviewProvider {
    static var previews: some View {
        
        AddNewEntryView(coreDM: CoreDataManager())
    }
}

// Subview for text input
struct DataInput: View {
    var title: String
    @Binding var userInput: String
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            Text(title)
                .font(.h2)
                .foregroundColor(.purple_dark)
                .padding(.leading, 30)
            ZStack {
                // Background Color
                Color.blue_light.edgesIgnoringSafeArea(.all)
                TextField("", text: $userInput)
                    // Custom placeholder
                    .placeholder(when: userInput.isEmpty) {
                        Text("Enter \(title)...")
                            .foregroundColor(.purple_light)
                    }
                    // Modifies the internal padding of text input field
                    .customTextField(color: .black, padding: 20, lineWidth: 0)
                    .foregroundColor(.purple_dark)
            }
            .cornerRadius(20)
            .padding(.leading, 20)
            .padding(.trailing, 20)

        }
        .padding(.bottom, 10)
    }
}

// For adding internal padding to TextField
struct TextFieldModifier: ViewModifier {
    let color: Color
    let padding: CGFloat // <- space between text and border
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .overlay(RoundedRectangle(cornerRadius: padding)
                        .stroke(color, lineWidth: lineWidth)
            )
    }
}

// Also for adding the internal padding to TextView
extension View {
    func customTextField(color: Color = .secondary, padding: CGFloat = 3, lineWidth: CGFloat = 1.0) -> some View { // <- Default settings
        self.modifier(TextFieldModifier(color: color, padding: padding, lineWidth: lineWidth))
    }
}

// For adding custom placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
