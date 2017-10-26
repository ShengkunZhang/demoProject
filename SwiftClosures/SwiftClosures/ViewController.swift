//
//  ViewController.swift
//  SwiftClosures
//
//  Created by zsk on 2017/10/20.
//  Copyright © 2017年 zsk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 一般形式
        let calAdd:(NSInteger ,NSInteger) ->(NSInteger) = {
            (a: NSInteger, b: NSInteger) -> NSInteger in
            return a + b
        }
        let result = calAdd(23, 34)
        print(result)
        
        // Swift可以根据闭包上下文推断参数和返回值的类型，所以上面的例子可以简化如下
        let calAdd2:(NSInteger, NSInteger) ->(NSInteger) = {
            a, b in  // 或者 (a, b) in
            return a + b
        }
        print(calAdd2(100, 234))
        
        // 或者简化为这样
        let calAdd3:(NSInteger, NSInteger) ->(NSInteger) = { (a, b) in a + b }
        print(calAdd3(199, 221))
        
        // 如果闭包没有参数
        let calAdd4:() ->NSInteger = { return 100 + 200 }
        print(calAdd4())
        
        // 如果没有参数和返回值
        let calAdd5:() ->Void = { print("我是测试用的") }
        calAdd5()
        
        // 更简单的表达方式
        let calAdd55 = {
            print("我就是在次试试")
        }
        calAdd55()
        
        // 关键字“typealias”先声明一个闭包数据类型
        typealias AddBlock = (NSInteger, NSInteger) -> (NSInteger)
        let calAdd6:AddBlock = {
            (a, b) in
            return a + b
        }
        print(calAdd6(234, 189))
        
        
        // 将闭包作为函数最后一个参数，可以省略参数标签,然后将闭包表达式写在函数调用括号后面
        func testFunction(testBlock: () ->Void) {
            // 这里需要传进来的闭包类型是无参数和无返回值的
            testBlock()
        }
        
        // 正常写法
        testFunction(testBlock: {
            print("正常写法")
        })
        // 尾随闭包写法
        testFunction() {
            print("尾随闭包写法")
        }
        // 也可以把括号去掉，也是尾随闭包写法。推荐写法
        testFunction { 
            print("去掉括号的尾随闭包写法")
        }
        
        // 实际应用中
        let numbers = [20, 300, 291, 435, 786]
        // sort 排序
        // 排序的完整写法
        let sortNumbers22 = numbers.sorted { (number1: NSInteger, number2: NSInteger) -> Bool in
            return number1 > number2
        }
        print("完整写法的打印： \(sortNumbers22)")
        // 降序
        let sortNumbers = numbers.sorted{ $0 > $1 }
        print("降序序后的数组：\(sortNumbers)")
        // 升序
        let otherSortNumbers = numbers.sorted{ $1 > $0 }
        print("升序后的数组：\(otherSortNumbers)")
        // 默认为升序
        let sortNumbers11 = numbers.sorted()
        print(sortNumbers11)
        // 也可以这样
        let sortNumbers33 = numbers.sorted(by: >)
        print(sortNumbers33)
        
        // map 有点像一种遍历，然后对遍历的数据进行处理，并返回给数组
        let mappedNumbers = numbers.map({
            (number: NSInteger) ->NSInteger in
            return number * 3
        })
        print("map 遍历处理后的数据： \(mappedNumbers)")
        
        // 所有的奇数转换为0
        let mappedNumbers1 = numbers.map({
            (number: NSInteger) -> NSInteger in
            if number % 2 == 0 {
                return number
            } else {
                return 0
            }
        })
        print("所有的奇数都被置换为0：\(mappedNumbers1)")
        
        // 函数值捕获
        // 返回值是个函数（一个不需要参数，返回值为int）
        func captureValue(sums amount:Int) -> ()->Int{
            var total = 0
            func incrementer() ->Int{
                total += amount
                return total
            }
            return incrementer
        }
        // 当你持有这个返回对象时
        let referenceFunc = captureValue(sums: 10)
        print(referenceFunc()) // 10
        print(referenceFunc()) // 20
        print(referenceFunc()) // 30
        
        // 闭包形式
        func captureValue2(sums amount:Int) -> ()->Int{
            var total = 0
            let AddBlock:()->Int = {
                total += amount
                return total
            }
            return AddBlock
        }
        
        let testBlock = captureValue2(sums: 100)
        print(testBlock()) // 100
        print(testBlock()) // 200
        print(testBlock()) // 300
        
        // 逃匿闭包
        // 当一个闭包作为参数传到一个函数中，需要这个闭包在函数返回之后才被执行，我们就称该闭包从函数种逃逸。一般如果闭包在函数体内涉及到异步操作，但函数却是很快就会执行完毕并返回的，闭包必须要逃逸掉，以便异步操作的回调。
        // 逃逸闭包一般用于异步函数的回调，比如网络请求成功的回调和失败的回调。语法：在函数的闭包行参前加关键字“@escaping”。
        // 例1
        func doSomething(some: @escaping () -> Void){
            // 延时操作，注意这里的单位是秒
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                // 1秒后操作
                some()
            }
            print("函数体")
        }
        // 调用函数doSomething时简写的写法如下，意思是把{ print("逃逸闭包") } 这个简写的闭包当做参数传递给这个函数
        doSomething { print("逃逸闭包") }
         
        // 例2
        var comletionHandle: ()->String = {"约吗?"}
        func doSomething2(some: @escaping ()->String){
            // 对comletionHandle 重新赋值
            comletionHandle = some
        }
        doSomething2 {
            return "叔叔，我们不约"
        }
        // comletionHandle的返回值被改变了
        print(comletionHandle())
        
        // 定义一个类
        class someClass: NSObject {
            // 将一个闭包标记为@escaping意味着你必须在闭包中显式的引用self。
            // 其实@escaping和self都是在提醒你，这是一个逃逸闭包，
            // 别误操作导致了循环引用！而非逃逸包可以隐式引用self。
            
            var x = 10
            // 定义了一个数组：一个闭包函数的数组
            var completionHandlers: [() -> Void] = []
            // 逃逸
            func someFunctionWithEscapingClosure(completionHandler: @escaping () -> Void) {
                completionHandlers.append(completionHandler)
            }
            // 非逃逸
            func someFunctionWithNonescapingClosure(closure: () -> Void) {
                closure()
            }
            
            func myTest() {
                someFunctionWithEscapingClosure { self.x = 100 }
                someFunctionWithNonescapingClosure { x = 200 }
            }
        }
    }
}

