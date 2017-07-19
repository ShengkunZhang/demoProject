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
    var splitArr = getWordArrWithString(selectString);
    // 句子解析对象
    var nlp = window.nlp(selectString);
    // 把一段字符串 截取成句子对象数组
    var sentenceArr = nlp.sentences().out('array');
    if (sentenceArr.length <= 1 ) { // 即选中的字符串不可以切割为两个及以上句子
        var arr = getParentNodeTextAndNodeLocal(anchorNode);
        // 这个单词所处的节点之前的所有节点的字符长度（一个<p></p>段中）
        var preLength = arr[0];
        // 找到这个单词所在的句子
        var allText = arr[1];
        // 句子解析对象
        arr = getSentenceArrWithString(allText);
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

// 是快读模式吗 false 不是，true 是
var isFastRead = false;
// 节点数组
var nodeArr = [];

$(function() {
  // 对div标签上的点击事件的监控
  $('div').on('click', function(e) {
    // 通过点击事件获得相关信息
    var arr = getInformationWithTapClick(e);
    // 前端需要用 window.webkit.messageHandlers.注册的方法名.postMessage({body:传输的数据} 来给native发送消息
    // 以此达到js与oc的交互
    if (arr && typeof(arr) == 'object') {
        // window.webkit.messageHandlers.tapClick.postMessage(arr);
        console.log(arr);
    }
  });
});

// 根据点击事件获取相关信息
function getInformationWithTapClick(event) {
    var i, begin, end, range, textNode, offset;

    // 根据事件的属性找到相应的位置及节点及偏移量
    range = document.caretRangeFromPoint(event.clientX, event.clientY);
    textNode = range.startContainer;
    offset = range.startOffset;

    // 节点为元素节点且有子节点则选中的节点是当前节点的第一个子节点
    // <a> <mark>...</mark> </a> 此时如果点击mark标签附近获得的节点就符合下面的判断
    if (textNode.nodeType == Node.ELEMENT_NODE && textNode.childNodes.length != 0) {
        textNode = textNode.childNodes[0];
    }

    // 如果节点不存在直接没有继续的必要且必须是文本节点，即二者必须同时成立
    if (!textNode || textNode.nodeType !== Node.TEXT_NODE) {
        return "";
    }

    // 点击所处的node的content
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

    // 得到点击位置的字符
    var word = data.substring(begin, end + 1);
    var isHas = isHasAEnglishLetters(word);
    if (!isHas) {
        console.log('点击的不是英语词语');
        return;
    }

    // 根据选中的节点找到当前节点所处的位置以及所在的整体文本内容
    var arr = getParentNodeTextAndNodeLocal(textNode);
    var preLength = arr[0]; // 当前节点的位置
    var allText = arr[1]; // 当前节点所在的段落内容

    // 获得当前node所在的句子
    var sentenceTemp = getSentenceWithAllText(allText, preLength + begin, word);

    // 去除字符左右的特殊字符 得到更为准确的单击位置的单词
    word = deleteSpecialChara(word);
    // 根据选中的单词及其所在的句子。得到经过词性分析后的单词及其原本的形式（名词变为单数，动词变为不定式）
    var wordArr = handleSentenceAndTapWord(data, word, begin, sentenceTemp);
    word = wordArr[0]; // 经过处理后确定的选中单词
    var root = wordArr[1]; // 选中单词的词根
    var realIndex = wordArr[2]; // 在当前节点中的真实的开始位置
    var wordType = wordArr[3]; // 单词的类型
    begin = realIndex;

    // 处理节点
    var isAdd = handleTapNode(textNode, word, realIndex, root, wordType);

    // 校正最后的段落位置和选中的句子
    var infoArr = getSentenceInfo(allText, word, preLength + begin);
    var beginOffset = infoArr[0]; // 字符串在句子中的开始位置
    var endOffset = infoArr[1]; // 字符串在句子中的结束位置
    var selectSentence = infoArr[2]; // 选中的句子
    selectSentence = deleteSpecialChara(selectSentence, true); // 去除首尾的空格和换行符

    return [word, selectSentence, allText, beginOffset, endOffset, isAdd, root, wordType];
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
    // 如果此节点的父节点的父节点为div 则说明此节点的父节点是div层下的子节点，则此节点的父节点就是一个独立的段落
    var nodeLocalName = node.parentNode.parentNode.localName; // localName 标签应该为div
    var paragraphNode = node.parentNode; // 段落节点
    // 找到此节点的上一个节点和此节点所在的整个段落的文字
    // 如果此节点直接存在上个节点
    if (node.previousSibling) { // 上个节点
        preNode = node.previousSibling;
    } else if (node.parentNode.previousSibling) { // 此节点的父节点有上一个节点
        if (nodeLocalName != 'div') { // 如果不是div标签
            preNode = node.parentNode.previousSibling;
        }
    } else {
        // 如果不是div标签 且 此节点无直接的上一个节点 且 此节点的父节点也没有上一个节点
        // 这种情况可能是比较深的标签之间的嵌套
        // 例如：<div><span><p><em><strong><i>this is span p em strong i tag.</i></strong></em></p></span></div>
        // 或者类似这种的情况 <div><span> this is span tag. <p><em><strong><i>this is span p em strong i tag.</i></strong></em></p></span></div>
        // 这种情况的结束就是：要么找到了上一个节点，要么就是 nodeLocalName == div
        var otherNode = node.parentNode;
        while (nodeLocalName != 'div' && !preNode) { // 只有同时(nodeLocalName != div&&preNode == null), 才能进入循环
            nodeLocalName = otherNode.parentNode.parentNode.localName;
            paragraphNode = otherNode.parentNode;
            if (nodeLocalName == 'div') {
                preNode = null;
            } else {
                preNode = otherNode.parentNode.previousSibling;
            }
            otherNode = otherNode.parentNode;
        }
    }
    while(preNode) { // 节点存在 则计算长度
        nodeLocalName = preNode.parentNode.parentNode.localName; // localName 标签为div
        if (nodeLocalName == 'body') {
            preNode = null;
            allText = node.textContent;
            return [length, allText];
        }
        paragraphNode = preNode.parentNode;
        length += preNode.textContent.length;
        if (preNode.previousSibling) {
            preNode = preNode.previousSibling;
        } else if (preNode.parentNode.previousSibling) {
            if (nodeLocalName != 'div') { // 如果不是div标签
                preNode = preNode.parentNode.previousSibling;
            } else {
                preNode = null;
            }
        } else {
            var otherNode = preNode.parentNode;
            preNode = null;
            while (nodeLocalName != 'div' && !preNode) { // 只有同时(nodeLocalName != div&&preNode == null), 才能进入循环
                nodeLocalName = otherNode.parentNode.parentNode.localName;
                paragraphNode = otherNode.parentNode;
                if (nodeLocalName == 'div') {
                    preNode = null;
                } else {
                    preNode = otherNode.parentNode.previousSibling;
                }
                otherNode = otherNode.parentNode;
            }
        }
    }

    allText = paragraphNode.innerText;
    // 校正文字的位置
    nodeText = getNodeText(node);
    realIndex = realIndex = allText.indexOf(nodeText, length);
    if (realIndex == -1) {
      length --;
      realIndex = allText.indexOf(nodeText, length);
    }
    return [length, allText];
}

// Whitespace checker
function isW(s) {
    return /[ \f\n\r\t\v\u00A0\u2028\u2029]/.test(s);
}

// 处理字符串前后的特殊字符
function deleteSpecialChara(word, isPart) {
    var arr = ['\ ', '\~', '\`', '\!', '\！', '\@', '\#', '\$', '\￥', '\%',
               '\^', '\&', '\*', '\(', '\（', '\)', '\）', '\_', '\+', '\=',
               '\|', '\\', '\[', '\]', '\{', '\}', '\;', '\；', '\:', '\：',
               '\"', '\'', '\‘', '\’', '\,', '\，', '\<', '\.', '\>', '\/',
               '\?', '\”', '\“', '\…', '\n'];
    if (isPart) {
      arr = ['\ ', '\n'];
    }

    var wordLength = word.length + 1;
    var theFirst = true;
    while (wordLength > word.length) {
        if (theFirst) {
            wordLength -= 1;
        } else {
            wordLength = word.length;
        }
        for (var i = 0; i < arr.length; i++) {
            var char = arr[i];
            // 左侧
            word = word.replace(new RegExp('^\\'+char+'+', 'g'), '');
            // 右侧
            word = word.replace(new RegExp('\\'+char+'+$', 'g'), '');
        }
    }
    return word;
}

// 单击处理node
function handleTapNode(node, word, index, root, wordType) {
    var mean = getMean(root, wordType);
    var parentNode = node.parentNode;
    var attribute = parentNode.getAttribute("data-entity");
    // class的二个不同的值，分别是：普通模式下点击添加mark，开启快读时添加的mark
    var classNameArr = ['classTap', 'classFast'];
    if (parentNode.localName == 'mark' && attribute) { // 如果是mark tag
        var grandpaNode = parentNode.parentNode;
        // 1. 现在此mark node 之前插入一个textnode
        var textNode = document.createTextNode(word);
        grandpaNode.insertBefore(textNode, parentNode);
        // 2. 删除此mark node
        grandpaNode.removeChild(parentNode);
        return false;
    } else {
        var nextNode = node.nextSibling;
        var data = node.textContent;
        var localName = parentNode.localName;
        // 选中的单词在这个节点中之前的字符即此字符的节点
        var beforeString = data.substring(0, index);
        var beforeNode = document.createTextNode(beforeString);
        // 选中的单词在这个节点中之后的字符即此字符的节点
        var afterString = data.substring(index + word.length, data.length);
        var afterNode = document.createTextNode(afterString);
        // 选中单词的节点
        var wordNode = document.createTextNode(word);

        // 创建此mark节点
        var markNode = document.createElement('mark');
        // 添加 data-entity
        markNode.setAttribute('data-entity', mean);
        // 点击的className 就是classTap
        var className = classNameArr[0];
        if (isFastRead) {
            className = classNameArr[1];
        }
        markNode.setAttribute('class', className);
        markNode.appendChild(wordNode);

        // 删除此节点本身
        parentNode.removeChild(node);
        if (localName == 'div') {
          var spanNode = document.createElement('span');
          spanNode.appendChild(beforeNode);
          spanNode.appendChild(markNode);
          spanNode.appendChild(afterNode);
          if (nextNode) {
            parentNode.insertBefore(spanNode, nextNode);
          } else {
            parentNode.appendChild(spanNode);
          }
        } else {
          if (nextNode) { // 此节点是否有下一个相邻节点
              // 插入在此节点之前 insertBefore
              parentNode.insertBefore(afterNode, nextNode);
              parentNode.insertBefore(markNode, afterNode);
              parentNode.insertBefore(beforeNode, markNode);
          } else {
              // 直接 appendChild
              parentNode.appendChild(beforeNode);
              parentNode.appendChild(markNode);
              parentNode.appendChild(afterNode);
          }
        }
    }
    return true;
}

// 处理关闭快读
function handleCloseFastRead() {
    // 将具有calssFast的标签处理了，去除mark改为textNode
    var classArr = document.getElementsByClassName('classFast');
    for (var i = classArr.length - 1; i >= 0 ; i--) {
        // 处理此节点
        var markNode = classArr[i];
        var grandpaNode = markNode.parentNode;
        // 1. 现在此mark node 之前插入一个textnode
        var textNode = document.createTextNode(markNode.innerText);
        grandpaNode.insertBefore(textNode, markNode);
        // 2. 删除此mark node
        grandpaNode.removeChild(markNode);
    }
}

// 处理开启快读
function handleOpenFastRead() {
    nodeArr = [];
    // 找到div层
    var divNode = document.getElementsByTagName('div')[0];
    // 找到div层的子节点
    handleFastReadLogic(divNode);
    for (var i = 0; i < nodeArr.length; i++) {
        handleFastNode(nodeArr[i]);
    }
}

// 处理快读节点逻辑
function handleFastReadLogic(node) {
    // 首先判断如果将要处理的是元素节点且此元素节点的localName为mark且此节点有data-entity属性 则不处理
    if (node.nodeType == Node.ELEMENT_NODE) {
        var nodeName = node.localName;
        var attribute = node.getAttribute("data-entity");
        if (nodeName == 'mark' && attribute) {
            return;
        }
    }

    if (node.childNodes.length) {
        for (var i = 0; i < node.childNodes.length; i++) {
            var nextNode = node.childNodes[i];
            // 如果节点有内容 则处理
            nodeText = getNodeText(node);
            isHas = isHasAEnglishLetters(nodeText);
            if (isHas) {
                // 处理这个节点
                handleFastReadLogic(nextNode);
            }
        }
    } else {
        // 如果节点有内容 则处理
        nodeText = getNodeText(node);
        isHas = isHasAEnglishLetters(nodeText);
        if (isHas) {
            // 处理这个节点
            nodeArr.push(node);
        }
    }
}

// 处理开启快读相应节点的处理
function handleFastNode(node) {
    // 获得节点的文本内容
    var nodeText = node.textContent;
    // [wordArr, endWordTypeArr, rootArr]
    var nodeArr = getWordAndRootWithNode(node);
    var arr = nodeArr[0];
    var wordTypeArr = nodeArr[1];
    var rootArr = nodeArr[2];
    // 本节点将被切割为的子节点数组
    var childNodeArr = [];
    var begin = 0;
    var end = 0;
    var realIndex = 0;
    for (i = 0; i < arr.length; i++) {
        // 得到单词
        var text = arr[i];
        var type = wordTypeArr[i];
        var root = rootArr[i];
        // 辨别是否包含字母
        var isHas = isHasAEnglishLetters(text);
        if (isHas) {
            // 处理单词左右的特殊字符
            text = deleteSpecialChara(text);
            // 1. 这个词是否在生词本中
            var isNew = isNewWord(root);
            if (isNew) {
                realIndex = nodeText.indexOf(text, begin);
                // 先处理之前可能存在的textNode
                if (realIndex != end) {
                    // 1.3 如果不在，则将这个mark之间的作为一个textNode节点
                    var otherText = nodeText.substring(end, realIndex);
                    var textNode = getTextNode(otherText);
                    childNodeArr.push(textNode);
                }
                // 1.2 如果在，找到这个单词的词义
                var mean = getMean(root, type);
                // 1.2.1 将这个单词及词义，生成一个mark节点，此节点的class为classFast
                var markNode = getMarkNode(text, mean);
                childNodeArr.push(markNode);
                end = (realIndex + text.length);
                begin = end;
            } else {
                realIndex = nodeText.indexOf(text, begin);
                begin = (realIndex + text.length);
            }
        }
    }

    // 循环结束后，判断end是否小于节点内容的长度，小于说明从end到结束这个段落还未处理
    if (end < nodeText.length) {
        var endText = nodeText.substring(end, nodeText.length);
        var endTextNode = getTextNode(endText);
        childNodeArr.push(endTextNode);
    }

    var nextNode = node;
    var parentNode = node.parentNode;
    if (parentNode.localName == 'div') {
      var spanNode = document.createElement('span');
      // 处理完成后，顺序加入父节点
      for (i = 0; i < childNodeArr.length; i++) {
          var appendNode = childNodeArr[i];
          spanNode.appendChild(appendNode);
      }
      parentNode.insertBefore(spanNode, nextNode);
    } else {
      // 处理完成后，顺序加入父节点
      for (i = childNodeArr.length - 1; i >= 0 ; i--) {
          var tempNode = childNodeArr[i];
          parentNode.insertBefore(tempNode, nextNode);
          nextNode = tempNode;
      }
    }
    parentNode.removeChild(node);
}

// 是否是生词
function isNewWord(word) {
    // 用confirm函数与oc交互
    // return confirm(word);
    return true;
}

// 获得单词的词义
function getMean(word, wordType) {
    // 用prompt函数与oc交互
    var mean = prompt(word, '无');
    if (mean == '无') {
      if (wordType == 'people') {
        mean = '人名';
      } else if (wordType == 'place') {
        mean = '地名';
      } else if (wordType == 'organization') {
        mean = '组织名';
      }
    }
    return mean;
}

// 获得markNode对象
function getMarkNode(word, mean) {
    // 创建选中单词的文本节点
    var wordNode = document.createTextNode(word);
    // 创建此标签为mark的元素节点
    var markNode = document.createElement('mark');
    // 添加 data-entity
    markNode.setAttribute('data-entity', mean);
    // 添加 class
    markNode.setAttribute('class', 'classFast');
    // 文本节点加入元素节点
    markNode.appendChild(wordNode);
    return markNode;
}

// 获得某段文字的节点
function getTextNode(word) {
    var wordNode = document.createTextNode(word);
    return wordNode;
}

// 取某个节点的文本内容
function getNodeText(node) {
    var nodeText = '';
    if (node.nodeType == Node.ELEMENT_NODE) {
        nodeText = node.innerText;
    } else if (node.nodeType == Node.TEXT_NODE) {
        nodeText = node.textContent;
    }
    return nodeText;
}

// 正则判断字符串中是否有大写字母或者小写字母
function isHasAEnglishLetters(string) {
    var pattEnglish = new RegExp('([A-Za-z])');
    var isHasEnglish = pattEnglish.test(string);

    // 是否有中文
    var pattChinese = new RegExp('[\u4e00-\u9fa5]');
    var isHasChinese = pattChinese.test(string);
    if (isHasChinese) {
        isHasEnglish = false;
    }
    return isHasEnglish;
}

function getSentenceArrWithString(string) {
  // 句子解析对象
  var nlp = window.nlp(string);
  // 把一段字符串 截取成句子对象数组
  // 使用下面这种方式更简单，但是输出的句子被处理了，不在是原来的样式，所以舍弃
  // var arr = nlp.sentences().out('array');
  var sentenceObjectArr = nlp.sentences().data();
  var arr = [];
  for (var i = 0; i < sentenceObjectArr.length; i++) {
    var sentenceText = sentenceObjectArr[i].text;
    arr.push(sentenceText);
  }
  return arr;
}

function getSentenceWithAllText(allText, preLength, data) {
  sentenceArr = getSentenceArrWithString(allText);
  realIndex = allText.indexOf(data, preLength);
  while (realIndex == -1) {
    return data;
  }
  length = 0;
  for (var i = 0; i < sentenceArr.length; i++) {
    text = sentenceArr[i];
    if (length + text.length > realIndex) {
      return text;
    }
    length += text.length;
  }
  return data;
}

function getSentenceInfo(allText, word, index) {
  var beginOffset = 0; // 字符串在句子中的开始位置
  var endOffset = 0; // 字符串在句子中的结束位置
  var selectSentence = ''; // 选中的句子
  // 在计算之前节点长度的基础上再次校正开始的位置
  // 在当前段落中的真实位置
  realIndex = allText.indexOf(word, index); // 真实的开始位置
  arr = getSentenceArrWithString(allText);

  var length = 0;
  for (i = 0; i < arr.length; i++) {
      var arrStr = arr[i];
      length += arrStr.length;
      if (length >= realIndex + word.length) {
          selectSentence = arrStr;
          beginOffset = realIndex - (length - arrStr.length);
          endOffset = beginOffset + word.length;
          break;
      }
  }
  return [beginOffset, endOffset, selectSentence];
}

// 切割字符串为单词数组
function getWordArrWithString(string) {
  // 句子解析对象
  var nlp = window.nlp(string);
  var arr = [];
  var wordObjectArr = nlp.terms().data();
  for (var i = 0; i < wordObjectArr.length; i++) {
    var word = wordObjectArr[i].text;
    word = deleteSpecialChara(word);
    arr.push(word);
  }
  return arr;
}

function getWordAndRootWithNode(node) {
  var endWordArr = []; // 正常的句子切割数组
  var endWordTypeArr = []; // 单词类型数组
  var rootArr = []; // root数组

  // 获得节点的文本内容
  var nodeText = node.textContent;

  // 根据选中的节点找到当前节点所处的位置以及所在的整体文本内容
  var arr = getParentNodeTextAndNodeLocal(node);
  var preLength = arr[0]; // 当前节点的位置
  var allText = arr[1]; // 当前节点所在的段落内容

  // 如果所在的句子可以继续分割为不同的句子，则说明这是一个段落
  var sentenceArr = getSentenceArrWithString(nodeText);
  var nodeTextArr = [];
  var endSentenceArr = [];
  if (sentenceArr.length > 1) {
    for (var m = 0; m < sentenceArr.length; m++) {
      var nodeTextTemp = sentenceArr[m];
      sentenceTemp = getSentenceWithAllText(allText, preLength, nodeTextTemp);
      endSentenceArr.push(sentenceTemp);
      nodeTextArr.push(nodeTextTemp);
      preLength += nodeTextTemp.length;
    }
  } else {
    // 获得当前node所在的句子
    sentenceTemp = getSentenceWithAllText(allText, preLength, nodeText);
    endSentenceArr = [sentenceTemp];
    nodeTextArr = [nodeText];
  }

  for (var k = 0; k < endSentenceArr.length; k++) {
    sentenceTemp = endSentenceArr[k];
    nodeText = nodeTextArr[k];

    // 先获取简单分割的单词数组
    var wordArr = getWordArrWithString(nodeText);
    var begin = 0;
    for (var i = 0; i < wordArr.length; i++) {
      var word = wordArr[i];
      // 去除字符左右的特殊字符 得到更为准确的单击位置的单词
      word = deleteSpecialChara(word);
      begin = nodeText.indexOf(word, begin);
      // 根据选中的单词及其所在的句子。得到经过词性分析后的单词及其原本的形式（名词变为单数，动词变为不定式）
      arr = handleSentenceAndTapWord(nodeText, word, begin, sentenceTemp);
      var endWord = arr[0]; // 经过处理后确定的选中单词
      root = arr[1]; // 选中单词的词根
      realIndex = arr[2]; // 在当前节点中的真实的开始位置
      wordType = arr[3]; // 单词的类型
      var isExist = false; // 是否存在，初始为不存在
      var arrLength = endWordArr.length;
      if (arrLength > 0) {
        // 如果相邻的两个单词相等，则不添加到数组中
        // 考虑New York, New会被识别为New York ,York 同样也会。 但是New York 只能添加一次。
        var temp = endWordArr[arrLength - 1];
        var tempArr1 = getWordArrWithString(endWord);
        if (temp == endWord && tempArr1.length > 1) { // ...you， you... 这种情况
          for (var j = 0; j < tempArr1.length; j++) {
            var temp2 = tempArr1[j];
            temp2 = deleteSpecialChara(temp2);
            if (word == temp2) { // ...New York, New York.... 这种情况
                isExist = true;
                console.log(word);
                console.log(endWord);
                break;
            }
          }
        }
      }

      if (!isExist) {
        endWordArr.push(endWord);
        endWordTypeArr.push(wordType);
        rootArr.push(root);
      }
    }
  }

  return [endWordArr, endWordTypeArr, rootArr];
}

function handleSentenceAndTapWord(data, word, begin, sentence) {
  // 选中单词的词根
  var root = '';
  var wordType = 'normal'; // 普通的动词或者名词为normal, 人名为people, 地名为place, 组织名organization
  var realIndex = 0;
  var nlp = window.nlp(sentence);
  // 找到人名，组织名称，地名 例如:Mr. Trump, China , Washington
  // 具体区分单词属性
  var topicObjectArr = nlp.topics().data();
  var peopleArr = nlp.people().data();
  var placeArr = nlp.places().data();
  var organizationArr = nlp.organizations().data();
  // 先进行topic 识别
  for (var k = 0; k < 3; k++) {
    var tempArr = [];
    if (k == 0) {
      tempArr = peopleArr;
      wordType ='people';
    } else if (k == 1) {
      tempArr = placeArr;
      wordType ='place';
    } else if (k == 2) {
      tempArr = organizationArr;
      wordType ='organization';
    }
    for (var i = 0; i < tempArr.length; i++) {
      var text = tempArr[i].text;
      text = deleteSpecialChara(text);
      var textArr = text.split(' ');
      for (var j = 0; j < textArr.length; j++) {
        var smallText = textArr[j];
        smallText = deleteSpecialChara(smallText);
        if (word == smallText) {
          // 查看确定的单词是否在句子中
          realIndex = data.indexOf(text, begin);
          var count = 0;
          var isFind = true;
          while (realIndex < 0) {
            begin --;
            count ++;
            realIndex = data.indexOf(text, begin);
            if (count == text.length) {
              realIndex = 0;
              isFind = false;
            }
          }
          if (isFind) {
            word = text;
            root = text;
            return [word, root, realIndex, wordType];
          }
        }
      }
    }
  }

  realIndex = data.indexOf(word, begin);
  var object = null;
  wordType = 'normal';
  // 名词单复数
  var nounObjectArr = nlp.nouns().toSingular().data();
  for (ii = 0; ii < nounObjectArr.length; ii++) {
      object = nounObjectArr[ii];
      if (word == object.plural) {
        root = object.singular;
        return [word, root, realIndex, wordType];
      }
  }

  // 动词的各种形态
  var verbObjectArr = nlp.verbs().conjugate();
  for (ii = 0; ii < verbObjectArr.length; ii++) {
    object = verbObjectArr[ii];
    if (word == object.PastTense || word == object.PresentTense || word == object.PerfectTense || word == object.Pluperfect || word == object.Gerund) {
      root = object.Infinitive;
      return [word, root, realIndex, wordType];
    }
  }

  root = word.toLowerCase();
  return [word, root, realIndex, wordType];
}
