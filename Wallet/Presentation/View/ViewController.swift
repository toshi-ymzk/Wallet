//
//  ViewController.swift
//  Wallet
//
//  Created by Toshihiro Yamazaki on 2019/10/05.
//  Copyright © 2019 Toshihiro Yamazaki. All rights reserved.
//

import UIKit

enum WalletType: Int, CaseIterable {
    case a
    case b
    case c
    
    var title: String {
        switch self {
        case .a:
            return "Wallet A"
        case .b:
            return "Wallet B"
        case .c:
            return "Wallet C"
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    lazy var header: UIView = {
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        header.font = UIFont.boldSystemFont(ofSize: 16)
        header.textAlignment = .center
        header.text = "Select Wallet Type"
        if #available(iOS 13.0, *) {
            header.backgroundColor = .systemBackground
        } else {
            header.backgroundColor = .white
        }
        return header
    }()
    
    let cellID = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title = "Wallet"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WalletType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.selectionStyle = .none
        if let module = WalletType(rawValue: indexPath.row) {
            cell.textLabel?.text = module.title
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let module = WalletType(rawValue: indexPath.row) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: false)
        switch module {
        case .a:
            openWalletA()
        case .b:
            openWalletB()
        case .c:
            openWalletC()
        }
    }
}

extension ViewController {
    
    func openWalletA() {
        let vc = WalletViewControllerA()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func openWalletB() {
        let vc = WalletViewControllerB()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func openWalletC() {
        let vc = WalletViewControllerC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
