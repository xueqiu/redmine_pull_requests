function change_tabs() {
  tabs = $('#smalltabs').find('a');
  tabs.each(function() {
    $(this).click(function(e) {
      tabs.each(function(){
        bucket = '#' + this.name + '_bucket';
        if(this == e.target) {
          $(bucket).show();
          $(this).addClass('selected');
        } else {
          $(bucket).hide();
          $(this).removeClass('selected');
        }
      });
    });
  });
}

$(document).ready(change_tabs);