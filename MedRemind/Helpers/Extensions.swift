//
//  Extensions.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 03/03/22.
//

import Foundation
import UIKit

var imageCache = NSCache<AnyObject, AnyObject>()

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    var month: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.string(from: self)
    }
}


extension UIImageView {

    func loadImage(urlString: String) {
        
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Couldn't download image: ", error)
                return
            }
            
            guard let data = data else { return }
            let image = UIImage(data: data)
            imageCache.setObject(image!, forKey: urlString as AnyObject)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()

    }
}

extension UIControl {
    func setOnClickListener(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}
