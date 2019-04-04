// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0")
        GMSPlacesClient.provideAPIKey("AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0")
        //let firstTab = tabBar.viewControllers![0] as! UINavigationController
        //let mapViewController = firstTab.viewControllers.first as! MapController
        //let splitView: UISplitViewController = tabBar.viewControllers![1] as! UISplitViewController
        //splitView.delegate = self
        //splitView.preferredDisplayMode = .allVisible
        //let navController: UINavigationController = splitView.viewControllers.first as! UINavigationController
        //let animalDetailView: AnimalDetailController = splitView.viewControllers.last as! AnimalDetailController
        //let animalTable: AnimalTableViewController = navController.viewControllers.first as! AnimalTableViewController
        //animalTable.detailViewController = animalDetailView
        //animalTable.mapViewController = mapViewController
        return true
    }

}

