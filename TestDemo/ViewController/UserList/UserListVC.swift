//
//  ViewController.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 04/03/21.
//

import UIKit
import CoreData

class UserListVC: UITableViewController {

    //MARK:- Outlets
    @IBOutlet var btnNetwork:UIBarButtonItem!

    //MARK:- Variables
   
    var dataProvider: DataProvider = DataProvider(persistentContainer: CoreDataStack.shared.persistentContainer, repository: APIManager.shared)

    lazy var fetchedResultsController: NSFetchedResultsController<Users> = {
        let fetchRequest = NSFetchRequest<Users>(entityName: "Users")
        if isFiltering
        {
            fetchRequest.predicate = NSPredicate(format: "login CONTAINS %@", searchString ?? "")
        }
        else
        {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        }
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataProvider.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self

        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return controller
    }()

    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandies: [Users] = []
    var searchString: String?
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        let searchBarScopeIsFiltering =
            searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive &&
            (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }


    let loadingView = UIView()

    let spinner = UIActivityIndicatorView()

    let loadingLabel = UILabel()


    //MARK:- View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

       


        // Do any additional setup after loading the view.
    }
    func setupViews()
    {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        
        NetworkManager.shared.startMonitoring { (isReachable) in
            DispatchQueue.main.async {
                if !isReachable
                {
                    self.navigationItem.rightBarButtonItem = self.btnNetwork
                }
                else{
                    if self.fetchedResultsController.sections?[0].numberOfObjects == 0
                    {
                        self.setLoadingScreen()
                        self.dataProvider.fetchUsers(fromId: 0) { (err) in
                            DispatchQueue.main.async {
                            self.removeLoadingScreen()
                            }
                        }
                    }
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK:- Table Datasource & Delegates

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredCandies.count : fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        if isFiltering
        {
            cell.user = filteredCandies[indexPath.row]
        }
        else
        {
            cell.user = (fetchedResultsController.sections?[0].objects as! [Users])[indexPath.row]
        }
        cell.isInverted = (indexPath.row + 1) % 4 == 0
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if !isFiltering
        {

            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
                print("this is the last cell")

                dataProvider.fetchUsers(fromId: Int(((fetchedResultsController.sections![0].objects as! [Users])[lastRowIndex].id))) { (err) in
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView?.isHidden = true
                    }
                }


                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = isFiltering ? filteredCandies[indexPath.row] : (fetchedResultsController.sections![0].objects as! [Users])[indexPath.row]
        setLoadingScreen()
        dataProvider.fetchUserDetails(userName: user.login!) { (err) in
            DispatchQueue.main.async {
                self.removeLoadingScreen()
                if let err = err
                {
                    print(err)
                }
                else
                {
                    let provided = self.dataProvider.getUser(id: Int(user.id))
                    self.performSegue(withIdentifier: "showProfile", sender: provided)
                }

            }

        }
    }
    //MARK:- Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile"
        {
            let controller = segue.destination as! ProfileVC
            controller.user = sender as? Users
            controller.context = dataProvider.viewContext
        }
    }
    //MARK:- Filter
    func filterContentForSearchText(searchString: String)
    {
        let filter = fetchedResultsController.sections![0].objects as! [Users]
        filteredCandies = filter.filter { (obj) -> Bool in
            return obj.login!.lowercased().contains(searchString.lowercased())
        }
        tableView.reloadData()
    }

    //MARK:- Loading
    private func setLoadingScreen() {

        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        loadingLabel.textColor = .black
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        spinner.style = .medium
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        tableView.addSubview(loadingView)
    }

    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {

        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true

    }


}

extension UserListVC: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.tableView.tableFooterView?.isHidden = true
        tableView.reloadData()
    }
}

extension UserListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchString: searchBar.text!)
    }
}
