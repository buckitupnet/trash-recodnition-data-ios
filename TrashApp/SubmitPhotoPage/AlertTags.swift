//
//  AlertTags.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 04.07.2022.
//

import Foundation
import UIKit

class AlertTags: UIView {
    private lazy var backgraundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.opacity = 0.4
        return view
    }()

    private lazy var alertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5.0
        return view 
    }()

    private lazy var title: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please choose a tag:"
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    private lazy var cancelButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        button.backgroundColor = Constants.greenColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        button.layer.cornerRadius = 3
        return button
    }()

    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TagTableViewCell", bundle: nil), forCellReuseIdentifier: "TagTableViewCell")
        tableView.indicatorStyle = .black
        return tableView
    }()

    var cancelHandler: (() -> Void)?
    var chooseTagHandler: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension AlertTags: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell") as? TagTableViewCell else { return UITableViewCell() }
        cell.configure(text: Constants.tags[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chooseTagHandler = chooseTagHandler else { return }
        chooseTagHandler(Constants.tags[indexPath.row])
    }
}

private extension AlertTags {
    func setupConstrains() {
        addSubview(backgraundView)
        addSubview(alertView)
        alertView.addSubview(title)
        alertView.addSubview(tableView)
        alertView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            backgraundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgraundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgraundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgraundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            alertView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30),
            alertView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30),
            alertView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            alertView.heightAnchor.constraint(equalToConstant: 288),

            title.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 15),
            title.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -15),
            title.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 25),

            tableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15),
            tableView.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -15),
            tableView.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 15),

            cancelButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -16),
            cancelButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: alertView.centerXAnchor)
        ])
    }

    @objc func cancelAction(sender: UIButton!) {
        guard let cancel = cancelHandler else { return }
        cancel()
    }
}
