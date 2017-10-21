/*
 * spa.js
 * Root namespace module 根控件模块
*/

/*jslint           browser : true,   continue : true,
  devel  : true,    indent : 2,       maxerr  : 50,
  newcap : true,     nomen : true,   plusplus : true,
  regexp : true,    sloppy : true,       vars : false,
  white  : true
*/
/*global $, spa */ /* 告诉JSLint，spa和$是全局变量。 */

var spa = (function () {
  var initModule = function ( $container ) {
    spa.shell.initModule( $container );
  };

  return { initModule: initModule };
}());
