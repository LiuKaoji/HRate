import Foundation
import UIKit

class PlayListHeader: UIView {
    static var selectedIndex = 0
    private var titleLabel: UILabel!
    private var fileCountLabel: UILabel!
    private var descriptionLabel: UILabel!
    public var segmentedControl: UISegmentedControl!
    var searchButton: UIButton!
    private var searchBarTopConstraint: Constraint?
    var searchBar: UISearchBar!

    func configure(fileCount: Int) {
        fileCountLabel.text = "(\(fileCount))"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        // Segmented control
        segmentedControl = UISegmentedControl(items: ["已录制", "音频包"])
        segmentedControl.selectedSegmentIndex =  PlayListHeader.selectedIndex
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(30)
        }

        // File count label
        fileCountLabel = UILabel()
        fileCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        fileCountLabel.textColor = .white
        addSubview(fileCountLabel)
        fileCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
        }

        // Search button
        searchButton = UIButton(type: .system)
        searchButton.isHidden = true
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .white
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
        }

        // Search bar
        searchBar = UISearchBar()
        searchBar.placeholder = "搜索"
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.alpha = 0
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.backgroundColor = .clear
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle("取消", for: .normal)
        }
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            searchBarTopConstraint = make.top.equalTo(segmentedControl.snp.bottom).offset(10).constraint
            make.left.right.equalToSuperview().inset(10)
        }
    }

    @objc private func searchButtonTapped() {
        searchBar.alpha = 1
        searchBar.becomeFirstResponder()
        searchButton.isHidden = true
        segmentedControl.isHidden = true
        fileCountLabel.isHidden = true

        // Update searchBar top constraint for centering
        searchBarTopConstraint?.update(offset: (frame.height - searchBar.frame.height) / 2)
    }
}

extension PlayListHeader: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.alpha = 0
        searchBar.text = ""
        searchButton.isHidden = false
        segmentedControl.isHidden = false
        fileCountLabel.isHidden = false

        // Update searchBar top constraint back to original
        searchBarTopConstraint?.update(offset: 10)
    }
}
