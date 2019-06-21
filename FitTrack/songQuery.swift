//
//  songQuery.swift
//  FitTrack
//  Reference: https://stackoverflow.com/questions/43385292/get-all-the-songs-from-music-library-ios-swift-3-xcode-8-2-1
//  Created by Ash  on 19/6/19.
//  Copyright © 2019 Thev. All rights reserved.
//

import Foundation

import MediaPlayer

struct SongInfo {
    
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    
    
    var songId   :  NSNumber
}

struct AlbumInfo {
    
    var albumTitle: String
    var songs: [SongInfo]
}

class SongQuery {
    
    func get(songCategory: String) -> [AlbumInfo] {
        
        var albums: [AlbumInfo] = []
        let albumsQuery: MPMediaQuery
        if songCategory == "Artist" {
            albumsQuery = MPMediaQuery.artists()
            
        } else if songCategory == "Album" {
            albumsQuery = MPMediaQuery.albums()
            
        } else {
            albumsQuery = MPMediaQuery.albums()
        }
        
        
        // let albumsQuery: MPMediaQuery = MPMediaQuery.albums()
        let albumItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
        //  var album: MPMediaItemCollection
        
        for album in albumItems {
            
            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            // var song: MPMediaItem
            
            var songs: [SongInfo] = []
            
            var albumTitle: String = ""
            
            for song in albumItems {
                if songCategory == "Artist" {
                    albumTitle = song.value( forProperty: MPMediaItemPropertyArtist ) as! String
                    
                } else if songCategory == "Album" {
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                    
                    
                } else {
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                }
                
                let songInfo: SongInfo = SongInfo(
                    albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String,
                    artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as? String ?? "" ,
                    songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                    songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber
                )
                songs.append( songInfo )
            }
            
            let albumInfo: AlbumInfo = AlbumInfo(
                
                albumTitle: albumTitle,
                songs: songs
            )
            
            albums.append( albumInfo )
        }
        
        return albums
        
    }
    
    func getItem( songId: NSNumber ) -> MPMediaItem {
        
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: songId, forProperty: MPMediaItemPropertyPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        var items: [MPMediaItem] = query.items! as [MPMediaItem]
        
        return items[items.count - 1]
        
    }
    
}
