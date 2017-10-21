/*
 * spa.shell.js
 * Shell module for SPA
*/

/*jslint         browser : true, continue : true,
  devel  : true, indent  : 2,    maxerr   : 50,
  newcap : true, nomen   : true, plusplus : true,
  regexp : true, sloppy  : true, vars     : false,
  white  : true
*/
/*global $, spa */ 

spa.shell = (function () {
  /* 声明所有在名字空间（Module Scope）内可用的变量 */
  var
    configMap = { // 把静态配置值放在configMap变量中
      // 定义给uriAnchor使用的映射用于验证
      anchor_schema_map : {
        chat  : { open : true, closed : true }
      },
      main_html : String() // 缩进HTML字符串。易于理解易于维护
        + '<div class="spa-shell-head">'
          + '<div class="spa-shell-head-logo"></div>'
          + '<div class="spa-shell-head-acct"></div>'
          + '<div class="spa-shell-head-search"></div>'
        + '</div>'
        + '<div class="spa-shell-main">'
          + '<div class="spa-shell-main-nav"></div>'
          + '<div class="spa-shell-main-content"></div>'
        + '</div>'
        + '<div class="spa-shell-foot"></div>'
        + '<div class="spa-shell-chat"></div>'
        + '<div class="spa-shell-modal"></div>',
      // 开发人员可以配置滑块运动的速度和高度，在模块配置映射中保存收起和展开的时间，高度和title。 
      chat_extend_time     : 1000,
      chat_retract_time    : 300,
      chat_extend_height   : 450,
      chat_retract_height  : 15,
      chat_extended_title  : 'Click to retract',
      chat_retracted_title : 'Click to extend'
    },
    stateMap  = { // 将在整个模块中共享的动态信息放在stateMap变量中
      $container        : null,
      anchor_map        : {}, // 将当前的锚的值保存在表示模块状态的映射中：stateMap.anchor_map
      is_chat_retracted : true
    },
    jqueryMap = {}, // 将jQuery集合缓存在jqueryMap中 

    copyAnchorMap,    setJqueryMap,   toggleChat, // 声明这三个额外的方法
    changeAnchorPart, onHashchange,
    onClickChat,      initModule;
  //----------------- END MODULE SCOPE VARIABLES ---------------

  //------------------- BEGIN UTILITY METHODS ------------------
  // Returns copy of stored anchor map; minimizes overhead
  // 使用jQuery的extend() 工具方法来复制对象，这是必须的，因为所有的JavaScript对象都是按照引用传递的，正确复制一个对象不是件容易的事
  copyAnchorMap = function () {
    return $.extend( true, {}, stateMap.anchor_map );
  };
  //-------------------- END UTILITY METHODS -------------------

  //--------------------- BEGIN DOM METHODS --------------------
  // 将创建和操作页面元素的函数放在DOM Methods区块中
  // Begin DOM method /setJqueryMap/ 
  // 使用setJqueryMap来缓存jQuery集合。可以减少jQuery对文档的遍历次数，提高性能
  setJqueryMap = function () {
    var $container = stateMap.$container;

    jqueryMap = { // 将聊天模块的jQuery集合缓存到jqueryMap中
      $container : $container,
      $chat      : $container.find( '.spa-shell-chat' )
    };
  };
  // End DOM method /setJqueryMap/

  // Begin DOM method /toggleChat/
  // Purpose   : Extends or retracts chat slider
  // Arguments :
  //   * do_extend - if true, extends slider; if false retracts
  //   * callback  - optional function to execute at end of animation
  // Settings  :
  //   * chat_extend_time, chat_retract_time
  //   * chat_extend_height,   chat_retract_height
  // Returns   : boolean
  //   * true  - slider animation activated
  //   * false - slider animation not activated
  // State     : sets stateMap.is_chat_retracted
  //   * true  - slider is retracted
  //   * false - slider is extended
  //
  toggleChat = function ( do_extend, callback) {
    var
      px_chat_ht = jqueryMap.$chat.height(),
      is_open    = px_chat_ht === configMap.chat_extend_height,
      is_closed  = px_chat_ht === configMap.chat_retract_height,
      is_sliding = ! is_open && ! is_closed;

    // 避免同时展开和收起，所以当滑块在运动时拒绝其他操作
    if ( is_sliding ) { return false; }

    // 滑块展开的逻辑处理
    // Begin extend chat slider
    if ( do_extend ) {
      jqueryMap.$chat.animate(
        { height : configMap.chat_extend_height },
        configMap.chat_extend_time,
        function () {
          // 修改展开的title值
          jqueryMap.$chat.attr(
            'title', configMap.chat_extended_title
          );
          // 滑块状态设置
          stateMap.is_chat_retracted = false;
          // 动画完成后的回调函数
          if ( callback ) { callback( jqueryMap.$chat ); }
        }
      );
      return true;
    }
    // End extend chat slider

    // 滑块收起的逻辑处理
    // Begin retract chat slider
    jqueryMap.$chat.animate(
      { height : configMap.chat_retract_height },
      configMap.chat_retract_time,
      function () {
        jqueryMap.$chat.attr(
         'title', configMap.chat_retracted_title
        );
        stateMap.is_chat_retracted = true;
        if ( callback ) { callback( jqueryMap.$chat ); }
      }
    );
    return true;
    // End retract chat slider
  };
  // End DOM method /toggleChat/

  // Begin DOM method /changeAnchorPart/
  // Purpose  : Changes part of the URI anchor component
  // Arguments:
  //   * arg_map - The map describing what part of the URI anchor
  //     we want changed.
  // Returns  : boolean
  //   * true  - the Anchor portion of the URI was update
  //   * false - the Anchor portion of the URI could not be updated
  // Action   :
  //   The current anchor rep stored in stateMap.anchor_map.
  //   See uriAnchor for a discussion of encoding.
  //   This method
  //     * Creates a copy of this map using copyAnchorMap().
  //     * Modifies the key-values using arg_map.
  //     * Manages the distinction between independent
  //       and dependent values in the encoding.
  //     * Attempts to change the URI using uriAnchor.
  //     * Returns true on success, and false on failure.
  //
  // 添加changeAnchorPart工具方法对锚进行原子更细。它更改一个映射是想更改的内容，比如{chat: 'open'}
  // 只会更新锚组件中的这个指定键所对应的值
  changeAnchorPart = function ( arg_map ) {
    var
      anchor_map_revise = copyAnchorMap(),
      bool_return       = true,
      key_name, key_name_dep;

    // Begin merge changes into anchor map
    KEYVAL:
    for ( key_name in arg_map ) {
      if ( arg_map.hasOwnProperty( key_name ) ) {

        // skip dependent keys during iteration
        if ( key_name.indexOf( '_' ) === 0 ) { continue KEYVAL; }

        // update independent key value
        anchor_map_revise[key_name] = arg_map[key_name];

        // update matching dependent key
        key_name_dep = '_' + key_name;
        if ( arg_map[key_name_dep] ) {
          anchor_map_revise[key_name_dep] = arg_map[key_name_dep];
        }
        else {
          delete anchor_map_revise[key_name_dep];
          delete anchor_map_revise['_s' + key_name_dep];
        }
      }
    }
    // End merge changes into anchor map

    // Begin attempt to update URI; revert if not successful
    // 如果不能通过模式（schema）验证就不设置锚（不然会抛出异常）。大发生这种情况时把锚组件的状态回滚到它之前的状态
    try {
      // 通过了设置锚
      $.uriAnchor.setAnchor( anchor_map_revise );
    }
    catch ( error ) {
      // replace URI with existing state
      // 出错的话就回滚到之前状态
      $.uriAnchor.setAnchor( stateMap.anchor_map,null,true );
      bool_return = false;
    }
    // End attempt to update URI...

    return bool_return;
  };
  // End DOM method /changeAnchorPart/
  //--------------------- END DOM METHODS ----------------------

  //------------------- BEGIN EVENT HANDLERS -------------------
  // Begin Event handler /onHashchange/
  // Purpose  : Handles the hashchange event
  // Arguments:
  //   * event - jQuery event object.
  // Settings : none
  // Returns  : false
  // Action   :
  //   * Parses the URI anchor component
  //   * Compares proposed application state with current
  //   * Adjust the application only where proposed state
  //     differs from existing
  //
  // 添加onHashchange事件处理程序来处理URL锚变化。使用uriAnchor插件来将锚转化为映射，与之前的状态比较，一遍确定要采取的动作。
  // 如果提议的锚变化无效，将锚重置为之前的值
  onHashchange = function ( event ) {
    var
      anchor_map_previous = copyAnchorMap(),
      anchor_map_proposed,
      _s_chat_previous, _s_chat_proposed,
      s_chat_proposed;

    // attempt to parse anchor
    try { anchor_map_proposed = $.uriAnchor.makeAnchorMap(); }
    catch ( error ) {
      $.uriAnchor.setAnchor( anchor_map_previous, null, true );
      return false;
    }
    stateMap.anchor_map = anchor_map_proposed;

    // convenience vars
    _s_chat_previous = anchor_map_previous._s_chat;
    _s_chat_proposed = anchor_map_proposed._s_chat;

    // Begin adjust chat component if changed
    if ( ! anchor_map_previous
     || _s_chat_previous !== _s_chat_proposed
    ) {
      s_chat_proposed = anchor_map_proposed.chat;
      switch ( s_chat_proposed ) {
        case 'open'   :
          toggleChat( true );
        break;
        case 'closed' :
          toggleChat( false );
        break;
        default  :
          toggleChat( false );
          delete anchor_map_proposed.chat;
          $.uriAnchor.setAnchor( anchor_map_proposed, null, true );
      }
    }
    // End adjust chat component if changed

    return false;
  };
  // End Event handler /onHashchange/

  // 滑动的点击事件的处理逻辑
  // Begin Event handler /onClickChat/
  onClickChat = function ( event ) {
    // 修改onClickChat事件处理程序，只修改锚的chat参数
    changeAnchorPart({
      chat : ( stateMap.is_chat_retracted ? 'open' : 'closed' )
    });
    return false;
  };
  // End Event handler /onClickChat/
  //-------------------- END EVENT HANDLERS --------------------

  //------------------- BEGIN PUBLIC METHODS -------------------
  // Begin Public method /initModule/
  // 创建initModule公开方法，用于初始化模块
  initModule = function ( $container ) {
    // load HTML and map jQuery collections
    stateMap.$container = $container;
    $container.html( configMap.main_html );
    setJqueryMap();

    // initialize chat slider and bind click handler
    // 初始化聊天滑块，绑定点击事件和设置悬停文字
    stateMap.is_chat_retracted = true;
    jqueryMap.$chat
      .attr( 'title', configMap.chat_retracted_title )
      .click( onClickChat );

    // configure uriAnchor to use our schema
    // 配置uriAnchor插件，用于检测模式（schema）
    $.uriAnchor.configModule({
      schema_map : configMap.anchor_schema_map
    });

    // Handle URI anchor change events.
    // This is done /after/ all feature modules are configured
    // and initialized, otherwise they will not be ready to handle
    // the trigger event, which is used to ensure the anchor
    // is considered on-load
    //
    $(window)
      // 绑定hashchange事件处理程序并立即触发它，这样模块在初始化加载时就会处理书签
      .bind( 'hashchange', onHashchange )
      .trigger( 'hashchange' );

  };
  // End PUBLIC method /initModule/

  // 显式地导出公开方法，以映射（map）的形式返回。目前可用的只有initModule。
  return { initModule : initModule };
  //------------------- END PUBLIC METHODS ---------------------
}());
