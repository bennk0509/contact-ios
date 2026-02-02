//
//  ViewController.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-25.
//

import UIKit

class ContactListViewController: UIViewController {
    
    private let viewModel: ContactViewModel
//    UI
    private let tableView = UITableView()
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Int, ContactModel>!
    
    init(viewModel: ContactViewModel = ContactViewModel(repository: ContactRepositoryImpl(service: ContactService.shared))) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        bindViewModel()
        
        Task {
            await viewModel.fetchIds()
        }
    }

    
    private func setupUI() {
        title = "Contacts"
        view.backgroundColor = .systemBackground
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: ContactCell.identifier)
        tableView.rowHeight = 70
        tableView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, ContactModel>(tableView: tableView) { tableView, indexPath, contact in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier, for: indexPath) as? ContactCell else {
                return UITableViewCell()
            }
            
            // Cell tự lo việc load ảnh thô từ Repository
            cell.configure(with: contact) { identifier in
                return await self.viewModel.fetchThumbnail(for: identifier)
            }
            return cell
        }
    }
    private func bindViewModel() {

        viewModel.onDataUpdated = { [weak self] in
            self?.updateSnapshot()
        }
        
        viewModel.onError = { [weak self] errorCode in
            guard let self = self else { return }
            
            switch errorCode {
            case "denied":
                self.showSettingsAlert(
                    title: "Access denied from User",
                    message: "Please allow to access contact from Settings"
                )
            case "restricted":
                self.showSimpleAlert(
                    title: "Limited Access",
                    message: "Please allow to access contact from Settings"
                )
            default:
                self.showSimpleAlert(title: "Lỗi", message: "Đã có lỗi xảy ra: \(errorCode)")
            }
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ContactModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.contacts)
        // Áp dụng dữ liệu mới. Diffable sẽ tự tính toán để chèn thêm hàng (Insert)
        // thay vì reload toàn bộ bảng, giúp hiệu năng cực mượt.
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ContactListViewController: UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Khi user scroll cách đáy 200 point, tự động load thêm batch tiếp theo
        if offsetY > (contentHeight - frameHeight - 200) {
            Task {
                await viewModel.loadNextPage()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedContact = viewModel.contacts[indexPath.row]
        print("Selected: \(selectedContact.name)")
    }
}


extension ContactListViewController {
    
    func showSettingsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
