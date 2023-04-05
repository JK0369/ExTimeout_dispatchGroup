//
//  ViewController.swift
//  ExTimeout
//
//  Created by 김종권 on 2023/04/05.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getResult()
    }
    
    func task1(completion: (Int) -> ()) {
        print("start task1", Thread.current)
        sleep(3)
        print("end task1", Thread.current)
        completion(1)
    }
    
    func task2(completion: (Int) -> ()) {
        print("start task2", Thread.current)
        sleep(5)
        print("end task2", Thread.current)
        completion(2)
    }
    
    func getResult() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "my_task")
        
        let tasks = [task1, task2]
        var results = [Int]()
        
        for (i, task) in tasks.enumerated() {
            print("queue.async's out thread:", Thread.current) // <_NSMainThread: 0x60000325c880>{number = 1, name = main}
            group.enter()
            queue.async {
                print("queue.async's in thread:", Thread.current) // <NSThread: 0x60000325a980>{number = 4, name = (null)}
                task { result in
                    results.append(result)
                    group.leave()
                }
            }
            
            switch group.wait(timeout: .now() + .seconds(30)) {
            case .success:
                print("작업이 성공")
                continue
            case .timedOut:
                print("작업이 타임아웃 되었습니다.")
                return
            }
        }
        
        print("group.notify")
        group.notify(queue: queue) {
            print("result>", results, Thread.current)
        }
    }
}
