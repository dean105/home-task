//
//  RoomViewController.swift
//  CanvaTakeHome
//
//  Created by Dean Parreno on 16/12/16.
//  Copyright © 2016 Dean Parreno. All rights reserved.
//

import UIKit
import TakeHomeTask

class RoomViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var roomIds: [RoomId] = []
    var loadedStartingRoom = false
    var adjacentTile: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStartingRoom()
    }
    
    func loadStartingRoom() {
        MazeManager.sharedInstance.fetchStartRoom { (roomOrError) in
            do {
                let roomIdentifier = try roomOrError()
                print(roomIdentifier)
                self.loadRoomsRecursively(roomIdentifier: roomIdentifier)
            } catch {
                print(error)
            }
        }
    }
    
    func loadRoomsRecursively(roomIdentifier: RoomId) {
        MazeManager.sharedInstance.fetchRoom(roomId: roomIdentifier, callback: { (room) in
            do {
                let room = try room()
                if self.roomIds.isEmpty || !self.roomIds.contains(roomIdentifier) {
                    self.loadedStartingRoom = true
                    print(room.tileURL)
                    self.imageView!.downloadedFrom(url: room.tileURL)
                    //
                    self.adjacentTile?.downloadedFrom(url: room.tileURL)
                    self.adjacentTile?.frame = self.imageView.frame
                    self.view.addSubview(self.adjacentTile!)
                    self.view.addConstraint(NSLayoutConstraint(item: self.adjacentTile!, attribute: .bottom, relatedBy: .equal, toItem: self.imageView, attribute: .top, multiplier: 1.0, constant: 0.0))
                    
                    }
                    
                    
                    
                    // Adds roomID to array
                    self.roomIds.append(roomIdentifier)
                      
                    var adjacentRooms: [Connection] = []
                    if let room = room.connections[.north] { adjacentRooms.append(room) }
                    if let room = room.connections[.south] { adjacentRooms.append(room) }
                    if let room = room.connections[.east] { adjacentRooms.append(room) }
                    if let room = room.connections[.west] { adjacentRooms.append(room) }
                    
                    for adjacentRoom in adjacentRooms {
                        switch adjacentRoom {
                        case .Room(let adjacentRoomId):
                            self.loadRoomsRecursively(roomIdentifier: adjacentRoomId)
                        case .LockedRoom: break
                        }
                    }
                
            } catch {
                print(error)
            }
        })
    }
    
    func placeTile() {
        
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}