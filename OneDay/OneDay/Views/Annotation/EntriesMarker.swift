//
//  MyLocationMarker.swift
//  OneDay
//
//  Created by juhee on 17/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import MapKit

class EntryAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    var entry: Entry
    
    init(entry: Entry) {
        self.entry = entry
        self.title = entry.title
        guard let location = entry.location else { preconditionFailure() }
        self.locationName = location.address ?? ""
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

internal final class EntryAnnotationView: MKMarkerAnnotationView {
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
}

private extension EntryAnnotationView {
    func configure(with annotation: MKAnnotation) {
        guard annotation is EntryAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
        markerTintColor = UIColor.doBlue
        glyphImage = UIImage(named: "ic_diary")
    }
}

// MARK: Battle Rapper Cluster View
internal final class EntryAnnotationClusterView: MKAnnotationView {
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        centerOffset = CGPoint(x: 0.0, y: -10.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented.")
    }
}

private extension EntryAnnotationClusterView {
    func configure(with annotation: MKAnnotation) {
        guard let annotation = annotation as? MKClusterAnnotation else { return }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40.0, height: 40.0))
        let count = annotation.memberAnnotations.count
        image = renderer.image { _ in
            UIColor.doBlue.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)).fill()
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0)]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
        clusteringIdentifier = String(describing: EntryAnnotationClusterView.self)
    }
}
