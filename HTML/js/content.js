// head标签
head = document.getElementsByTagName('head')[0];
// 固定大小，不在放大与缩小 (即禁止了双击放大功能)
metaTag = document.createElement('meta');
metaTag.name = 'viewport';
metaTag.content= 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no';
head.appendChild(metaTag);

// 获得选中字符的frame，选中的字符所在的句子以及在句子中的位置，和是否跨句或者字符是否大于三个单词
function getInformationWithSelection() {
    var selection = document.getSelection();
    var range = selection.getRangeAt(0);
    var rect = range.getBoundingClientRect();
    var frame = "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
    // 当前选中的字符所处的节点
    var anchorNode = selection.anchorNode;
    // 获得选中的字符串
    var selectString = selection.toString();
    var selectSentence = selectString;
    // 字符串在句子中的开始位置
    var beginOffset = 0;
    // 字符串在句子中的结束位置
    var endOffset = selectString.length;
    // 生词是否隐藏   true 隐藏， false 不隐藏 。默认不隐藏
    var theWordIsHidden = false;
    // 根据空格切割
    var splitArr = selectString.split(' ');
    // 解析句子对象
    var nlp = window.nlp_compromise;
    // 把一段字符串 截取成句子数组
    var arr = nlp.sentenceParser(selectString);
    if (arr.length <= 1 ) { // 即选中的字符串不可以切割为两个及以上句子
        var arr = getParentNodeTextAndNodeLocal(anchorNode);
        // 这个单词所处的节点之前的所有节点的字符长度（一个<p></p>段中）
        var preLength = arr[0];
        // 找到这个单词所在的句子
        var allText = arr[1];
        // 把一段字符串 截取成句子数组
        var arr = nlp.sentenceParser(allText);
        var length = 0;
        for (var i = 0; i < arr.length; i++) {
            var arrStr = arr[i];
            length += arrStr.length;
            if (length >= preLength + range.startOffset + selectString.length) {
                beginOffset = preLength - (length - arrStr.length) + range.startOffset;
                endOffset = beginOffset + selectString.length;
                selectSentence = arrStr;
                break;
            }
        }
        if (splitArr.length > 3) { // 如果字符串经过处理 是一个句子且字符可以分割为三个单词以上 那么隐藏
            theWordIsHidden = true;
        }
    } else { // 如果字符串经过处理 不是一个句子，那么加入生词按钮隐藏
        theWordIsHidden = true;
    }

    return [frame, selectString, selectSentence, theWordIsHidden, beginOffset, endOffset];
}

$(function() {
  // 对div标签上的点击事件的监控
  $('div').on('click', function(e) {
    // 通过点击事件获得相关信息
    var arr = getInformationWithTapClick(e);
    // 前端需要用 window.webkit.messageHandlers.注册的方法名.postMessage({body:传输的数据} 来给native发送消息
    // 以此达到js与oc的交互
    if (arr && typeof(arr) == 'object') {
      console.log(arr);
        //window.webkit.messageHandlers.tapClick.postMessage(arr);
    }
  });
});

