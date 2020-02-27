alert('tree');
setTimeout(function() {
  alert($('.category-selector').length);
  $('.category-selector').click(function() {
    alert('hi');
  });
}, 1000);
