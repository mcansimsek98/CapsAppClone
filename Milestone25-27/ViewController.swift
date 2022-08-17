//
//  ViewController.swift
//  Milestone25-27
//
//  Created by Mehmet Can Şimşek on 17.08.2022.
//

import UIKit

enum Position {
    case top
    case bottom
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var topCaptionButton: UIButton!
    @IBOutlet var bottomCaptionButton: UIButton!
    
    var image: UIImage?
    var topCaption: String?
    var bottomCaption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButton))
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    
        
        updateButtonsState(enable: false)
    }
    
    func updateButtonsState(enable: Bool) {
          topCaptionButton.isEnabled = enable
          bottomCaptionButton.isEnabled = enable
          navigationItem.rightBarButtonItem?.isEnabled = enable
      }
    
    
    
    @objc func selectImage() {
        let picer = UIImagePickerController()
        picer.delegate = self
        picer.sourceType = .photoLibrary
        present(picer, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.dismiss(animated: true)
        imageView.image = image
        self.image = image
        topCaption = nil
        bottomCaption = nil
        
        updateButtonsState(enable: true)
    }

    @objc func share() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else { return }
                
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
        
    }
    @objc func refreshButton() {
        imageView.image = UIImage(named: "select.jpeg")
        updateButtonsState(enable: false)
    }
    
    
    @IBAction func topCaption(_ sender: Any) {
        showAlert(for: .top)
    }
    @IBAction func bottomCaption(_ sender: Any) {
        showAlert(for: .bottom)
    }
    
    
    
    func showAlert(for position: Position) {
        var title = ""
        if position == .top { title = "Top Caption"}
        else if position == .bottom { title = "Bottom Caption"}
        
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] action in
            guard let text = ac?.textFields?[0].text else { return }
            
            if position == .top {
                self?.topCaption = text
            }else if position == .bottom {
                self?.bottomCaption = text
            }
            self?.addCaption()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func addCaption() {
        guard let image = image else { return }

        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let renderedImage = renderer.image { [weak self] ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            if let topCaption = self?.topCaption {
                textFunc(text: topCaption, position: .top, rendererSize: image.size)
            }else if let bottomCaption = self?.bottomCaption {
                textFunc(text: bottomCaption, position: .bottom, rendererSize: image.size)
            }
        }
        imageView.image = renderedImage
    }
    
    func textFunc(text: String, position: Position, rendererSize: CGSize) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let lenght = rendererSize.width + rendererSize.height
        let font = lenght / 25
        
        let attrs: [NSAttributedString.Key : Any] = [
            .strokeWidth: -2.0,
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue", size: font)!,
            .paragraphStyle: paragraphStyle
        ]
        
        
        let margin = 32
        let textWidth = Int(rendererSize.width) - (margin * 2)
        let textHeight = heightFunc(text: text, attributes: attrs, width: textWidth)
        
        var startY: Int
        
        switch position {
        case .top:
            startY = margin
        case .bottom:
            startY = Int(rendererSize.height) - (textHeight + margin)
        }
        
        text.draw(with: CGRect(x: margin, y: startY, width: textWidth, height: textHeight), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    func heightFunc(text: String, attributes: [NSAttributedString.Key : Any], width: Int) -> Int {
        let text = NSString(string: text)
        let size = CGSize(width: CGFloat(width), height: .greatestFiniteMagnitude)
        let textRect = text.boundingRect(with: size, options: .usesLineFragmentOrigin,attributes: attributes, context: nil)
        return Int(textRect.size.height)
    }
    
}


