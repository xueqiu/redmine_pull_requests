Event.observe(window,'load',function() {

  tabs = $('smalltabs').children
  for (var i = tabs.length - 1; i >= 0; i--) {
    aobj = tabs[i].children[0];
    aobj.observe('click', function(e) {
      for (var i = tabs.length - 1; i >= 0; i--) {
        a = tabs[i].children[0];
        bucket = a.name + "_bucket";
        if(a == e.target) {
          $(bucket).style.display = 'block';
          a.className = 'selected';
        } else {
          $(bucket).style.display = 'none';
          a.className = '';
        }
      }
      return false;
    });    
  };

})