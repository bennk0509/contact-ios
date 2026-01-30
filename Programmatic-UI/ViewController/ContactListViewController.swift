//
//  ViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-25.
//

import UIKit

class ContactListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let service = ContactService.shared
    private let fpsCounter = FPSCounter()
    
    private var sectionTitles: [String] = []
    
    private var groupedContacts: [String:[ContactModel]] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadData()
        
    }
    
    deinit{
        print("KILL Contact List ViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fpsCounter.start()
    }
    
    func loadData(){
        service.fetchAllContacts{[weak self] (grouped, title , error) in
            guard let self = self else {return}
            if let error = error {
                print("Fetch error: \(error.localizedDescription)")
                return
            }
            self.groupedContacts = grouped
            self.sectionTitles = title
            
            self.tableView.reloadData()
            
//            if let contacts = contacts {
//                // Thằng call back này lại giữ ViewController. thằng viewcontroller lại giữ hàm này. STRONG REFERENCE CYCLE
//                // Phải làm sao? PHẢI CHỊU. [weak self]
//                
//                let groupedDictionary = Dictionary(grouping: contacts) { model in
//                    let firstChar = model.name.prefix(1).uppercased()
//                    return firstChar.rangeOfCharacter(from: .letters) != nil ? firstChar : "#"
//                }
//                
//                self.groupedContacts = groupedDictionary.mapValues { contacts in
//                    contacts.sorted { $0.name < $1.name }
//                }
//                
//                self.sectionTitles = self.groupedContacts.keys.sorted { (a, b) -> Bool in
//                    if a == "#" { return false }
//                    if b == "#" { return true  }
//                    return a < b
//                }
//                
//                self.tableView.reloadData()
//            }
        }
    }
    
    func setupUI(){
        title = "Contact"
        view.backgroundColor = .white

        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Top Table = Top View and so on for bottom, left, right
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self

//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        tableView.rowHeight = 56
        tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    }
}

extension ContactListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionTitles[section]
        return groupedContacts[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let key = sectionTitles[indexPath.section]
        if let contactsInSection = groupedContacts[key] {
            let contact = contactsInSection[indexPath.row]
            cell.configure(with: contact)
        }
        return cell
    }
    
    
}

extension ContactListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let key = sectionTitles[indexPath.section]
        guard let contact = groupedContacts[key]?[indexPath.row] else { return }

        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .systemGray6
        detailVC.title = contact.name

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ContactListViewController{
    func createAvatarImage(initial: String, color: UIColor) -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // 1. Vẽ hình tròn màu
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))

            // 2. Vẽ chữ cái đầu
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.white
            ]

            let stringSize = initial.size(withAttributes: attributes)
            let rect = CGRect(
                x: (size.width - stringSize.width) / 2,
                y: (size.height - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            )

            initial.draw(in: rect, withAttributes: attributes)
        }
    }
}

