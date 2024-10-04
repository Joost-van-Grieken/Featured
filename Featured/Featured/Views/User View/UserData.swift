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
        
        case watchedState
        case watchedCount
        case savedState
        case rated
    }
    
    //MARK: - Watched
    
    func setWatchedState(value: Bool, movieId: Int) {
        set(value, forKey: "\(UserDefaultsKeys.watchedState.rawValue)_\(movieId)")
    }
    
    func getWatchedState(movieId: Int) -> Bool {
        return bool(forKey: "\(UserDefaultsKeys.watchedState.rawValue)_\(movieId)")
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
    
    func setWatchedMovieCount(value: Bool, movieId: Int) {
        let watchedStateKey = "\(UserDefaultsKeys.watchedState.rawValue)_\(movieId)"
        let currentWatchedState = bool(forKey: watchedStateKey)

        if currentWatchedState != value {
            set(value, forKey: watchedStateKey)
            var count = watchedMovieCount

            if value {
                count += 1
            } else {
                count -= 1
            }
            count = max(count, 0)

            watchedMovieCount = count
        }
    }
    
    func getWatchedMovieCount() -> Int {
        return integer(forKey: UserDefaultsKeys.watchedCount.rawValue)
    }
    
    //MARK: - Saved
    
    func setSavedState(value: Bool, movieId: Int) {
        set(value, forKey: "\(UserDefaultsKeys.savedState.rawValue)_\(movieId)")
    }
    
    func getSavedState(movieId: Int) -> Bool {
        return bool(forKey: "\(UserDefaultsKeys.savedState.rawValue)_\(movieId)")
    }
    
    //MARK: - Rated
    
    func setRatedState(value: Double, movieId: Int) {
        set(value, forKey: UserDefaultsKeys.rated.rawValue)
    }

    func getRatedState(movieId: Int) -> Double {
        return double(forKey: UserDefaultsKeys.rated.rawValue)
    }
}

class UserSettings: ObservableObject {
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "login")
        }
    }
    
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    @Published var rating: [Int: Int] {
        didSet {
            UserDefaults.standard.set(rating, forKey: "rating")
        }
    }
    
    @Published var watchedMovieIDs: [Int] {
        didSet {
            UserDefaults.standard.set(watchedMovieIDs, forKey: "watchedMovieIDs")
        }
    }
    
    @Published var savedMovieIDs: [Int] {
        didSet {
            UserDefaults.standard.set(savedMovieIDs, forKey: "savedMovieIDs")
        }
    }
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "login")
        self.username = UserDefaults.standard.string(forKey: "username") ?? "user123"
        self.rating = UserDefaults.standard.dictionary(forKey: "rating") as? [Int: Int] ?? [:]
        self.watchedMovieIDs = UserDefaults.standard.array(forKey: "watchedMovieIDs") as? [Int] ?? []
        self.savedMovieIDs = UserDefaults.standard.array(forKey: "savedMovieIDs") as? [Int] ?? []
    }
    
    func setRating(value: Int, movieID: Int) {
        rating[movieID] = value
    }

    func getRating(movieID: Int) -> Int? {
        return rating[movieID]
    }
    
    func addMovieID(movieID: Int) {
        if !watchedMovieIDs.contains(movieID) {
            watchedMovieIDs.append(movieID)
        }
    }
    
    func removeMovieID(movieID: Int) {
        if let index = watchedMovieIDs.firstIndex(of: movieID) {
            watchedMovieIDs.remove(at: index)
        }
    }
    
    func saveMovieID(movieID: Int) {
        if !savedMovieIDs.contains(movieID) {
            savedMovieIDs.append(movieID)
        }
    }
    
    func unSaveMovieID(movieID: Int) {
        if let index = savedMovieIDs.firstIndex(of: movieID) {
            savedMovieIDs.remove(at: index)
        }
    }
}
