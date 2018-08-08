//
//  AirPlay2ViewController.swift
//  AirPlay
//
//  Created by Kenny Lin on 2018/7/27.
//  Copyright © 2018 Kenny Lin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class AirPlay2ViewController: UIViewController, AVRoutePickerViewDelegate {

    var pickerView: AVRoutePickerView?
    var pickerViewBig: AVRoutePickerView?
    var routeDetector = AVRouteDetector()
    
    var avplayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var seekBar: UISlider!
    var isSeeking: Bool = false
    var readyToPlayCompletionHandler: (()-> ())?
    
    private var playerItemContext = 0
    var updateUIObserver: Any?
    
    lazy var sampleFilePath: String? = {
        return "http://www.largesound.com/ashborytour/sound/AshboryBYU.mp3"
    }()
    
    @IBAction func doDetect(_ sender: Any) {
        routeDetectChange()
    }
    
    @IBAction func doPlay(_ sender: Any) {
        avplayer?.play()
    }
    
    @IBAction func doPause(_ sender: Any) {
        avplayer?.pause()
        
    }
    
    @objc func routeDetectChange() {
        if (routeDetector.multipleRoutesDetected) {
            // AVRoutePickerView
            
            if pickerView == nil {
                DispatchQueue.main.async { [weak self] in
                    if let strongSelf = self {
                        let rect = CGRect.init(origin: CGPoint(x: (strongSelf.view.frame.size.width - 50) / 2, y: 80), size: CGSize(width: 50, height: 50))
                        strongSelf.pickerView = AVRoutePickerView.init(frame: rect)
                        strongSelf.pickerView?.delegate = self
                        strongSelf.view.addSubview(strongSelf.pickerView!)
                        
                        let rectBig = CGRect.init(origin: CGPoint(x: (strongSelf.view.frame.size.width - 150) / 2, y: 200), size: CGSize(width: 150, height: 150))
                        strongSelf.pickerViewBig = AVRoutePickerView.init(frame: rectBig)
                        strongSelf.pickerViewBig?.delegate = self
                        strongSelf.view.addSubview(strongSelf.pickerViewBig!)
                    }
                }
            }
        }
    }
    
    func removeObserver() {
        avplayer?.removeTimeObserver(updateUIObserver!)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayerItem )
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: avPlayerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVRouteDetectorMultipleRoutesDetectedDidChange, object: nil)
    }
    
    func getDuration() -> TimeInterval {
        guard let avplayer = avplayer else {
            return 0
        }
        return CMTimeGetSeconds((avplayer.currentItem?.duration)!)
    }
    
    func updateProgress(_ progress: CMTime) {
        
        let ratio = Float(CMTimeGetSeconds(progress)/getDuration())
        if isSeeking == false {
            seekBar.value = ratio
        }
    }
    
    func addObserver(_ player: AVPlayer, _ playerItem: AVPlayerItem ) {
        
        updateUIObserver = avplayer?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (time) in
            if let strongSelf = self {
                strongSelf .updateProgress(time)
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(failedToPlayToEnd), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self , selector: #selector(routeDetectChange), name: NSNotification.Name.AVRouteDetectorMultipleRoutesDetectedDidChange, object: nil)
    }
    
    @IBAction func playAudio(_ sender: Any) {
        avplayer?.play()
    }
    
    @IBAction func pauseAudio(_ sender: Any) {
        avplayer?.pause()
    }
    
    @IBAction func onDragExit(_ sender: Any) {
        doSetProgress(Float64(seekBar.value))
        isSeeking = false
    }
    
    @IBAction func onDragEnter(_ sender: Any) {
        isSeeking = true
    }
    
    func updateCurrentProgress(_ progress: Float) {
        if isSeeking == false {
            seekBar.value = progress
        }
    }
    
    func doSetProgress(_ progress: TimeInterval) {
        let newProgress: TimeInterval = progress * getDuration()
        avplayer?.seek(to: CMTimeMakeWithSeconds(floor(newProgress), Int32(NSEC_PER_SEC)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { [weak self] (isFinish) in
            if isFinish {
                if let strongSelf = self {
                    strongSelf.avplayer?.play()
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    final private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback,
                                         mode: AVAudioSessionModeDefault,
                                         routeSharingPolicy: .longForm )
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    final private func setupAVPlayer() {
        // avplayer
        avPlayerItem = AVPlayerItem(url: URL(string: sampleFilePath!)!)
        avplayer = AVPlayer(playerItem: avPlayerItem)
        
        avplayer?.volume = 1.0
        avplayer?.rate = 1.0
        // avaudioplayer
        addObserver(avplayer!, avPlayerItem!)
        avplayer?.play()
    }
    
    final func setupRouteDetector() {
        routeDetector.isRouteDetectionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupAudioSession()
        setupAVPlayer()
        setupRouteDetector()
        routeDetectChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func playbackToEnd() {
        finishPlayback()
    }
    
    @objc func failedToPlayToEnd() {
        let alert = UIAlertController.init(title: "Fail to play to end", message: "something wrong", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "ok", style: .default) { [weak self] (UIAlertAction) in
            if let strongSelf = self {
                strongSelf.finishPlayback()
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func finishPlayback() {
        self.navigationController?.popViewController(animated: true)
    }
}
