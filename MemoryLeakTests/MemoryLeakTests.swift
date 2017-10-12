//
//  MemoryLeakTests.swift
//  MemoryLeakTests
//
//  Created by Ronaldo II Dorado on 12/10/17.
//  Copyright © 2017 Ronaldo II Dorado. All rights reserved.
//

import XCTest
@testable import MemoryLeak

class MemoryLeakTests: XCTestCase {
    
    var customViewController: CustomViewController?
    override func setUp() {
        super.setUp()
        customViewController = CustomViewController()
    }
    
    
    func testExample() {
        LeakTestHelper<CustomViewController>.prepareTest(viewController: &self.customViewController,
                                                         properties: [(self.customViewController?.person)!,
                                                                      (self.customViewController?.apartment)!])
    }
}

class LeakTestHelper<T>{
    class func prepareTest(viewController: inout T?, properties: [AnyObject] = []) {
        weak var weakViewController:UIViewController? = (viewController as! UIViewController)
        let viewControllerName = String(describing: type(of: viewController))
        let weakRefArray = NSPointerArray.weakObjects()
        
        for property in properties {
            let pointer = Unmanaged.passUnretained(property).toOpaque()
            weakRefArray.addPointer(pointer)
        }
        
        let v = UINavigationController(rootViewController: UIViewController())
        let _ = v.view
        v.pushViewController((viewController as! UIViewController), animated: false)
        let _ = (viewController as! UIViewController).view
        (viewController as! UIViewController).navigationController?.popViewController(animated: false)
        viewController = nil

        
        DispatchQueue.main.async {
            if let _ = weakViewController {
                print("  ERROR: \(viewControllerName) did not get deallocated.")
            }
            
            weakRefArray.compact()
            if weakRefArray.count > 0 {
                for index in 0..<weakRefArray.count {
                    if let leakingObject = weakRefArray.object(at: index) {
                        print("  ERROR: property leak in class: \(viewControllerName)   propertyName: \(leakingObject))")
                    }
                }
            }
        }
    }
}

class WeakRef<T> where T: AnyObject {

    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}

extension NSPointerArray {
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    func insertObject(_ object: AnyObject?, at index: Int) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }
    
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int) {
        guard index < count else { return }
        
        removePointer(at: index)
    }
}


