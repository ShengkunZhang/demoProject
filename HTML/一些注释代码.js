// var describeDown = '下面的是HTML5 Web SQL';
// // 处理本地数据库
// var db = openDatabase('sql', '1.0', '本地词典', 1024*1024*10);
// if (db) {
//   console.log('创建成功');
// } else {
//   console.log('创建失败');
// }
//
// db.transaction(function (tx) {
//   tx.executeSql('CREATE TABLE IF NOT EXISTS LOGS (id unique, log)');
//   tx.executeSql('INSERT INTO LOGS (id, log) VALUES (1, "菜鸟教程")');
//   tx.executeSql('INSERT INTO LOGS (id, log) VALUES (2, "www.runoob.com")');
// });
//
// db.transaction(function (tx) {
//    tx.executeSql('SELECT * FROM LOGS', [], function (tx, results) {
//       var len = results.rows.length, i;
//       msg = "<p>查询记录条数: " + len + "</p>";
//       console.log(msg);
//       for (i = 0; i < len; i++){
//          console.log(results.rows.item(i).log);
//       }
//
//    }, null);
// });
//
// // select * from words where word = '%@'
// db.transaction(function (tx) {
//   tx.executeSql(
//     "SELECT * FROM WORDS",
//     [],
//     function (tx, result) { //执行成功的回调函数
//       //在这里对result 做你想要做的事情吧...........
//       console.log(result);
//     },
//     function (tx, error) {
//       console.log('查询失败: ' + error.message);
//     });
//   });
  // // other sql测试
  // var otherDB = new SQL.Database('/Users/zsk/Desktop/demoProject/HTML/jsAndcssKeepSameWithapp/db/demoTest.db');
  // // Prepare a statement
  // var stmt = otherDB.prepare("SELECT * FROM WORDS");
  //
  // while(stmt.step()) { //
  //     var row = stmt.getAsObject();
  //     // [...] do something with the row of result
  //     console.log(row);
  // }


  // // 处理node
  // function handleNode(node, word, index) {
  //   var parentNode = node.parentNode;
  //   if (parentNode.localName == 'mark') { // 如果是mark tag
  //     var grandpaNode = parentNode.parentNode;
  //     // 1. 现在此mark node 之前插入一个textnode
  //     var textNode = document.createTextNode(word);
  //     grandpaNode.insertBefore(textNode, parentNode);
  //     // 2. 删除此mark node
  //     grandpaNode.removeChild(parentNode);
  //   } else {
  //     var nextNode = node.nextSibling;
  //     var data = node.textContent;
  //     // 选中的单词在这个节点中之前的字符即此字符的节点
  //     var beforeString = data.substring(0, index);
  //     var beforeNode = document.createTextNode(beforeString);
  //     // 选中的单词在这个节点中之后的字符即此字符的节点
  //     var afterString = data.substring(index + word.length, data.length);
  //     var afterNode = document.createTextNode(afterString);
  //     // 选中单词的节点
  //     var wordNode = document.createTextNode(word);
  //     var markNode = document.createElement('mark');
  //     markNode.setAttribute('data-entity', '测试');
  //     markNode.appendChild(wordNode);
  //
  //     // 删除此节点本身
  //     parentNode.removeChild(node);
  //     if (nextNode) { // 此节点是否有下一个相邻节点
  //       // 插入在此节点之前 insertBefore
  //       parentNode.insertBefore(afterNode, nextNode);
  //       parentNode.insertBefore(markNode, afterNode);
  //       parentNode.insertBefore(beforeNode, markNode);
  //     } else {
  //       // 直接 appendChild
  //       parentNode.appendChild(beforeNode);
  //       parentNode.appendChild(markNode);
  //       parentNode.appendChild(afterNode);
  //     }
  //   }
  // }
