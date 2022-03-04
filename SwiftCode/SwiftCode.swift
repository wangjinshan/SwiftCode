//
//  SwiftCode.swift
//  OCMasoryDemo
//
//  Created by 王金山 on 2022/3/4.
//

import UIKit

// MARK: - propertyWrapper 知识点
// @propertyWrapper
/// 先告诉编译器 下面这个UserDefault是一个属性包裹器
@propertyWrapper struct UserDefault<T> {
    ///这里的属性key 和 defaultValue 还有init方法都是实际业务中的业务代码
    ///我们不需要过多关注
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    ///  wrappedValue是@propertyWrapper必须要实现的属性
    /// 当操作我们要包裹的属性时  其具体set get方法实际上走的都是wrappedValue 的set get 方法。
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

///封装一个UserDefault配置文件
struct UserDefaultsConfig {
    ///告诉编译器 我要包裹的是hadShownGuideView这个值。
    ///实际写法就是在UserDefault包裹器的初始化方法前加了个@
    /// hadShownGuideView 属性的一些key和默认值已经在 UserDefault包裹器的构造方法中实现
    @UserDefault("had_shown_guide_view", defaultValue: false) static var hadShownGuideView: Bool
    ///保存用户名称
    @UserDefault("username", defaultValue: "unknown") static var username: String
}

struct WJS {
    var name: String = ""
}

// MARK: - propertyWrapper 知识点
// @inline(__always)
@inline(__always) func test() {
  print("test")
}

//使用 @inline(__always) 来混淆订阅的部分
//作用
// 1,比较重要的代码可以使用这个来进行代码混淆, 增大代码破解的难度
// 2, 使函数称为一个标准的内联函数，函数的代码被放入符号表，在使用时直接进行替换 引入内联函数是为了解决函数调用效率的问题，函数之间调用，是内存地址之间的调用，当函数调用完毕之后还会返回原来函数执行的地址，会有一定的时间开销，内联函数就是为了解决这一问题
