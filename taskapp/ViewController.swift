//
//  ViewController.swift
//  taskapp
//
//  Created by Tatsuya on 2016/02/20.
//  Copyright © 2016年 Tatsuya. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    

    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト
    // 日付の近い順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    let taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    var filterTitle = try! Realm().objects(Task)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        let backButtonItem = UIBarButtonItem(title: "戻る", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem

        // テーブルのヘッダーに表示する
        tableView.tableHeaderView = searchBar
        
    }

    // 検索中のみ判定
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.view.endEditing(true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let predicate = NSPredicate(format: "category = %@", searchBar.text!)
        filterTitle = try! Realm().objects(Task).filter(predicate)
        
        self.tableView.reloadData()
//        print(filterTitle)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数(=セルの数)を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            return filterTitle.count
        } else {
            return taskArray.count
        }
    }

    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            
            // Cellに値を設定する
            let task = filterTitle[indexPath.row]
            cell.textLabel?.text = task.title
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.stringFromDate(task.date)
            cell.detailTextLabel?.text = dateString

        } else {
            // Cellに値を設定する
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = task.title
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.stringFromDate(task.date)
            cell.detailTextLabel?.text = dateString

        }
        
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        performSegueWithIdentifier("cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete;
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
                if (notification.userInfo!["id"] as! Int == task.id) {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
    }
    
    // segue で画面遷移する際に呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        
        if segue.identifier == "cellSegue" {
            
            // searchBarが入力状態か(.active = true / false)
            if ((self.searchDisplayController?.active) != false) {
                
                let indexPath = searchDisplayController?.searchResultsTableView.indexPathForSelectedRow
                inputViewController.task = filterTitle[indexPath!.row]
            
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray[indexPath!.row]
                
            }
            
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

