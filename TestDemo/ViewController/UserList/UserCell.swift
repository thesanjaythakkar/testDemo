//
//  UserCell.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 04/03/21.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet var imgProfile: UIImageView!
    {
        didSet {
            imgProfile.layer.cornerRadius = 55 / 2
        }
    }
    @IBOutlet var vwImageContainer: UIView!
    {
        didSet {
            vwImageContainer.layer.cornerRadius = 65 / 2
        }
    }
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDetails: UILabel!
    @IBOutlet var btnNote: UIButton!

    var user: Users!
    {
        didSet {
            self.backgroundColor = UIColor { [self] options in

                switch options.userInterfaceStyle
                {
                case .dark:
                    return user.seens ? UIColor.darkGray : UIColor.black
                case .light:
                    return user.seens ? UIColor.tertiarySystemGroupedBackground : UIColor.white
                default:
                    return UIColor.white
                }
            }
            imgProfile.loadImageUsingCache(isInverted: isInverted, withUrl: user.avatar_url ?? "")
            lblName.text = user.login
            if let company = user.company, company.count > 0
            {
                lblDetails.text = company
                lblDetails.isHidden = false
            }
            else
            {
                lblDetails.isHidden = true
            }
            btnNote.isHidden = user.note == nil || user.note == ""
        }
    }
    var isInverted: Bool = false
    {
        didSet {
            vwImageContainer.backgroundColor = UIColor { options in

                switch options.userInterfaceStyle
                {
                case .dark:
                    return UIColor.gray
                case .light:
                    return UIColor.lightGray
                default:
                    return UIColor.brown
                }

            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageUsingCache(isInverted: Bool = false, withUrl urlString: String) {
        let url = URL(string: urlString)
        self.image = nil

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    self.image = image
                    if isInverted
                    {
                        self.invertImage()
                    }
                    imageCache.setObject(self.image!, forKey: urlString as NSString)
                }
            }

        }).resume()
    }
    func invertImage()
    {
        if let filter = CIFilter(name: "CIColorInvert") {
            let coreImage = CIImage(image: self.image!)
            filter.setValue(coreImage, forKey: kCIInputImageKey)
            if let output = filter.outputImage
            {
                let newImage = UIImage(ciImage: output)
                self.image = newImage
            }
        }
    }

}
