//
//  Task.swift
//  taskapp
//
//  Created by Tatsuya on 2016/02/20.
//  Copyright © 2016年 Tatsuya. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    //タイトル
    dynamic var title = ""
    
    //内容
    dynamic var contents = ""
    
    //カテゴリー
    dynamic var category = ""
    
    //日時
    dynamic var date = NSDate()
    
    /*
     id をプライマリーキーとして設定
     */
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
