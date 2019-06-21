//
//  MusicTableViewController.swift
//  FitTrack
//  Reference: https://stackoverflow.com/questions/43385292/get-all-the-songs-from-music-library-ios-swift-3-xcode-8-2-1
//  Created by Ash  on 19/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//
import UIKit
import MediaPlayer
import AVFoundation


class MusicTableViewController: UITableViewController {
    
    var albums: [AlbumInfo] = []
    var songQuery: SongQuery = SongQuery()
    var audio: AVAudioPlayer?
    var playing:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Songs"
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.albums = self.songQuery.get(songCategory: "")
                DispatchQueue.main.async {
                    self.tableView?.rowHeight = 111
                    self.tableView?.reloadData()
                }
            } else {
                self.displayMediaLibraryError()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func displayMediaLibraryError() {
        
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        present(controller, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return albums.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums[section].songs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "musicCell",
            for: indexPath) as! MusicTableViewCell
        cell.musicTitle?.text = albums[indexPath.section].songs[indexPath.row].songTitle
        cell.musicDescription?.text = albums[indexPath.section].songs[indexPath.row].artistName
        let songId: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        let item: MPMediaItem = songQuery.getItem( songId: songId )
        
        if  let imageSound: MPMediaItemArtwork = item.value( forProperty: MPMediaItemPropertyArtwork ) as? MPMediaItemArtwork {
            cell.musicImage?.image = imageSound.image(at: CGSize(width: cell.musicImage.frame.size.width, height: cell.musicImage.frame.size.height))
        }
        return cell;
    }
   


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let songId: NSNumber = albums[indexPath.section].songs[indexPath.row].songId
        let item: MPMediaItem = songQuery.getItem( songId: songId )
        let url: NSURL = item.value( forProperty: MPMediaItemPropertyAssetURL ) as! NSURL
        do {
            audio = try AVAudioPlayer(contentsOf: url as URL)
            guard let player = audio else { return }
            
            if !self.playing {
                player.prepareToPlay()
                player.play()
                self.playing = true
            }
            else {
                player.stop()
                self.playing = false
            }
         
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}
