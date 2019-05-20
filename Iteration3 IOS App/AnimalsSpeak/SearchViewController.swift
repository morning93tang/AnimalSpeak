//
//  SearchViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 8/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Delegate for sent back a animal list for search resut.
protocol searchListDelegate {
    func gerResultData(selctedanimalList: [animal]) }

/// View controller for displaying search bar and search result list
class SearchViewController: UIViewController {
    

    fileprivate let reuseCellIdentifier = "reuseCellIdentifier"
    var animalList = [animal]()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var filteredAnimalList = [animal]()
    var selctedanimalList = [animal]()
    @IBOutlet weak var tableView: UITableView!
    var delegate : searchListDelegate?
    @IBAction func search(_ sender: Any) {
        if delegate != nil {
            delegate?.gerResultData(selctedanimalList: self.selctedanimalList)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// Initialize the view with default data by dispalying all animals.
    override func viewDidLoad() {
        let translator = ROGoogleTranslate()
        translator.sendRequestToServer(methodId: 3,request: ["lat":"asf","lon":"sdafsadf"]){ (result) in
            if result != nil{
                if let list = result!["response"] as? String{
                    print(list)
                    if let data = list.data(using: .utf8) {
                        if let json = try? JSON(data: data) {

                            for anis in json.arrayValue {
                                print(anis["name"])
                                
                                let name = anis["name"].stringValue
                                if anis["className"].stringValue == "Mammalia"{
                                    let ani = animal(name: name, element: .Mammal)
                                    self.animalList.append(ani)
                                }
                                if anis["className"].stringValue == "Aves"{
                                    let ani = animal(name: name, element: .Birds)
                                    self.animalList.append(ani)
                                }
                                if anis["className"].stringValue == "Reptilia"{
                                    let ani = animal(name: name, element: .Reptile)
                                    self.animalList.append(ani)
                                }

                            }
                        }
                }
                    print(self.animalList)
                    self.configureSearchController()
                    super.viewDidLoad()
            }
        }
            

        
    }
    }
    
    
    /// Updating the layout of current screen
    private func addConstraints(){
        
        NSLayoutConstraint(item: tableView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: topLayoutGuide,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        
        NSLayoutConstraint(item: tableView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: view,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: tableView,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: view,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: tableView,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 0).isActive = true
        
    }
    
    /// Configure the search bar with the filer
    func configureSearchController() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.setValue("Cancel", forKey: "cancelButtonText")
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Mammal", "Birds","Reptile"]
        searchController.searchBar.delegate = self
    }
    
    /// Filter the search result base on the user selection
    ///
    /// - Parameter searchBar: Current search bar instance
    func filterSearchController(_ searchBar: UISearchBar) {
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        let selectedElement = animal.Element(rawValue: scopeString) ?? .All
        let searchText = searchBar.text ?? ""
        
        // filter pokemonList by element and text
        filteredAnimalList = animalList.filter { anima in
            let isElementMatching = (selectedElement == .All) || (anima.element == selectedElement)
            let isMatchingSearchText = anima.name.lowercased().contains(searchText.lowercased()) || searchText.lowercased().characters.count == 0
            return isElementMatching && isMatchingSearchText
            
        }
        tableView.reloadData()
    }
    
}


// MARK: - <#UITableViewDelegate#>
// Display the serach result in the table view.
extension SearchViewController : UITableViewDelegate{
    /// Allow user to select a table cell, and tick the cell after selection
    ///
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell!.isSelected
        {
            cell!.isSelected = false
            if cell!.accessoryType == UITableViewCell.AccessoryType.none
            {
                if self.searchController.isActive{
                    if selctedanimalList.index(of:self.filteredAnimalList[indexPath.row]) != nil {
                       UITableViewCell.AccessoryType.none
                    }else{
                        selctedanimalList.append(self.filteredAnimalList[indexPath.row])
                        cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
                        print(selctedanimalList)
                    }
                }else{
                    if selctedanimalList.index(of:self.animalList[indexPath.row]) != nil {
                        UITableViewCell.AccessoryType.none
                    }else{
                        selctedanimalList.append(self.animalList[indexPath.row])
                        cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
                        print(selctedanimalList)
                    }
                }
            }
            else
            {
                cell!.accessoryType = UITableViewCell.AccessoryType.none
                if let index = selctedanimalList.index(of:self.animalList[indexPath.row]) {
                    selctedanimalList.remove(at: index)
                    print(selctedanimalList)
                }
            }
        }
    }
    
    /// Define the height of sections(0)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if self.searchController.isActive {
//
//            return 44
//
//        }
//        else {
           return 0
//        }
 }
}

// MARK: - UITableViewDataSource
// Push data to table view.
extension SearchViewController : UITableViewDataSource {
    
    
    /// Define the number of sections in table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredAnimalList.count : animalList.count
        
    }

    
    /// Initialize cells in table view
    ///
    /// - Parameters:
    ///   - tableView: current instance of table view
    ///   - indexPath: index of the cell
    /// - Returns: table cell to be shown
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath)
        let ani = searchController.isActive ? filteredAnimalList[indexPath.row] : animalList[indexPath.row]
        cell.textLabel!.text = ani.name
        cell.detailTextLabel?.text = ani.element.rawValue
        if selctedanimalList.index(of:ani) != nil{
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }else{
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        return cell
    }
    
}

// MARK: - UISearchResultsUpdating
// Updating the search result
extension SearchViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchController.searchBar)
    }
    
}

// MARK: - UISearchBarDelegate
// Initialize the search bar.
extension SearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar)
    }
    
   func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
    }
}


