//
//  AppDelegate.swift
//  Scoper
//
//  Created by soxjke on 04/07/2018.
//  Copyright (c) 2018 soxjke. All rights reserved.
//

import UIKit
import Scoper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.'
        let scope = DefaultScope.Builder()
            .name("Root test scope")
            .testCase(
                TestCase.Builder()
                    .name("8Mb Memory Consumption, 5s wait")
                    .worker { context, completion in
                        let memory = UnsafeMutablePointer<UInt64>.allocate(capacity: 1024 * 1024)
                        memory.initialize(to: 42, count: 1024 * 1024)
                        Thread.sleep(forTimeInterval: 5)
                        memory.deinitialize(count: 1024 * 1024)
                        memory.deallocate(capacity: 1024 * 1024)
                        completion()
                    }
                    .async()
                    .build()
            )
            .testCase(
                TestCase.Builder()
                    .name("Single core CPU load for 4s")
                    .worker { context, completion in
                        let queue = DispatchQueue(label: "workerQueue")
                        queue.async {
                            let startInterval = Date()
                            while Date().timeIntervalSince(startInterval) < 4 {}
                        }
                        Thread.sleep(forTimeInterval: 4)
                        completion()
                    }
                    .async()
                    .build()
            )
            .nestedScope(
                Scope.Builder()
                .name("First nested scope")
                .testCase(
                    TestCase.Builder()
                        .name("Test case of first nested scope")
                        .worker { context, completion in
                            Thread.sleep(forTimeInterval: 1)
                            completion()
                        }
                        .async()
                        .build()
                )
                .nestedScope(
                    Scope.Builder()
                    .name("Second nested scope")
                    .testCase(
                        TestCase.Builder()
                            .name("Test case of second nested scope")
                            .worker { context, completion in
                                Thread.sleep(forTimeInterval: 2)
                                completion()
                            }
                            .async()
                            .build()
                    )
                    .build()
                )
                .build()
            )
            .options(.complete)
            .build()
        
        TestRunner.shared.schedule(scope) { scopeResult in
            print(scopeResult)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
