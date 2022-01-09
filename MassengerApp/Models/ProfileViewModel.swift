//
//  ProfileViewModel.swift
//  MassengerApp
//
//  Created by Amaal almutairi on 07/01/2022.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
