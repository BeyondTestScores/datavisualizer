setTimeout(function() {
  $('.category-selector a').click(function(event) {
    event.preventDefault();
    const {categoryId} = event.currentTarget.dataset;
    $('.category-selector-target').val(categoryId);
    return false;
  });
}, 1000);
