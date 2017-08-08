$(function() {
  // 对div标签上的点击事件的监控
  $('div').on('click', function(e) {
    // 通过点击事件获得相关信息
    var arr = getInformationWithTapClick(e);
    console.log(arr);
  });
});

// 是快读模式吗 false 不是，true 是
var isFastRead = false;
// 节点数组
var nodeArr = [];

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
    // 去除字符左右的特殊字符 得到更为准确的单击位置的单词
    word = deleteSpecialChara(word);
    // 重新计算准确的单词所在的位置
    // 防止此单词在这个文本节点中，出现多次，然后直接获取这个单词位置不对问题。所以以单词所处的位置为计算的开始位置
    var realIndex = data.indexOf(word, begin); // 真实的开始位置
    // 处理节点
    handleTapNode(textNode, word, realIndex);
    // 范围单击的位置，记录然后等待下次的查找与修改
    return [event.clientX, event.clientY]; // 返回记录当前
}

// Whitespace checker
function isW(s) {
    return /[ \f\n\r\t\v\u00A0\u2028\u2029]/.test(s);
}

// 处理字符串前后的特殊字符
function deleteSpecialChara(word) {
    var arr = ['\ ', '\~', '\`', '\!', '\！', '\@', '\#', '\$', '\￥', '\%',
               '\^', '\&', '\*', '\(', '\（', '\)', '\）', '\_', '\+', '\=',
               '\|', '\\', '\[', '\]', '\{', '\}', '\;', '\；', '\:', '\：',
               '\"', '\'', '\‘', '\,', '\，', '\<', '\.', '\>', '\/', '\?',
               '\”', '\“', '\n'];

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
function handleTapNode(node, word, index) {
  var mean = getMean(word);
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
  } else {
    var nextNode = node.nextSibling;
    var data = node.textContent;
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
  nodeArr = new Array();
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
      var nodeText = getNodeText(node);
      var isHas = isHasAEnglishLetters(nodeText);
      if (isHas) {
        // 处理这个节点
        handleFastReadLogic(nextNode);
      }
    }
  } else {
    // 如果节点有内容 则处理
    var nodeText = getNodeText(node);
    var isHas = isHasAEnglishLetters(nodeText);
    if (isHas) {
      // 处理这个节点
      // handleFastNode(node);
      nodeArr.push(node);
    }
  }
}

// 处理开启快读相应节点的处理
function handleFastNode(node) {
  // 获得节点的文本内容
  var nodeText = node.textContent;
  // 对文本内容进行解析获得准确的单词或者此单词的root，（类似is = be）。现在只做简单的切割
  var arr = nodeText.split(' ');
  // 本节点将被切割为的子节点数组
  var childNodeArr = new Array();
  var begin = 0;
  var end = 0;
  for (var i = 0; i < arr.length; i++) {
    // 得到单词
    var text = arr[i];
    // 辨别是否包含字母
    var isHas = isHasAEnglishLetters(text);
    if (isHas) {
      // 处理单词左右的特殊字符
      text = deleteSpecialChara(text);
      // 1. 这个词是否在生词本中
      var isNew = isNewWord(text);
      if (isNew) {
        var realIndex = nodeText.indexOf(text, begin);
        // 先处理之前可能存在的textNode
        if (realIndex != end) {
          // 1.3 如果不在，则将这个mark之间的作为一个textNode节点
          var otherText = nodeText.substring(end, realIndex);
          var textNode = getTextNode(otherText);
          childNodeArr.push(textNode);
        }
        // 1.2 如果在，找到这个单词的词义
        var mean = getMean(text);
        // 1.2.1 将这个单词及词义，生成一个mark节点，此节点的class为classFast
        var markNode = getMarkNode(text, mean);
        childNodeArr.push(markNode);
        end = (realIndex + text.length);
        begin = end;
      } else {
        var realIndex = nodeText.indexOf(text, begin);
        begin = (realIndex + text.length);
      }
    }
  }

  // 循环结束后，判断end是否小于节点内容的长度，小于说明从end到结束这个段落还未处理
  if (end < nodeText.length) {
    var otherText = nodeText.substring(end, nodeText.length);
    var textNode = getTextNode(otherText);
    childNodeArr.push(textNode);
  }

  var nextNode = node;
  var parentNode = node.parentNode;
  // 处理完成后，顺序加入父节点
  for (var i = childNodeArr.length - 1; i >= 0 ; i--) {
    var appendNode = childNodeArr[i];
    parentNode.insertBefore(appendNode, nextNode);
    nextNode = appendNode;
  }
  parentNode.removeChild(node);
}

// 是否是生词
function isNewWord(word) {
  // 此处依据数据库的查询结果，现在是简单测试
  return confirm(word);
  // var arr = ['strong', 'this', 'paragraph', 'story', 'main', 'the'];
  // for (var i = 0; i < arr.length; i++) {
  //   var text = arr[i];
  //   if (word == text) {
  //     return true;
  //   }
  // }
  // return false;
}

// 获得单词的词义
function getMean(word) {
  // 此处应该从数据库中获取
  var mean = prompt(word, '无');
  return mean;
  // return '测试';
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
  var patt = new RegExp('([A-Za-z])');
  var isHas = patt.test(string);
  return isHas;
}
