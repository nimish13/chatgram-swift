//
//  DateFormatter.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 22/02/21.
//

import Foundation

protocol FormattedDate {
    func displayDate(for floatedTime: Double) -> String
}

extension FormattedDate {
    func displayDate(for floatedTime: Double) -> String {
        let date = Date(timeIntervalSince1970: floatedTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short //Set time style
        dateFormatter.dateStyle = .medium //Set date style
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}
