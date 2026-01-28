//
//  ViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-25.
//

import UIKit

class ContactListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let service = ContactService()
    private let fpsCounter = FPSCounter()
    
    private var sectionTitles: [String] = []
    
    private var groupedContacts: [String:[ContactModel]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadData()
        
        fpsCounter.start()
    }
    
    func loadData(){
        service.fetchAllContacts{[weak self] (contacts, error) in
            guard let self = self else {return}
            if let error = error {
                print("Fetch error: \(error.localizedDescription)")
                return
            }
            
            if let contacts = contacts {
                // Thằng call back này lại giữ ViewController. thằng viewcontroller lại giữ hàm này. STRONG REFERENCE CYCLE
                // Phải làm sao? PHẢI CHỊU. [weak self]
                
                let groupedDictionary = Dictionary(grouping: contacts) { model in
                    let firstChar = model.name.prefix(1).uppercased()
                    return firstChar.rangeOfCharacter(from: .letters) != nil ? firstChar : "#"
                }
                
                self.groupedContacts = groupedDictionary.mapValues { contacts in
                    contacts.sorted { $0.name < $1.name }
                }
                
                self.sectionTitles = self.groupedContacts.keys.sorted { (a, b) -> Bool in
                    if a == "#" { return false }
                    if b == "#" { return true  }
                    return a < b
                }
                
                self.tableView.reloadData()
            }
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
//        let key = sectionTitles[indexPath.section]
//        if let contactsInSection = groupedContacts[key] {
//            let contact = contactsInSection[indexPath.row]
//            cell.textLabel?.text = contact.name
//            
//            
//            if let image = contact.avatar{
//                cell.imageView?.image = image
//                cell.imageView?.layer.cornerRadius = 22
//                cell.imageView?.clipsToBounds = true
//            } else {
//                cell.imageView?.image = createAvatarImage(initial: contact.initial, color: contact.color)
//            }
//            
//        }
        
        return cell
    }
    
    
}

