//
//  CollectionViewBeginner.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-14.
//
import UIKit

class PhotoCell: UICollectionViewCell{
    static let identifier = "PhotoCell"
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        //full cell
        iv.contentMode = .scaleAspectFill
        //out of bounds -> remove
        iv.clipsToBounds = true
        //background color
        iv.backgroundColor = .systemGray6
        
        iv.layer.cornerRadius = 16
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //auto layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PhotoCollectionView: UIViewController{
    let colors: [UIColor] = (0..<100).map { _ in
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        //spacing row
        layout.minimumLineSpacing = 10
        //spacing column
        layout.minimumInteritemSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI(){
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension PhotoCollectionView: UICollectionViewDataSource{
    //How many items in 1 section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    //Cell for each
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        
        cell.imageView.backgroundColor = colors[indexPath.item]
        
        return cell
        
    }
}

extension PhotoCollectionView:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noColumns: CGFloat = 3
        
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalPaddings = layout.sectionInset.left + layout.sectionInset.right
        
        let totalSpacings = layout.minimumInteritemSpacing * (noColumns - 1)
        
        let width = floor((collectionView.bounds.width - totalPaddings - totalSpacings) / noColumns)
        
        
        return CGSize(width: width, height: width)
    }
}
