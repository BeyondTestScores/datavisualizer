$( document ).on('turbolinks:load', function() {
  $('.category-selector a').click(function(event) {
    event.preventDefault();
    const categoryAnchor = event.currentTarget;
    const {categoryId} = categoryAnchor.dataset;
    $('.category-selector-target').val(categoryId);

    const category = $(categoryAnchor).closest('.category');
    category.find('.question').each(function(index, questionElement) {
      const {questionId} = questionElement.dataset;
      $('#survey_question_ids_' + questionId).prop( "checked", true );

    })

    return false;
  });

  $('.question-selector a').click(function(event) {
    event.preventDefault();
    const {questionId} = event.currentTarget.dataset;
    $('#survey_question_ids_' + questionId).prop( "checked", true );
    return false;
  });
});
