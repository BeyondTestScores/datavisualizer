setTimeout(function() {
  $('.category-selector').click(function(categorySelector) {
    alert("ID: " + $(categorySelector).attr("category_id"));
    return false;
  });
}, 1000);
