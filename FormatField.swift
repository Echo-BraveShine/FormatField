//
//  FormatField.swift
//  DuoDuo
//
//  Created by Hong Zhang on 2019/4/16.
//  Copyright © 2019 Muqiu. All rights reserved.
//

import UIKit

class FormatField: UITextField {
    //保存上一次的文本内容
    var _previousText : String!
    
    //保持上一次的文本范围
    var _previousRange : UITextRange!
    
    //最大输入范围
    @IBInspectable var maxLength : Int = 11
    
    //分隔符  ps只能单个字符
    @IBInspectable var separator : String = " "
    
    private var  separatorChar : String {
        get{
            return String(self.separator.first ?? " ")
        }
    }
    
    
    /// 去除分隔符后的真实字符串
    var realText : String{
        get{
            return (self.text?.replacingOccurrences(of: separatorChar, with: ""))!
        }
    }
    
    //组长度
    @IBInspectable var section : Int = 4
    
  
    
    //当本视图的父类视图改变的时候
    override func willMove(toSuperview newSuperview: UIView?) {
        //监听值改变通知事件
        if newSuperview != nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(phoneNumberFormat(_:)),
                                                   name: UITextField.textDidChangeNotification,
                                                   object: nil)
        }else{
            NotificationCenter.default.removeObserver(self,
                                                      name: UITextField.textDidChangeNotification,
                                                      object: nil)
        }
    }
    
    //输入框内容改变时对其内容做格式化处理
    @objc func phoneNumberFormat(_ notification: Notification) {
        let textField = notification.object as! UITextField
        
        if(!textField.isEqual(self)){
            return
        }
        
        //当前光标的位置（后面会对其做修改）
        var cursorPostion = textField.offset(from: textField.beginningOfDocument,
                                             to: textField.selectedTextRange!.start)
        
        //过滤掉分割字符，只保留数字
        let digitsText = getDigitsText(string: textField.text!,
                                       cursorPosition: &cursorPostion)
        
        //避免超过11位的输入
        if digitsText.count > maxLength {
            textField.text = _previousText
            textField.selectedTextRange = _previousRange
            return
        }
        
        //得到带有分隔符的字符串
        let hyphenText = getHyphenText(string: digitsText, cursorPosition: &cursorPostion)
        
        //将最终带有分隔符的字符串显示到textField上
        textField.text = hyphenText
        
        //让光标停留在正确位置
        let targetPostion = textField.position(from: textField.beginningOfDocument,
                                               offset: cursorPostion)!
        textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                          to: targetPostion)
        
        //现在的值和选中范围，供下一次输入使用
        _previousText = self.text!
        _previousRange = self.selectedTextRange!
    }
    
    //除去分割字符，同时确定光标正确位置
    func getDigitsText(string:String, cursorPosition:inout Int) -> String{
        //保存开始时光标的位置
        let originalCursorPosition = cursorPosition
        //处理后的结果字符串
        var result = ""
        
        //遍历每一个字符
        for (index,value) in string.enumerated() {
            //如果是数字则添加到返回结果中
            if String(value) != separatorChar {
                result.append(value)
            }
                //非数字则跳过，如果这个非法字符在光标位置之前，则光标需要向前移动
            else{
                if index < originalCursorPosition {
                    cursorPosition = cursorPosition - 1
                }
            }
        }
        
        return result
    }
    
    //将分隔符插入现在的string中，同时确定光标正确位置
    func getHyphenText(string:String, cursorPosition:inout Int) -> String {
        //保存开始时光标的位置
        let originalCursorPosition = cursorPosition
        //处理后的结果字符串
        var result = ""
        
        //遍历每一个字符
        for (index,value) in string.enumerated()  {
            //先添加个分隔符
            if  index != 0 && index%section == 0 {
                result.append(separatorChar)
                //如果添加分隔符位置在光标前面，光标则需向后移动一位
                if index < originalCursorPosition {
                    cursorPosition = cursorPosition + 1
                }
            }
            result.append(String(value))
        }
        
        return result
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
}