// 根据点击事件获取相关信息
function getInformationWithTapClick(event) {
    var i, begin, end, range, textNode, offset;

    range = document.caretRangeFromPoint(event.clientX, event.clientY);
    textNode = range.startContainer;
    offset = range.startOffset;

    // Only act on text nodes
    if (!textNode || textNode.nodeType !== Node.TEXT_NODE) {
        return "";
    }

    var data = textNode.textContent;

    // Sometimes the offset can be at the 'length' of the data.
    // It might be a bug with this 'experimental' feature
    // Compensate for this below
    if (offset >= data.length) {
        offset = data.length - 1;
    }

    // Ignore the cursor on spaces - these aren't words
    if (isW(data[offset])) {
        return "";
    }

    // Scan behind the current character until whitespace is found, or beginning
    i = begin = end = offset;
    while (i > 0 && !isW(data[i - 1])) {
        i--;
    }
    begin = i;

    // Scan ahead of the current character until whitespace is found, or end
    i = offset;
    while (i < data.length - 1 && !isW(data[i + 1])) {
        i++;
    }
    end = i;

    var arr = getParentNodeTextAndNodeLocal(textNode);
    var preLength = arr[0];
    // 找到这个单词所在的句子
    var allText = arr[1];
    // var otherWord = allText.substring(preLength + begin, preLength + end + 1);

    // 得到点击的单词
    var word = data.substring(begin, end + 1);
    // 字符串在句子中的开始位置
    var beginOffset = 0;
    // 字符串在句子中的结束位置
    var endOffset = 0;
    // 去除单词中的特殊字符
    word = deleteSpecialChara(word);
    // 设置单词的开始和结束范围
    range.setStart(textNode, begin);
    range.setEnd(textNode, end+1);
    // 获得点击单词的frame
    var rect = getRectForRange(range);
    // 句子解析对象
    var nlp = window.nlp_compromise;
    // 把一段字符串 截取成句子数组
    var arr = nlp.sentenceParser(allText);
    var length = 0;
    var selectSentence = null;
    for (var i = 0; i < arr.length; i++) {
        var arrStr = arr[i];
        length += arrStr.length;
        if (length >= preLength + end + 1) {
            selectSentence = arrStr;
            beginOffset = preLength - (length - arrStr.length) + begin;
            endOffset = beginOffset + word.length;
            break;
        }
    }
    
    return [word, rect, selectSentence, beginOffset, endOffset, allText];
}

// Whitespace checker
function isW(s) {
    return /[ \f\n\r\t\v\u00A0\u2028\u2029]/.test(s);
}

// 处理字符串前后的特殊字符
function deleteSpecialChara(word) {
    word = word.replace(/[\ |\~|\`|\!|\！|\@|\#|\$|\￥|\%|\^|\&|\*|\(|\（|\)|\）|\_|\+|\=|\||\\|\[|\]|\{|\}|\;|\；|\:|\：|\"|\'|\‘|\,|\，|\<|\.|\>|\/|\?|\”|\“]/g,"");
    return word;
}

// 根据range 获取frame
function getRectForRange(range) {
    var rect = range.getBoundingClientRect();
    return "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
}

// 获得整段文字和点击所在节点之前字符的长度
function getParentNodeTextAndNodeLocal(node) {
    var allText = null;
    var length = 0; // 在这个节点之前的所有节点文字的长度
    var preNode = null; // 上一个节点
    var nodeLocalName = node.parentNode.localName; // localName 标签 例如：p,h1....
    if (node.previousSibling) {
       allText = node.parentNode.innerText;
       preNode = node.previousSibling;
    } else if (node.parentNode && node.parentNode.previousSibling && (nodeLocalName != 'p' && nodeLocalName != 'h1' && nodeLocalName != 'h2' && nodeLocalName != 'h3' && nodeLocalName != 'h4' && nodeLocalName != 'h5' && nodeLocalName != 'h6')) {
       preNode = node.parentNode.previousSibling;
       allText = preNode.parentNode.innerText;
    } else {
       if (nodeLocalName == 'p' || nodeLocalName == 'h1' || nodeLocalName == 'h2' || nodeLocalName == 'h3' || nodeLocalName == 'h4' | nodeLocalName == 'h5' || nodeLocalName != 'h6') {
          allText = node.textContent;
       } else if (node.parentNode.previousSibling) {
          // 如果是一段的第一个标签且不是文本 即如：<i>wo de</i> 而不是 wo de shi jie。
          // 如果不存在  则代表着点击的是一段中的第一个标签（这个标签从段首开始）
          allText = node.parentNode.innerText;
       } else {
          allText = node.parentNode.parentNode.innerText;
       }
    }
    while(preNode) { // 节点存在 则计算长度
       nodeLocalName = preNode.parentNode.localName; // localName 标签 例如：p,h1....
       length += preNode.textContent.length;
       if (preNode.previousSibling) {
           preNode = preNode.previousSibling;
       } else if (preNode.parentNode && preNode.parentNode.previousSibling && (nodeLocalName != 'p' && nodeLocalName != 'h1' && nodeLocalName != 'h2' && nodeLocalName != 'h3' && nodeLocalName != 'h4' && nodeLocalName != 'h5' && nodeLocalName != 'h6')) {
           preNode = preNode.parentNode.previousSibling;
       } else {
           preNode = null;
       }
    }
   return [length, allText];
}
