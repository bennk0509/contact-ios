//
//  FPSCounter.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet Nguyen on 2026-01-28.
//


import UIKit


class FPSCounter {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: TimeInterval = 0
    private var count: Int = 0
    
    private let fpsLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.textColor
        = .green
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.frame = CGRect(x: 20, y: 50, width: 60, height: 25)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        return label
    }()
    
    func start() {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            window.addSubview(fpsLabel)
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick(link:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func tick(link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        
        count += 1
        let delta = link.timestamp - lastTimestamp
        
        if delta >= 1 {
            let fps = Double(count) / delta
            fpsLabel.text = "\(Int(fps)) FPS"
            
            fpsLabel.textColor = fps < 55 ? .red : .green
            
            lastTimestamp = link.timestamp
            count = 0
        }
    }
}
