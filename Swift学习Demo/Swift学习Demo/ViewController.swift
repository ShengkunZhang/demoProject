//
//  ViewController.swift
//  Swift学习Demo
//
//  Created by zsk on 2017/10/18.
//  Copyright © 2017年 zsk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 打印
        print("Hello world")
        
        let myConstant = "你是对的"
        print(myConstant)
        // let 定义的常量 只能赋值一次，之后不能修改
        // myConstant = "test"
        
        let implicDouble: Double = 70.02
        print(implicDouble)
        
        let implicFloat: Float = 70.0
        print(implicFloat)
        
        let label: String = "this is label"
        let width = 100
        // 用String(), 转化为字符串
        let widthLabel = label + String(width)
        // 如果一个字符直接和一个其他类型拼接 error: Binary operator '+' cannot be applied to operands of type 'String' and 'Int'
        // let widthLabel1 = label + width
        print(widthLabel)
        
        let apples = 3
        let oranges = 5
        // 另一个转化为字符串的方法
        let appleSummary = "I hava \(apples) apples."
        // 还可以做计算
        let fruitSummary = "I hava \(apples + oranges) prices of fruit."
        print(appleSummary + fruitSummary)
        
        // var 声明的是变量
        var myVariable = 50
        myVariable = 40
        print(myVariable)
        
        // 数组
        var arr = [200, 30, 40]
        arr[0] = 100
        var stringArr = ["wode", "nide", "tade"]
        stringArr[1] = "haha"
        
        // 字典
        var dict = [
            "date": "2017/09/01",
            "data": "sdfsdfsdf",
        ]
        dict["date"] = "2017/09/30"
        
        // 空数组
        // let emptyArr = [String]()
        // 空字典
        // let emptyDictionary = [String:Float]()
        
        // 如果类型信息可以被推断出来，你可以用 [] 和 [:] 来创建空数组和空字典——就像你声明变量或者给函数传参 数的时候一样。
        // var shopList = []
        // var shopDictionary = [:]
        
        let individualScores = [75, 43, 103, 87, 12]
        var teamScore = 0
        // for语句
        for score in individualScores {
            if score > 50 {
                teamScore += 3
            } else {
                teamScore += 1
            }
            // 不会隐形地与0做对比 error: 'Int' is not convertible to 'Bool'
            //if score {
            //    teamScore += 3
            //}
        }
        print(teamScore)
        
        // 类型后面加一个问号来标记这个变量的值是可选的
        // 可选的值是一个具体的值或者 是 nil 以表示值缺失
        let optionString: String? = "可选测试"
        // 输出false
        print(optionString == nil)
        // 打印出可选测试，如果为nil，则输出who
        print(optionString ?? "who")
        
        let optionOtherString: String? = nil
        // 打印出who ??是用来判断可选的常量或者变量的值是否存在，存在则使用可选值，存在可使用后面的值
        print(optionOtherString ?? "who")
        
        let optionalName: String? = "John Appleseed"
        var greeting = "Hello!"
        if let name = optionalName {
            greeting = "Hello, \(name)"
        } else {
            greeting = "nice to meet you"
        }
        print(greeting)
        
        let optionOtherName: String? = nil
        //// 由于optionOtherName的可选值为nil 所以name为nil,
        //if nil {
        //    // 不执行
        //} else {
        //    // 执行这里面的代码} nil为false 
        //}
        if let name = optionOtherName {
            greeting = "Hello, \(name)"
        } else {
            greeting = "nice to meet you"
        }
        print(greeting)
        
        // switch 支持任意类型的数据以及各种比较操作——不仅仅是整数以及测试相等。
        let vegetable = "red pepper"
        switch vegetable {
        case "celery": // 普通字符串
            print("Add some raisins and make ants on a log.")
        case "cucumber", "watercress":
            // 两个变量有一个相等的就算是符合
            print("That would make a good tea sandwich.")
        case let x where x.hasSuffix("pepper"):
            /**
             let x where x.hasSuffix("pepper")
             hasSuffix 后缀，hasPrefix 前缀
             就是判断前缀或者后缀是不是某个字符。
             let 在等式中是如何使用的，它将匹配等式的值赋给常量 x
             x 的值为pepper。没有想明白
             */
            print("Is it a spicy \(x)?")
        default:
            // 如果删除default ，error : Switch must be exhaustive, consider adding a default clause
            print("Everything tastes good in soup.")
        }
        
        // 遍历字典
        let interestingNumbers = [
            "Prime": [2, 3, 5, 7, 11, 13],
            "Fibonacci": [1, 1, 2, 3, 5, 8],
            "Square": [1, 4, 9, 16, 25],
            ]
        var largest = 0
        var largestKind = ""
        for (kind, numbers) in interestingNumbers {
            for number in numbers {
                if number > largest {
                    largest = number
                    largestKind = kind
                }
            }
        }
        
        print(largestKind + ": " + String(largest))
        
        // while 循环
        var n = 2
        while n < 100 {
            n = n * 2
        }
        print("while 循环后n: " + String(n))
        
        var m = 2
        repeat {
            m = m * 2
        } while m < 100
        print("repeat 循环后m: " + String(m))
        
        //  ..< 创建的范围不包含上界
        var total = 0
        for i in 1..<5 {
            total += i
        }
        print("1..<5为 1-5, 有1但是不包括5 total: " + String(total))
        
        //  ... 创建的范围包含上界和下界
        var otherTotal = 0
        for i in 1...5 {
            otherTotal += i
        }
        print("1...5为 1-5, 1 =< x <= 5 otherTotal: " + String(otherTotal))
        
        // 默认参数标签
        let result = greet(person: "boy", day: "mon", food: "apple")
        print(result)
        
        // 自定义参数标签
        otherGreet("boy", on: "mon", to: "apple")
        
        // 使用元组来让一个函数返回多个值。该元组的元素可以用名称或数字来表示
        let statistics = calculateStatistics(scores:[5, 3, 100, 3, 9])
        // calculateStatistics 的返回值return (min, max, sum)
        // 可以直接如下使用sum的值
        print(statistics.sum)
        // 也可以按照顺序取得sum的值。即(statistics.0)或者(statistics.min), (statistics.1)或者(statistics.max)
        print(statistics.2)
        
        // 可变个数的参数
        let sum = sumOf(numbers: 42, 597, 12)
        let sum1 = sumOf(numbers: 42, 597)
        print("results: \(sum) ,\(sum1)")
        
        let avger = averageOf(numbers: 42, 30, 20, 12, 33)
        print("平均值为: \(avger)")
        
        let 你好 = "中文变量"
        print(你好)
        
        let fitFiteen = returnFifteen()
        print("嵌套函数调用: \(fitFiteen)")
        
        // 这个变量是个函数
        let increment = makeIncrementer()
        // 调用函数变量
        let resulteIncrement = increment(7)
        print(resulteIncrement)
        
        
        // 将要当做参数的函数
        func lessThanTen(number: Int) -> Bool {
            return number < 10
        }
        let numbers = [20, 19, 7, 12]
        let hasResult = hasAnyMatches(list: numbers, condition: lessThanTen)
        print(hasResult)
    }
    
    // 使用 func 来声明一个函数，使用名字和参数来调用函数。使用 -> 来指定函数返回值的类型
    func greet(person: String, day: String, food: String) -> String {
        return "Hello \(person) today is \(day), want to eat \(food)"
    }
    
    // 默认情况下，函数使用它们的参数名称作为它们参数的标签，在参数名称前可以自定义参数标签，或者使用 _ 表示不使用参数标签
    func otherGreet(_ person: String, on day: String, to food: String) -> Void {
        print("Hello \(person) today is \(day), want to eat \(food)")
    }

    // 返回的三个参数，可以当做返回变量属性使用
    func calculateStatistics(scores: [NSInteger]) -> (min: NSInteger, max: NSInteger ,sum: NSInteger) {
        var min = scores[0]
        var max = scores[0]
        var sum = 0
        
        for score in scores {
            if score > max {
                max = score
            } else if score < min {
                min = score
            }
            sum += score
        }
        return (min, max, sum)
    }

    // 函数可以带有可变个数的参数，这些参数在函数内表现为数组的形式
    func sumOf(numbers: NSInteger...) -> NSInteger {
        var sum = 0
        for number in numbers {
            sum += number
        }
        return sum
    }
    
    // 计算平均值
    func averageOf(numbers: NSInteger...) -> Double {
        var aver = 0.0
        var sum = 0
        for number in numbers {
            sum += number
        }
        
        aver = Double(sum) / Double(numbers.count)
        return aver
    }
    
    // 函数可以嵌套。被嵌套的函数可以访问外侧函数的变量，你可以使用嵌套函数来重构一个太长或者太复杂的函数
    func returnFifteen() -> NSInteger {
        var y = 10
        // 函数嵌套
        func add() {
            // 访问外侧函数的变量
            y += 5
        }
        add()
        return y
    }
    
    // 函数是第一等类型，这意味着函数可以作为另一个函数的返回值
    func makeIncrementer() -> ((NSInteger) -> NSInteger) {
        // 返回值与将要返回的函数相对应
        //                 (NSInteger) -> NSInteger
        func addOne(number: NSInteger) -> NSInteger {
            return 1 + number
        }
        // 把函数当做参数返回
        return addOne
    }
    
    // 函数也可以当做参数传入另一个函数
    // 第一个参数数组，第二个参数函数
    func hasAnyMatches(list: [NSInteger], condition: (NSInteger) -> Bool) -> Bool {
        for item in list {
            if condition(item) {
                return true
            }
        }
        return false
    }
    
}

