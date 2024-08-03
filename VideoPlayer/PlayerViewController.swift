//
//  PlayerViewController.swift
//  VideoPlayer
//
//  Created by Praful Mahajan on 25/05/20.
//  Copyright © 2020 prafulmahajan. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var playbackControlsViewHeightContraint: NSLayoutConstraint!

    //MARK: Private Properties
    private var playerLayer: AVPlayerLayer?
    private var player: AVQueuePlayer?
    private var playerItems: [AVPlayerItem]?

    //MARK: Internal Properties
    public var isMuted = true {
        didSet {
            self.player?.isMuted = self.isMuted
            self.volumeButton.isSelected = self.isMuted
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeVideo()
    }

    func initializeVideo() {
        let videoFilePath = Bundle.main.path(forResource: "Earth", ofType: "mp4")
        let url1 = URL(fileURLWithPath: videoFilePath!)

        self.loadVideos(with: [url1])
        self.isMuted = false
        self.playVideo()
    }

    public func loadVideos(with urls: [URL]) {
        guard !urls.isEmpty else {
            print("🚫 URLs not available.")
            return
        }

        guard let player = self.player(with: urls) else {
            print("🚫 AVPlayer not created.")
            return
        }
        self.player = player
        player.rate = 1
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = self.videoView.frame
        playerViewController.showsPlaybackControls = false
        addChild(playerViewController)
        self.videoView.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        //let playerLayer = self.playerLayer(with: player)
        //self.videoView.layer.insertSublayer(playerLayer, at: 0)
    }

    public func playVideo() {
        self.player?.play()
        self.playPauseButton.isSelected = true
    }

    public func pauseVideo() {
        self.player?.pause()
        self.playPauseButton.isSelected = false
    }

    //MARK: Button Action Methods
    @IBAction private func onTapPlayPauseVideoButton(_ sender: UIButton) {
        if sender.isSelected {
            self.pauseVideo()
        } else {
            self.playVideo()
        }
    }

    @IBAction private func onTapExpandVideoButton(_ sender: UIButton) {
        self.pauseVideo()
    }

    @IBAction private func onTapVolumeButton(_ sender: UIButton) {
        self.isMuted = !sender.isSelected
    }

    @IBAction private func onTapRewindButton(_ sender: UIButton) {
        if let currentTime = self.player?.currentTime() {
            var newTime = CMTimeGetSeconds(currentTime) - 10
            if newTime <= 0 {
                newTime = 0
            }
            self.player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }

    @IBAction private func onTapForwardButton(_ sender: UIButton) {
        if let currentTime = self.player?.currentTime(), let duration = self.player?.currentItem?.duration {
            var newTime = CMTimeGetSeconds(currentTime) + 10
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            self.player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //self.playerLayer?.frame = self.videoView.bounds
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.player?.pause()
    }

}

// MARK: - Private Methods
private extension PlayerViewController {
    func player(with urls: [URL]) -> AVQueuePlayer? {
        var playerItems = [AVPlayerItem]()

        urls.forEach { (url) in
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            playerItems.append(playerItem)
        }

        guard !playerItems.isEmpty else {
            return nil
        }

        let player = AVQueuePlayer(items: playerItems)
        self.playerItems = playerItems
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            if let duration = player.currentItem?.duration {

                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)

                DispatchQueue.main.async {
                    self?.progressBar.progress = progress
                    if progress >= 1.0 {
                        self?.progressBar.progress = 0.0
                    }
                }
            }
        }
        return player
    }

    func playerLayer(with player: AVQueuePlayer) -> AVPlayerLayer {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        playerLayer.contentsGravity = .resizeAspect
        self.playerLayer = playerLayer
        return playerLayer
    }
}
