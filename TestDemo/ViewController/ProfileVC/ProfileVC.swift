//
//  ProfileVC.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 05/03/21.
//

import UIKit
import CoreData
class ProfileVC: UIViewController {
    
    @IBOutlet var imgAvatar:UIImageView!
    @IBOutlet var lblFollowing:UILabel!
    @IBOutlet var lblFollowers:UILabel!
    @IBOutlet var lblBlog:UILabel!
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblCompany:UILabel!
    @IBOutlet var txtNote:UITextView!
    @IBOutlet var scrollView:UIScrollView!
    
    
    
    var user:Users!
    var context:NSManagedObjectContext!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // Do any additional setup after loading the view.
    }
    func setupView()
    {
        user.seens = true
        try! context.save()
        self.title = user.login
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imgAvatar.loadImageUsingCache(withUrl: user.avatar_url!)
        if let blog = user.blog, blog.count > 0
        {
            lblBlog.text = blog
        }
        else{
            lblBlog.text = "N/A"
        }
        if let name = user.name, name.count > 0
        {
            lblName.text = name
        }
        else{
            lblName.text = "N/A"
        }
        if let company = user.company, company.count > 0
        {
            lblCompany.text = company
        }
        else{
            lblCompany.text = "N/A"
        }
        lblFollowing.text = "Following: \(user.following)"
        lblFollowers.text = "Followers: \(user.followers)"
        txtNote.text = user.note ?? ""
    }
    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    @IBAction func tappedOnSave(_ sender:UIButton?)
    {
        user.note = txtNote.text!
        try! context.save()
        if let value = txtNote.text, value.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
        {
            let alert = UIAlertController.init(title: "Congrats!!", message: "Notes Saved Successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController.init(title: "Notes are empty", message: "Please enter some notes", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ProfileVC:UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
