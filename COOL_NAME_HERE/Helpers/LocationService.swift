////
////  LocationService.swift
////  COOL_NAME_HERE
////
////  Created by Hayden Davidson on 6/14/21.
////
//
//import Foundation
//import Combine
//import MapKit
//
//class LocationService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
//
//    enum LocationStatus: Equatable {
//        case idle
//        case noResults
//        case isSearching
//        case error(String)
//        case result
//    }
//
//    @Published var queryFragment: String = ""
//    @Published private(set) var status: LocationStatus = .idle
//    @Published private(set) var searchResults: [MKLocalSearchCompletion] = []
//
//    private var queryCancellable: AnyCancellable?
//    private let searchCompleter: MKLocalSearchCompleter!
//
//    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
//        self.searchCompleter = searchCompleter
//        super.init()
//        self.searchCompleter.delegate = self
//
//        queryCancellable = $queryFragment
//            .receive(on: DispatchQueue.main)
//            // we're debouncing the search, because the search completer is rate limited.
//            // feel free to play with the proper value here
//            .debounce(for: .milliseconds(250), scheduler: RunLoop.main, options: nil)
//            .sink(receiveValue: { fragment in
//                self.status = .isSearching
//                if !fragment.isEmpty {
//                    self.searchCompleter.queryFragment = fragment
//                } else {
//                    self.status = .idle
//                    self.searchResults = []
//                }
//        })
//    }
//}
//
//
//
