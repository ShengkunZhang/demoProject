$(function() {
    // // wrap words in spans
    // $('div').each(function() {
    //     var $this = $(this);
    //     $this.html($this.text().replace(/\b(\w+)\b/g, "<span>$1</span>"));
    // });

    // // bind to each span
    // $('div span').hover (
    //     function() {
    //       $('#word').text($(this).css('background-color','#ffff66').text());
    //     },
    //     function() {
    //       $('#word').text('');
    //       $(this).css('background-color','');
    //     }
    // );

    $('body').on('click', function(e){
      // var origin = getMousePos(e);
      // var arr = getWordAtPoint(e.target, origin.x, origin.y);
      // // var arr = getWordAtPoint(e.target);
      // var selectString = arr[0];
      // var rect = arr[1];
      // console.log(selectString);
      // console.log(rect);
      // $('#word').text(selectString);

      // Return the word the cursor is over
      var arr = getFullWord(e);
      var selectString = arr[0];
      var rect = arr[1];
      var allString = arr[2];
      console.log(selectString);
      console.log(allString);
      console.log(rect);
    });

});

// Get the full word the cursor is over regardless of span breaks
function getFullWord(event) {
   var i, begin, end, range, textNode, offset;

  // Firefox, Safari
  // REF: https://developer.mozilla.org/en-US/docs/Web/API/Document/caretPositionFromPoint
  if (document.caretPositionFromPoint) {
    range = document.caretPositionFromPoint(event.clientX, event.clientY);
    textNode = range.offsetNode;
    offset = range.offset;

    // Chrome
    // REF: https://developer.mozilla.org/en-US/docs/Web/API/document/caretRangeFromPoint
  } else if (document.caretRangeFromPoint) {
    range = document.caretRangeFromPoint(event.clientX, event.clientY);
    textNode = range.startContainer;
    offset = range.startOffset;
  }

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

  var arr = getChildIndex(textNode);
  var preLength = arr[0];
  // 找到这个单词所在的句子
  var allText = arr[1];
  var otherWord = allText.substring(preLength + begin, preLength + end + 1);

  // 得到点击的单词
  var word = data.substring(begin, end + 1);
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
      // console.log(arrStr);
      break;
    }
  }

  // // 获取词性上不靠谱
  // var rawWord = nlp.verb(word).conjugate().infinitive;
  // console.log('=========' + rawWord);

  return [word, rect, selectSentence];
}

// 获得选中单词的frame(x, y, width, height)
function getRectForSelectedText() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rect = range.getBoundingClientRect();
    return "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
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

// REF: http://stackoverflow.com/questions/3127369/how-to-get-selected-textnode-in-contenteditable-div-in-ie
function getChildIndex(node) {
  var allText = null;
  var length = 0; // 在这个节点之前的所有节点文字的长度
  var preNode = null; // 上一个节点
  var i = 0; // 当前节点之前节点的个数
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
    i++;
  }
  return [length, allText];
}


// function getMousePos(event) {
//     var e = event || window.event;
//     var scrollX = document.documentElement.scrollLeft || document.body.scrollLeft;
//     var scrollY = document.documentElement.scrollTop || document.body.scrollTop;
//     var x = e.pageX || e.clientX + scrollX;
//     var y = e.pageY || e.clientY + scrollY;
//     //alert('x: ' + x + '\ny: ' + y);
//     return { 'x': x, 'y': y };
// }
//
// function getWordAtPoint(elem, x, y) {
//   if(elem.nodeType == elem.TEXT_NODE) {
    // var range = elem.ownerDocument.createRange();
    // range.selectNodeContents(elem);
    // var currentPos = 0;
    // var endPos = range.endOffset;
    // while(currentPos+1 < endPos) {
    //   range.setStart(elem, currentPos);
    //   range.setEnd(elem, currentPos+1);
    //   if(range.getBoundingClientRect().left <= x && range.getBoundingClientRect().right  >= x &&
    //      range.getBoundingClientRect().top  <= y && range.getBoundingClientRect().bottom >= y) {
    //         range.expand("word");
    //         var ret = range.toString();
    //         var rect = getRectForRange(range);
    //         range.detach();
    //         return([ret, rect]);
    //   }
    //   currentPos += 1;
    // }
//   } else {
//     for(var i = 0; i < elem.childNodes.length; i++) {
//       var range = elem.childNodes[i].ownerDocument.createRange();
//       range.selectNodeContents(elem.childNodes[i]);
//       if(range.getBoundingClientRect().left <= x && range.getBoundingClientRect().right  >= x &&
//          range.getBoundingClientRect().top  <= y && range.getBoundingClientRect().bottom >= y) {
//         range.detach();
//         return(getWordAtPoint(elem.childNodes[i], x, y));
//       } else {
//         range.detach();
//       }
//     }
//   }
//   return(null);
// }
