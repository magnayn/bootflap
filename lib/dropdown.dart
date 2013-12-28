import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

@CustomTag('bf-dropdown')
class BootflapDropdown extends PolymerElement {
  
  StreamSubscription<MouseEvent> _listen;
  MouseEvent _ignore;
  
  BootflapDropdown.created() : super.created() {
  }
  
  void enteredView() {
    super.enteredView();   

    _dropTitle.onClick.listen( onClickResponder );
    this.onKeyDown.listen( onKeyResponder );
  }
  
  Element get _dropMenu {   
    NodeList items3 = shadowRoot.querySelector(".menu").getDistributedNodes();   
    return items3.first;
  }
  
  Element get _dropTitle {
    return shadowRoot.querySelector(".title");
  }
  
  Element get _dropTitleLink {
    return _dropTitle.getDistributedNodes()[0].shadowRoot.querySelector("a");
  }  
  
  void onKeyResponder(KeyboardEvent ke) {

    final int keyCode = ke.keyCode;
    
    if (keyCode != KeyCode.UP && keyCode != KeyCode.DOWN && keyCode != KeyCode.ESC)
      return;
    
    ke.preventDefault();
    ke.stopPropagation();
    
    //if (elem.matches('.disabled, :disabled'))
    //  return;
    

    final bool isActive = _dropMenu.classes.contains('open');
    
    if (!isActive || (isActive && keyCode == KeyCode.ESC)) {
      if (keyCode == KeyCode.ESC) {
          _dropMenu.focus();      
          _dropMenu.click(); 
        }
      
      return;
    }
    
    //NodeList items = shadowRoot.querySelector(".menu").getDistributedNodes();

    var items = _dropMenu.childNodes;
    
    // TODO: can you combine the above with the not(.divider) ? CSS filter on
    // a list?

    List<Element> $items = new List<Element>();
    for (Node e in items) {

      // TODO: isHidden ?
      if (e is Element && !e.classes.contains("divider")) {
        Element li = e.shadowRoot.querySelector('content');
        
        NodeList ci = li.getDistributedNodes();
        Element a = queryTagList(ci, "A");
        if ( a != null)
          $items.add(a);
      }
    }

    if ($items.isEmpty)
      return;

    int index = _indexWhere($items, (Element e) => e.matches(':focus'));

    if (keyCode == KeyCode.UP && index > 0)
      index--; // up
    else if (keyCode == KeyCode.DOWN && index < $items.length - 1)
      index++; // down
    if (index == -1)
      index = 0;
    

    // TODO: $($items[index])[0].focus();
    $items[index].focus();
  }
  
  static Element queryTagList(NodeList items, String tagName) {
    for(Node e in items) {
      if( e is Element && e.tagName == tagName ) {
        return e;
      }
    }
    return null;
  }
  
  void clickOutside(MouseEvent e) {
   if( e == _ignore ) {
     _ignore = null;
     return;     
   }
   
   _dropMenu.classes.remove('open');
   _listen.cancel();
   _listen = null; 
  }
  
  void onClickResponder(MouseEvent e) {

    
    // TODO: Fire some kind of event.
    
    if (e.defaultPrevented)
      return;
        
    if( _dropMenu.classes.toggle('open') ) {
      // We've dropped down our list. Register for clicks elsewhere, but
      // also note which event we've already processed - we can't look
      // at event.target to figure this out because that will be masked
      // by the shadowed dom.
      _listen = document.onClick.listen( clickOutside );
      _ignore = e;

    } else {

    }
    
    _dropTitleLink.focus();
    
    
  }
  static int _indexWhere(List<Element> elems, bool f(Element elem)) {
    int i = 0;
    for (Element e in elems) {
      if (f(e))
        return i;
      i++;
    }
    return -1;
  }
  /**
   * Refer to Jquery
   */
  static bool isHidden(Element e) {
    //if (e.style.display != 'none' && e.style.visibility != 'hidden')
    //refer to jquery
    return e.offsetWidth <= 0 && e.offsetHeight <= 0;
  }
  
  //bool get applyAuthorStyles => true;
  //bool get resetStyleInheritance => true;

}

