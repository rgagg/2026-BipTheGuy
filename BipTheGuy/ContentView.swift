//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Richard Gagg on 31/1/2026.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
  
  @State private var audioPlayer: AVAudioPlayer!
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var bipImage: Image = Image("clown")
  @State private var isFullSize: Bool = true
  
  @AppStorage("savedImageData") private var savedImageData: Data?
  
  var body: some View {
    VStack {
      Spacer()
      
      bipImage
        .resizable()
        .scaledToFit()
        .scaleEffect(isFullSize ? 1.0 : 0.9)
        .padding(.horizontal, 10)
        .onTapGesture {
          playSound(soundName: "punchSound")
          isFullSize = false
          // Will immediately shink image to 90% using scale effect.
          
          withAnimation(.spring(response: 0.3, dampingFraction: 0.2)) {
            isFullSize = true
          }
          // Will resize image to 100% but using the .spring animation.
          
        }
      
      Spacer()
      
      PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
        Label("Photo Library", systemImage: "photo.on.rectangle.angled")
          .font(.title2)
          .padding(.horizontal, 20)
      }
      .buttonStyle(.glassProminent)
      .tint(.cooler1)
      .onChange(of: selectedPhoto) {
        
        Task {
          
          guard let selectedPhoto = selectedPhoto,
                  let imageData = try? await selectedPhoto.loadTransferable(type: Data.self) else {
            print("🤬 ERROR: could not get image from load transferable.")
            return
          }
          // Save the image data to user defaults
          savedImageData = imageData
          
          // Update the displayed image
          if let uiImage = UIImage(data: imageData) {
            bipImage = Image(uiImage: uiImage)
          }
        }
        
      }
    }
    .onAppear() {
      loadSavedImage()
    }
  }
  
  // Functions
  func loadSavedImage() {
    // Load the saved image from user defaults
    
    if let imageDate = UserDefaults.standard.data(forKey: "savedImageData"),
       let uiImage = UIImage(data: imageDate) {
      bipImage = Image(uiImage: uiImage)
    }
    
  }
  
  
  func playSound(soundName: String) {
    /*
     Import needed module
     Import AVFAudio
     
     Declare audio player
     @State private var audioPlayer: AVFAudioPlayer!
     
     Use the follering function call ensuring you use a
     sound file in the asset catalog
     */
    
    if audioPlayer != nil && audioPlayer.isPlaying {
      audioPlayer.stop()
    }
    
    guard let soundFile = NSDataAsset(name: soundName) else {
      print("🤬 Could not find sound file \(soundName)")
      return
    }
    do {
      audioPlayer = try AVAudioPlayer(data: soundFile.data)
      audioPlayer.play()
    } catch {
      print("🤬 Error: \(error.localizedDescription) creating audio player")
    }
  }
  
}

#Preview("Light Mode") {
  ContentView()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
  ContentView()
    .preferredColorScheme(.dark)
}
