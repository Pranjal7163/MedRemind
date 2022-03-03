//
//  ClosureSleeve.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 03/03/22.
//

import Foundation
import UIKit

class ClosureSleeve {
  let closure: () -> ()

  init(attachTo: AnyObject, closure: @escaping () -> ()) {
    self.closure = closure
    objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
  }

  @objc func invoke() {
    closure()
  }
}
