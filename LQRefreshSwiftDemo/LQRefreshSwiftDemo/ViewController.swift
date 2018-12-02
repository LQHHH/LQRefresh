//
//  ViewController.swift
//  LQRefreshSwiftDemo
//
//  Created by hhh on 2018/11/28.
//  Copyright © 2018 LQ. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    var cellNum = 5;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = UINavigationController.init(rootViewController: self)
        let window = UIApplication.shared.delegate?.window
        window!?.rootViewController = nav
        
        self.navigationItem.title = "测试刷新"
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init()
        
        //闭包的形式实现
        /*
        tableView.lq_header = LQRefreshHeader.headerWithRefreshBlock {
            //模拟数据加载
            DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: { [weak self] in
                self?.tableView.lq_header?.endRefresh()
                self?.cellNum = Int(arc4random() % 6) + 1
                self?.tableView.reloadData()
            })
        }
        */
        
       //taget-action模式实现
       tableView.lq_header = LQRefreshHeader.headerWithRefreshTarget(self, action: #selector(refreshData))
        return tableView
    }()
    
    @objc func refreshData() {
        //模拟数据加载
        DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: { [weak self] in
            self?.tableView.lq_header?.endRefresh()
            self?.cellNum = Int(arc4random() % 6) + 1
            self?.tableView.reloadData()
        })
    }

}

//MARK:- 实现代理和数据源方法
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellID)
        }
        cell?.textLabel?.text = String(indexPath.row)
        cell?.backgroundColor = UIColor.orange
        cell?.selectionStyle = .none
        return cell!
    }
}
