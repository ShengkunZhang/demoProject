// 属性值
var helloWorld = "Hello World!";

// 函数
function getFullname(firstname, lastname) {
    return firstname + " " + lastname;
}

// 函数
function maxMinAverage(values) {
    var max = Math.max.apply(null, values);
    var min = Math.min.apply(null, values);
    // 这句不注释就会出现异常，因为没有average方法
    // var average = Math.average(values);
    
    var average = null;
    if (values.length > 0) {
        var sum = 0;
        for (var i=0; i<values.length; i++) {
            sum += values[i];
        }
        
        average = sum / values.length;
    }
    
    return {
        "max": max,
        "min": min,
        "average": average
    };
}

//
function generateLuckyNumbers() {
    var luckyNumbers = [];

    while (luckyNumbers.length != 6) {
        var randomNumber = Math.floor((Math.random() * 50) + 1);
        
        if (!luckyNumbers.includes(randomNumber)) {
            luckyNumbers.push(randomNumber);
        }
    }
    
    // oc中定义的函数及使用
    consoleLog(luckyNumbers);
    // oc中定义的函数及使用
    handleLuckyNumbers(luckyNumbers);
}



function convertMarkdownToHTML(source) {
    var converter = new showdown.Converter();
    var htmlResult = converter.makeHtml(source);
    
    consoleLog(htmlResult);
    
    handleConvertedMarkdown(htmlResult);
}


function parseiPhoneList(originalData) {
    var results = Papa.parse(originalData, { header: true });
    if (results.data) {
        var deviceData = [];
        
        for (var i=0; i<results.data.length; i++) {
            var model = results.data[i]["Model"];
            var deviceInfo = DeviceInfo.initializeDevice(model);
            
            deviceInfo.initialOS = results.data[i]["Initial OS"];
            deviceInfo.latestOS = results.data[i]["Latest OS"];
            deviceInfo.imageURL = results.data[i]["Image URL"];
            
            deviceData.push(deviceInfo);
            
            //consoleLog(deviceInfo.imageURL);
        }
        
        return deviceData;
    }
    
    return null;
}
