//
//  main.swift
//  zspec
//
//  Created by 张行 on 2017/8/31.
//  Copyright © 2017年 张行. All rights reserved.
//

import Foundation

let zspec = ZSpec()
if !zspec.canParse() {
    print(zspec.commandLineTool.printCommand())
}
