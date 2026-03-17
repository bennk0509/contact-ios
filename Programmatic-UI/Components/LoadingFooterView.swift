//
//  LoadingFooterView.swift
//  Programmatic-UI
//

import UIKit

final class LoadingFooterView: UICollectionReusableView {
    static let identifier = "LoadingFooterView"

    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func start() { spinner.startAnimating() }
    func stop() { spinner.stopAnimating() }
}
