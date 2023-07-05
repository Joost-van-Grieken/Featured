//
//  UserData.swift
//  Featured
//
//  Created by Joost van Grieken on 26/05/2023.
//

// MARK: Hantert de data van de gebruiker

import Foundation
import Combine

extension UserDefaults: ObservableObject {
    
    enum UserDefaultsKeys: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        
        case isLoggedIn
        case userID
        case watchedState
        case watchedCount
        case totalWatchedMinutes
        case savedState
        case rated
    }
    
    //MARK: - Check Login
    
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func getLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: - Save User Data
    
    func setUserID(value: Int) {
        set(value, forKey: UserDefaultsKeys.userID.rawValue)
    }
    
    //MARK: - Retrieve User Data
    
    func getUserID() -> Int {
        return integer(forKey: UserDefaultsKeys.userID.rawValue)
    }
    
    //MARK: - Watched
    
    func setWatchedState(value: Bool, id: Int) {
        set(value, forKey: "\(UserDefaultsKeys.watchedState.rawValue)_\(id)")
    }
    
    func getWatchedState(id: Int) -> Bool {
        return bool(forKey: "\(UserDefaultsKeys.watchedState.rawValue)_\(id)")
    }
    
    //MARK: - Duration
    
    var totalWatchedMinutes: Int {
        get {
            return integer(forKey: UserDefaultsKeys.totalWatchedMinutes.rawValue)
        }
        set {
            set(newValue, forKey: UserDefaultsKeys.totalWatchedMinutes.rawValue)
        }
    }
    
    var totalWatchedMinutesInMinutes: Int {
        return totalWatchedMinutes % 60
    }
    
    //MARK: - Movie Count
    
    var watchedMovieCount: Int {
        get {
            return integer(forKey: UserDefaultsKeys.watchedCount.rawValue)
        }
        set {
            set(newValue, forKey: UserDefaultsKeys.watchedCount.rawValue)
        }
    }
    
    func setWatchedMovieCount(value: Bool, id: Int, durationText: String? = nil) {
        let watchedStateKey = "\(UserDefaultsKeys.watchedState.rawValue)_\(id)"
        let currentWatchedState = bool(forKey: watchedStateKey)
        
        if currentWatchedState != value {
            set(value, forKey: watchedStateKey)
            var count = watchedMovieCount
            
            if value {
                count += 1
                if let durationText = durationText {
                    let movieDuration = extractDurationInMinutes(from: durationText)
                    totalWatchedMinutes += movieDuration
                }
            } else {
                count -= 1
                if let durationText = durationText {
                    let movieDuration = extractDurationInMinutes(from: durationText)
                    totalWatchedMinutes -= movieDuration
                }
            }
            count = max(count, 0)
            
            watchedMovieCount = count
        }
    }
    
    private func extractDurationInMinutes(from durationText: String) -> Int {
        let components = durationText.components(separatedBy: " ")
        if let minutesString = components.first, let minutes = Int(minutesString) {
            return minutes
        }
        return 0
    }
    
    func getWatchedMovieCount() -> Int {
        return integer(forKey: UserDefaultsKeys.watchedCount.rawValue)
    }
    
    //MARK: - Saved
    
    func setSavedState(value: Bool, forMovieId movieId: Int) {
        set(value, forKey: "\(UserDefaultsKeys.savedState.rawValue)_\(movieId)")
    }
    
    func getSavedState(forMovieId movieId: Int) -> Bool {
        return bool(forKey: "\(UserDefaultsKeys.savedState.rawValue)_\(movieId)")
    }
    
    //MARK: - Rated
    
    func setRatedState(value: Double) {
        set(value, forKey: UserDefaultsKeys.rated.rawValue)
    }
    
    func getRatedState() -> Double {
        return double(forKey: UserDefaultsKeys.rated.rawValue)
    }
}
