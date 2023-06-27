import UIKit
import AVFoundation
import GuruSwiftSDK

class InferenceViewController: UIViewController {
  
    
    
    
    
    
    
    @IBOutlet weak var lblCount: UILabel!
    
    
  var inference: LocalVideoInference?
  @IBOutlet weak var imageView: UIImageView!
  var userLastFacing: UserFacing = UserFacing.other

  @IBAction func beingCapture(_ sender: AnyObject) {
    do {
        inference = try LocalVideoInference(
        consumer: self,
        cameraPosition: .front,
        source: "beth",
        apiKey: ""
        
      )
      
      Task {
        let videoId = try await inference!.start(activity: Activity.push_up)
        print("Guru videoId is \(videoId)")
          
          
      }
    }
    catch {
      print("Unexpected error starting inference: \(error)")
    }
  }
    
    
    @IBAction func stop(_ sender: AnyObject) {
        Task { @MainActor in
            
            try! await inference?.stop()
            
        }
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    Task {
      try! await inference?.stop()
    }
  }
}

extension InferenceViewController: InferenceConsumer {
    
    
    func consumeFrame(frame: UIImage, inference: GuruSwiftSDK.FrameInference) {
        
        
        imageView.image = frame
        
    }
    
  
  func consumeAnalysis(analysis: Analysis) {
      self.lblCount.text = "\(analysis.reps.count)"
      
      print("count to be show ===== \(analysis.reps.count)")
      
  }
  
  func consumeFrame(frame: UIImage, inference: FrameInference?) {
    if (inference != nil) {
      let painter = InferencePainter(frame: frame, inference: inference!)
        .paintLandmarkConnector(from: InferenceLandmark.leftShoulder, to: InferenceLandmark.leftElbow)
        .paintLandmarkConnector(from: InferenceLandmark.leftElbow, to: InferenceLandmark.leftWrist)
        .paintLandmarkConnector(from: InferenceLandmark.leftShoulder, to: InferenceLandmark.leftHip)
        .paintLandmarkConnector(from: InferenceLandmark.leftHip, to: InferenceLandmark.leftKnee)
        .paintLandmarkConnector(from: InferenceLandmark.leftKnee, to: InferenceLandmark.leftAnkle)
        .paintLandmarkConnector(from: InferenceLandmark.rightShoulder, to: InferenceLandmark.rightElbow)
        .paintLandmarkConnector(from: InferenceLandmark.rightElbow, to: InferenceLandmark.rightWrist)
        .paintLandmarkConnector(from: InferenceLandmark.rightShoulder, to: InferenceLandmark.rightHip)
        .paintLandmarkConnector(from: InferenceLandmark.rightHip, to: InferenceLandmark.rightKnee)
        .paintLandmarkConnector(from: InferenceLandmark.rightKnee, to: InferenceLandmark.rightAnkle)
      
      let userFacing = inference!.userFacing()
      if (userFacing != UserFacing.other) {
        userLastFacing = userFacing
      }
      if (userLastFacing == UserFacing.left) {
        painter.paintLandmarkAngle(center: InferenceLandmark.rightShoulder, from: InferenceLandmark.rightHip, to: InferenceLandmark.rightElbow, clockwise: true)
      }
      else if (userLastFacing == UserFacing.right) {
        painter.paintLandmarkAngle(center: InferenceLandmark.leftShoulder, from: InferenceLandmark.leftHip, to: InferenceLandmark.leftElbow, clockwise: false)
      }
      
      imageView.image = painter.finish()
    }
    else {
      imageView.image = frame
    }
  }
}