extension ContactListViewController: UITableViewDelegate{
    
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


//
//    //create tableView object
//    let tableView = UITableView()
//        
//    private var sectionTitles: [String] = []
//    private var groupedContacts: [String: [ContactModel]] = [:]
//    
//    private let contactService = ContactService()
//    
//    private var displayLink: CADisplayLink?
//    private var lastTimestamp: TimeInterval = 0
//    private let fpsLabel = UILabel()
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        setupTableView()
//        setupFPSCounter()
//        loadData()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
//        displayLink?.add(to: .main, forMode: .common)
//    }
//    
//    @objc func updateFPS(link: CADisplayLink) {
//        if lastTimestamp == 0 {
//            lastTimestamp = link.timestamp
//            return
//        }
//        
//        let delta = link.timestamp - lastTimestamp
//        let fps = 1 / delta
//        lastTimestamp = link.timestamp
//        
////        fpsLabel.text = "FPS: \(Int(round(fps)))"
//        
//        fpsLabel.text = "\(round(fps)"
//        
//        fpsLabel.textColor = fps > 55 ? .systemGreen : .systemRed
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        displayLink?.invalidate()
//        displayLink = nil
//    }
//    
//    func setupFPSCounter() {
//        fpsLabel.frame = CGRect(x: 20, y: 500, width: 80, height: 25)
//        fpsLabel.backgroundColor = .black.withAlphaComponent(0.7)
//        fpsLabel.textColor = .white
//        fpsLabel.textAlignment = .center
//        fpsLabel.font = .systemFont(ofSize: 12, weight: .bold)
//        fpsLabel.layer.cornerRadius = 5
//        fpsLabel.clipsToBounds = true
//        
//        view.addSubview(fpsLabel)
//        view.bringSubviewToFront(fpsLabel)
//    }
//
//    
//    func loadData() {
//        contactService.fetchMockContacts { [weak self] fetchedContacts in
//        guard let self = self else { return }
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let grouped = Dictionary(grouping: fetchedContacts) { $0.initial }
//            let titles = grouped.keys.sorted()
//                
//            DispatchQueue.main.async {
//                self.groupedContacts = grouped
//                self.sectionTitles = titles
//                self.tableView.reloadData()
//            }
//        }
//        }
//    }
//    
//    func setupUI(){
//        title = "Contact"
//        view.backgroundColor = .white
//        
//        view.addSubview(tableView)
//        
//        tableView.frame = view.bounds
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            // Top Table = Top View and so on for bottom, left, right
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    func setupTableView(){
//        tableView.dataSource = self
//        tableView.delegate = self
//        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
//    }
//
//}
//
////What we will show
//extension ContactListViewController: UITableViewDataSource{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sectionTitles.count
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let key = sectionTitles[section]
//        return groupedContacts[key]?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section]
//    }
//    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return sectionTitles
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
//
//        let key = sectionTitles[indexPath.section]
//        guard let contact = groupedContacts[key]?[indexPath.row] else { return cell }
//        
//        var content = cell.defaultContentConfiguration()
//        content.text = contact.name
//        
//        if let avatarData = contact.avatar {
//            content.image = makeCircularImage(from: avatarData, size: CGSize(width: 40, height: 40))
//        } else {
//            content.image = createAvatarImage(initial: contact.initial, color: contact.color)
//        }
//        
//        cell.contentConfiguration = content
//        cell.accessoryType = .disclosureIndicator
//        
//        return cell
//    }
//    
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return contacts.count
////    }
////    
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
////        let contact = contacts[indexPath.row]
////        // Sử dụng UIListContentConfiguration (Cái "Ruột" hiện đại)
////        var content = cell.defaultContentConfiguration()
////        content.text = contact.name
////        
////        
////        if let avatarData = contact.avatar {
////            content.image = avatarData
////        } else {
////            content.image = createAvatarImage(initial: contact.initial, color: contact.color)
////        }
////        content.imageProperties.cornerRadius = 20
////        
////        // Áp dụng cấu hình vào cell
////        cell.contentConfiguration = content
////        cell.accessoryType = .disclosureIndicator
////        
////        return cell
////    }
//}
//
//extension ContactListViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let key = sectionTitles[indexPath.section]
//        guard let contact = groupedContacts[key]?[indexPath.row] else { return }
//        
//        let detailVC = UIViewController()
//        detailVC.view.backgroundColor = .systemGray6
//        detailVC.title = contact.name // Lấy từ contact đã chọn
//        
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        // Bỏ chọn dòng sau khi bấm (cho đẹp UI)
////        tableView.deselectRow(at: indexPath, animated: true)
////        
////        // Chuyển sang màn hình mới
////        let detailVC = UIViewController()
////        detailVC.view.backgroundColor = .systemGray6
////        detailVC.title =  contacts[indexPath.row].name
////        
////        navigationController?.pushViewController(detailVC, animated: true)
////    }
//}
//
//extension ContactListViewController {
//    func createAvatarImage(initial: String, color: UIColor) -> UIImage? {
//        let size = CGSize(width: 40, height: 40)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        
//        return renderer.image { context in
//            // 1. Vẽ hình tròn màu
//            color.setFill()
//            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
//            
//            // 2. Vẽ chữ cái đầu
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
//                .foregroundColor: UIColor.white
//            ]
//            
//            let stringSize = initial.size(withAttributes: attributes)
//            let rect = CGRect(
//                x: (size.width - stringSize.width) / 2,
//                y: (size.height - stringSize.height) / 2,
//                width: stringSize.width,
//                height: stringSize.height
//            )
//            
//            initial.draw(in: rect, withAttributes: attributes)
//        }
//    }
//    
//    func makeCircularImage(from image: UIImage, size: CGSize) -> UIImage{
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { context in
//            let rect = CGRect(origin: .zero, size: size)
//            
//            UIBezierPath(ovalIn: rect).addClip()
//            
//            let imgSize = image.size
//            let ratio = max(size.width / imgSize.width, size.height / imgSize.height)
//            let newSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
//            let origin = CGPoint(x: (size.width - newSize.width) / 2, y: (size.height - newSize.height) / 2)
//            
//            image.draw(in: CGRect(origin: origin, size: newSize))
//        }
//    }
//}

