//
//  MainViewController.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import UIKit
import MBProgressHUD

class MainViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource,
UISearchBarDelegate, MainTableCellDelegate , RequestsGenericDelegate , ReachabilityDelegate{
   
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var currentList:[MainModel] = [MainModel]()
    

    var workPlansList = [MainModel]()
    var loadingNotif:MBProgressHUD! = nil
    
    var isNetworkAvailable:Bool = true
    var reachabilityManager:ReachabilityManager?


    var userId:Int?
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad \(self.userId)")
        tableView.rowHeight = UITableViewAutomaticDimension
        setupSearchBar()
        
        reachabilityManager = ReachabilityManager(delegate: self)

//        if #available(iOS 10, *){
//            self.tableView.refreshControl = refreshControl
//        }
//        else{
//            self.tableView.addSubview(refreshControl)
//        }
       // refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
        
        self.navigationController?.isNavigationBarHidden = false

        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
   //     self.navigationController?.setViewControllers([self], animated: true)

        
    }
    
    
    func setupSearchBar(){
        searchBar.searchBarStyle = .prominent
        searchBar.isTranslucent = false
        searchBar.barTintColor = UIColor(rgb: 0xededed, alphaVal: 1.0)
        searchBar.backgroundColor = UIColor(rgb: 0xededed, alphaVal: 1.0)
        searchBar.backgroundImage = UIImage()
        
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("viewDidAppear")
        
        self.navigationController?.isNavigationBarHidden = false
        
         reachabilityManager?.startMonitoring()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardUp(notification :)), name:  NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDown(notification :)), name:  NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.tintColor  = UIColor.clear
        self.navigationItem.leftBarButtonItem?.width = 0.01
        
        getList()
    }
    
    //MARK: ActionMethods
    
    @IBAction func didLogoutButtonTap(_ sender: Any) {
        
    }
    
    //MARK: List loading functions
    
    @objc private func refreshList(_ sender: Any) {
        getList()
    }
    
    func getList(){
        
        showLoading()
        
        workPlansList = [MainModel]()
        currentList = [MainModel]()
        Request.getWorkPlans(delegate: self)
    }
    
    //MARK: Table cell delegate functions
    
    func runForward(atIndexPath indexPath:IndexPath){
       // performSegue(withIdentifier: Constants.segueMainToCircuitIdentifier, sender: nil)
        
        if(!self.isNetworkAvailable)
        {
            showNetworkErrorDialog()
            return
        }
        
        self.searchBar.resignFirstResponder()
        
        if let workplan:MainModel = currentList[indexPath.row]
        {
            let WPID = workplan.id
            print("runForward WPId \(WPID)")
            
            performSegue(withIdentifier: Constants.segueMainToCircuitIdentifier, sender: WPID)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.segueMainToCircuitIdentifier)
        {
            
            let circuitVC = segue.destination as! CircuitViewController
            circuitVC.WPId = sender as! Int
            
        }
    }
    
    func updateCell(atIndexPath indexPath: IndexPath) {
        var listIndex = 0
        for (index, main) in currentList.enumerated(){
            print("titles: \(main.title) -- \(currentList[indexPath.row].title)")
            if main.title == currentList[indexPath.row].title {
                listIndex = index
                break
            }
        }
        currentList[listIndex].isShowingDescription = !currentList[listIndex].isShowingDescription
        currentList[indexPath.row] = currentList[listIndex]
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
    //MARK: Table delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.mainTableCellIdentifier, for: indexPath) as! MainTableViewCell
        
        if indexPath.row == 0 {
            cell.cellTopConstraint.constant = 0
        }
        else{
            cell.cellTopConstraint.constant = 5
        }
        
        cell.mainView.layer.shadowColor = UIColor.gray.cgColor
        cell.mainView.layer.shadowOpacity = 0.2
        cell.mainView.layer.shadowRadius = 2.0
        cell.mainView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.mainView.masksToBounds = false
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.titleLabel.text = self.currentList[indexPath.row].title!
        cell.startTimeLabel.text = "Starts: " + self.currentList[indexPath.row].startDate!
        cell.endTimeLabel.text = "Ends: " + self.currentList[indexPath.row].endDate!
        cell.locationLabel.text = self.currentList[indexPath.row].location!
        cell.descriptionTextLabel.text = self.currentList[indexPath.row].description!
        
        
        if(currentList[indexPath.row].isShowingDescription)
        {
            cell.showDescription()
            if(indexPath.row == currentList.count-1)
            {
                print("LAST INDEX")
               // scrollToBottom()
            }
        }
        else
        {
            cell.hideDescription()
        }
        
        return cell
    }
    
    //MARK: Search delegate functions
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
//        guard !searchBar.text!.isEmpty else {
//            currentList = workPlansList
//            tableView.reloadData()
//            return
//        }
//        currentList = workPlansList.filter({ mainModel -> Bool in
//            let result:Bool = mainModel.title.lowercased().contains(searchBar.text!.lowercased())
//            return mainModel.title.lowercased().contains(searchBar.text!.lowercased())
//        })
//        if currentList.count > 0{
//            currentList.sort { (workplan1, workplan2) -> Bool in
//                return workplan1.title.lowercased()<workplan2.title.lowercased()
//            }
//        }
//        else{
//            showErrorDialog(withMessage: Constants.noWorkplansFound)
//        }
//        tableView.reloadData();
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard !searchText.isEmpty else {
//            currentList = workPlansList
//            tableView.reloadData()
//            return
//        }
        
        
        guard !searchBar.text!.isEmpty else {
            currentList = workPlansList
            tableView.reloadData()
            return
        }
        currentList = workPlansList.filter({ mainModel -> Bool in
            let result:Bool = mainModel.title.lowercased().contains(searchBar.text!.lowercased())
            return mainModel.title.lowercased().contains(searchBar.text!.lowercased())
        })
        if currentList.count > 0{
            currentList.sort { (workplan1, workplan2) -> Bool in
                return workplan1.title.lowercased()<workplan2.title.lowercased()
            }
        }
        else{
            showErrorDialog(withMessage: Constants.noWorkplansFound)
        }
        tableView.reloadData();
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: Dialogs
    
    func showErrorDialog(withMessage message:String){
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: Constants.ok, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Keyboard functions
    
    @objc func dismissKeyboard() -> Bool {
        searchBar.resignFirstResponder()
        return false
    }
    
    @objc func keyBoardUp(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewBottomConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyBoardDown(notification: NSNotification){
        tableViewBottomConstraint.constant = 0
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }
    

    func onErrorResponse(msg: String) {
    }
    
    
    func onSuccessResponse(data: Any)
    {
        
        let dataArray = data as! [[String : Any]]
        print("data array count is \(dataArray.count)")
        
        for workPlan in dataArray
        {
            let id = workPlan["Id"]
            let title = workPlan["Title"]
            let Location = workPlan["Location"]
            let startDate = workPlan["StartDate"]
            let endDate = workPlan["EndDate"]
            let desc = workPlan["Description"]
            
            let workPlanModel = MainModel(id: id as! Int, title: title as! String, location: Location as! String, startDate: startDate as! String, enddate: endDate as! String, desc: desc as! String)
            
            workPlansList.append(workPlanModel)
        }
        
        currentList = workPlansList
        
        if(currentList.count == 0)
        {
            print("\(Constants.TAG) NO PLANS FOUND")
            
            DispatchQueue.main.sync
            {
                showErrorDialog(withMessage: Constants.noWorkplansFound)

            }
        }
        
        DispatchQueue.main.sync {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            loadingNotif.hide(animated: true)
        }
        
        
    }
    
    func showLoading(){
        loadingNotif = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotif.mode = MBProgressHUDMode.indeterminate
        loadingNotif.label.text = "Loading"
    }

    func scrollToBottom()
    {
        let indexPath = IndexPath(row: workPlansList.count-1 , section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func showNetworkErrorDialog()
    {
        let alert = UIAlertController(title:"Network not available.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    func networkAvailable()
    {
        isNetworkAvailable = true
    }
    
    func networkNotAvailable()
    {
        isNetworkAvailable = false
    }
    
    
    @IBAction func logout_button_clicked(_ sender: Any)
    {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logout = UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            
            
            self.navigationController?.popViewController(animated: true)
            guard let vcList = self.navigationController?.viewControllers else{
                print("&&&&")
                return
            }

            print("Logout pressed \(vcList.count)")
//
//            for controller in vcList
//            {
//                if controller is LoginViewController
//                {
//                    print("LoginViewController")
//                }
//            }
            
//            if vcList[vcList.count - 2] is LoginViewController {
//                self.navigationController?.popToViewController(vcList[vcList.count - 2], animated: true)
//            }
            
            })
        
        actionSheet.addAction(logout)
        present(actionSheet , animated: true , completion: nil)
    }
    
}














