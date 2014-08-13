// -*- mode:swift -*-

import UIKit
import MediaPlayer
import AVFoundation

class ViewController : UIViewController
{
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var playButton: UIButton!

  var mediaItem: MPMediaItem?
  var player: AVAudioPlayer?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.resetPlayer()
    self.playButton.enabled = false
    self.titleLabel.text = "(no music)"
  }
}

// MARK: Custom Logic
extension ViewController {
  @IBAction func pressPicker(sender: UIButton) {
    if let p = self.player {
      p.stop()
    }

    var picker = MPMediaPickerController(mediaTypes:.Music)
    picker.delegate = self
    picker.allowsPickingMultipleItems = false
    picker.showsCloudItems = false
    picker.prompt = "music picker"

    self.presentViewController(picker, animated:true, completion:nil)
  }

  @IBAction func pressPlay(sender: UIButton) {
    if self.mediaItem == nil {
      self.resetPlayer()
      return
    }

    if self.player == nil {
      self.runPlayer()
      return
    }

    self.stopPlayer()
  }

  func resetPlayer() {
    self.stopPlayer()
    self.playButton.enabled = false
  }

  func stopPlayer() {
    if let p = self.player {
      p.stop()
      self.player = nil
      self.playButton.setTitle("Play", forState:.Normal)
    }
  }

  func runPlayer() {
    if self.mediaItem == nil {
      return
    }

    let u: NSURL =
      self.mediaItem!.valueForProperty(MPMediaItemPropertyAssetURL) as NSURL
    if u == nil {
      return
    }

    self.player = AVAudioPlayer(contentsOfURL:u, error:nil)
    self.player!.play()
    self.playButton.setTitle("Stop", forState:.Normal)
  }
}

// MARK: MPMediaPickerControllerDelegate
extension ViewController : MPMediaPickerControllerDelegate {
  func mediaPicker(mediaPicker: MPMediaPickerController!,
    didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
    func completion() {
      self.dismissViewControllerAnimated(true, completion:nil)
    }

    self.playButton.enabled = false
    self.mediaItem = nil
    if (mediaItemCollection.items.count <= 0) {
      completion()
      return
    }

    var i: MPMediaItem = mediaItemCollection.items[0] as MPMediaItem
    var b = i.valueForProperty(MPMediaItemPropertyIsCloudItem) as NSNumber
    if (b.boolValue) {
      self.titleLabel.text = "(sorry, not on the device)"
      self.resetPlayer()
      completion()
      return
    }

    self.mediaItem = i
    self.titleLabel.text =
      i.valueForProperty(MPMediaItemPropertyTitle) as String
    println("selected title: \(self.titleLabel.text)")
    println("URL: \(i.valueForProperty(MPMediaItemPropertyAssetURL))")
    self.playButton.setTitle("Play", forState:.Normal)
    self.playButton.enabled = true

    completion()
  }

  func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
    self.dismissViewControllerAnimated(true, completion:nil)
  }
}
