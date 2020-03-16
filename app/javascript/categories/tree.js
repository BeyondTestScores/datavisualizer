$( document ).on('turbolinks:load', function() {
  $('.category-selector>a').click(function(event) {
    event.preventDefault();
    const category = $(event.currentTarget).closest('.category');
    const {categoryId} = category[0].dataset;
    $('.category-selector-target').val(categoryId);

    var check = !category.find("input[type=checkbox]").prop("checked");
    category.find('.question-selector').each(function(index, questionElement) {
      const {questionId} = questionElement.dataset;
      $("input[name='question-" + questionId + "']").prop("checked", check);
      $("#survey_question_ids_" + questionId).prop("checked", check)
    })

    return false;
  });

  $('.question-selector a').click(function(event) {
    event.preventDefault();
    const {questionId} = $(event.currentTarget).closest('.question-selector')[0].dataset;
    var check = !$("input[name='question-" + questionId + "']").prop("checked");

    $("input[name='question-" + questionId + "']").prop("checked", check);
    $('#survey_question_ids_' + questionId).prop( "checked", check );
    return false;
  });

  $('.question-selector input').click(function(event) {
    const {questionId} = $(event.currentTarget).closest('.question-selector')[0].dataset;
    var check = $("input[name='question-" + questionId + "']").prop("checked");

    $("input[name='question-" + questionId + "']").prop("checked", check);
    $('#survey_question_ids_' + questionId).prop( "checked", check );
    return true;
  });

  $("input[name='survey[question_ids][]'").click(function(event) {
    const checkbox = $(event.currentTarget);
    const questionId = checkbox.val();
    var check = checkbox.prop("checked");

    $("input[name='question-" + questionId + "']").prop("checked", check);
    $('#survey_question_ids_' + questionId).prop( "checked", check );
    return true;
  });

});
