//
//  UploadView.swift
//  GuidedCaptureSample
//
//  Created by M. Bertan Tarakçıoğlu on 3/29/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
import SceneKit
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct UploadView: View {
    let modelFile: URL
    let endCaptureCallback: () -> Void
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isUploading = false
    @State private var uploadProgress: Float = 0
    @State private var uploadComplete = false
    
    // New state variables for duck data entry
    @State private var currentStep: UploadStep = .authentication
    @State private var duckName: String = ""
    @State private var duckDescription: String = ""
    @State private var userId: String = ""
    
    // Enum to track upload workflow steps
    enum UploadStep {
        case authentication
        case duckDataEntry
        case uploading
        case complete
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Show the model during upload
            ModelViewer(modelURL: modelFile, shouldResetCamera: .constant(false))
                .frame(minHeight: 50, maxHeight: 300)
            
            if !uploadComplete {
                switch currentStep {
                case .authentication:
                    authenticationView
                case .duckDataEntry:
                    duckDataEntryView
                case .uploading:
                    uploadProgressView
                case .complete:
                    uploadCompleteView
                }
            } else {
                uploadCompleteView
            }
        }
        .navigationTitle("Upload Model")
    }
    
    // Authentication view
    private var authenticationView: some View {
        VStack(spacing: 12) {
            Text("Log in to DUX!")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Email", text: $username)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button(action: {
                authenticateUser()
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isUploading || username.isEmpty || password.isEmpty)
        }
        .padding()
    }
    
    // Duck data entry view - new view for entering name and description
    private var duckDataEntryView: some View {
        VStack(spacing: 12) {
            Text("Name Your Duck!")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Duck Name", text: $duckName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .autocapitalization(.words)
            
            Text("Add a Description")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
            
            TextEditor(text: $duckDescription)
                .frame(minHeight: 100)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button(action: {
                startUpload()
            }) {
                Text("Upload Duck")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(duckName.isEmpty)
        }
        .padding()
    }
    
    // Upload progress view
    private var uploadProgressView: some View {
        VStack(spacing: 12) {
            Text("Uploading \(duckName)...")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack {
                ProgressView(value: uploadProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                Text("\(Int(uploadProgress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .padding()
    }
    
    // Upload complete view
    private var uploadCompleteView: some View {
        VStack(spacing: 12) {
            Label("Upload Complete!", systemImage: "checkmark")
                .foregroundStyle(.green)
                .symbolVariant(.circle)
                .symbolRenderingMode(.hierarchical)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(duckName.isEmpty ? "Your 3D model has been successfully uploaded" : "Your duck \"\(duckName)\" has been successfully uploaded")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                UIApplication.shared.open(URL(string: "https://dux.bertant.dev/")!)
            } label:
            {
                Label("View your duck in the DUX website!", systemImage: "arrow.up.forward")
            }
            .frame(maxWidth: .infinity)
            .fontWeight(.bold)
            .padding(.vertical, 12)
            
            Button(action: {
                endCaptureCallback()
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // Function to handle authentication
    private func authenticateUser() {
        errorMessage = ""
        isUploading = true
        
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            isUploading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            if let uid = result?.user.uid {
                // Save the user ID for later use
                userId = uid
                // Proceed to duck data entry after successful authentication
                currentStep = .duckDataEntry
            } else {
                errorMessage = "Failed to get user information"
            }
        }
    }
    
    // Start the upload process after duck data is entered
    private func startUpload() {
        errorMessage = ""
        isUploading = true
        currentStep = .uploading
        
        let modelId = UUID().uuidString
        let modelPath = "duck-models/\(userId)/\(modelId).usdz"
        let previewPath = "duck-previews/\(userId)/\(modelId).jpg"
        let dataPath = "duck-data/\(userId)/\(modelId).json"
        
        // Create duck data object
        let duckData = DuckData(
            displayName: duckName,
            description: duckDescription,
            likeCount: 1
        )
        
        // Generate and upload JSON file from duck data
        uploadDuckData(duckData, to: dataPath) { result in
            switch result {
            case .success(let dataURL):
                // JSON data uploaded successfully, continue with other uploads
                print("Duck data uploaded to: \(dataURL)")
                
                // Generate thumbnail
                if let thumbnailImage = ModelThumbnailGenerator.generateThumbnail(from: modelFile) {
                    if let imageData = thumbnailImage.jpegData(compressionQuality: 0.8) {
                        uploadImageData(imageData, to: previewPath) { progress in
                            uploadProgress = 0.3 + (progress * 0.3) // 30-60%
                        } completion: { result in
                            switch result {
                            case .success(let previewURL):
                                print("Preview image uploaded to: \(previewURL)")
                                
                                // Upload model file after preview upload completes
                                uploadModelFile(self.modelFile, to: modelPath) { progress in
                                    uploadProgress = 0.6 + (progress * 0.4) // 60-100%
                                } completion: { result in
                                    switch result {
                                    case .success(let modelURL):
                                        print("Model uploaded to: \(modelURL)")
                                        uploadComplete = true
                                        currentStep = .complete
                                        isUploading = false
                                    case .failure(let error):
                                        isUploading = false
                                        errorMessage = "Model upload failed: \(error.localizedDescription)"
                                    }
                                }
                            case .failure(let error):
                                isUploading = false
                                errorMessage = "Preview upload failed: \(error.localizedDescription)"
                            }
                        }
                    }
                }
                
            case .failure(let error):
                isUploading = false
                errorMessage = "Duck data upload failed: \(error.localizedDescription)"
            }
        }
    }

    // Upload JSON data from DuckData struct
    private func uploadDuckData(_ data: DuckData, to path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(data)
            
            let storageRef = Storage.storage().reference().child(path)
            
            // Create metadata with JSON content type
            let metadata = StorageMetadata()
            metadata.contentType = "application/json"
            
            // Update progress indicator for this step (0-30%)
            uploadProgress = 0.15
            
            let uploadTask = storageRef.putData(jsonData, metadata: metadata) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        uploadProgress = 0.3 // JSON upload complete (30%)
                        completion(.success(downloadURL))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    private func uploadModelFile(_ fileURL: URL, to path: String, progress: @escaping (Float) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child(path)
        
        // Create metadata with content type
        let metadata = StorageMetadata()
        metadata.contentType = "application/octet-stream"
        
        let uploadTask = storageRef.putFile(from: fileURL, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let downloadURL = url {
                    completion(.success(downloadURL))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            if let progressValue = snapshot.progress {
                let percentage = Float(progressValue.completedUnitCount) / Float(progressValue.totalUnitCount)
                progress(percentage)
            }
        }
    }

    func uploadImageData(_ data: Data, to path: String, contentType: String = "image/jpeg", progress: @escaping (Float) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child(path)
        
        // Create metadata with content type
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        let uploadTask = storageRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let downloadURL = url {
                    completion(.success(downloadURL))
                } else if let error = error {
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            if let progressValue = snapshot.progress {
                let percentage = Float(progressValue.completedUnitCount) / Float(progressValue.totalUnitCount)
                progress(percentage)
            }
        }
    }
}
