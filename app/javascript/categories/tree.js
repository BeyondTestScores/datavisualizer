$( document ).on('turbolinks:load', function() {
  $('.tree-category-selector>a').click(function(event) {
    event.preventDefault();
    const treeCategory = $(event.currentTarget).closest('.tree-category');
    const {treeCategoryId} = treeCategory[0].dataset;
    $('.tree-category-selector-target').val(treeCategoryId);

    var check = !treeCategory.find("input[type=checkbox]").prop("checked");
    treeCategory.find('.tree-category-question-selector').each(function(index, questionElement) {
      const {treeCategoryQuestionId} = questionElement.dataset;
      $("input[name='question-" + treeCategoryQuestionId + "']").prop("checked", check);
      $("#survey_question_ids_" + treeCategoryQuestionId).prop("checked", check)
    })

    return false;
  });

  $('.tree-category-question-selector a').click(function(event) {
    event.preventDefault();
    const {treeCategoryQuestionId} = $(event.currentTarget).closest('.tree-category-question-selector')[0].dataset;
    var check = !$("input[name='question-" + treeCategoryQuestionId + "']").prop("checked");

    $("input[name='question-" + treeCategoryQuestionId + "']").prop("checked", check);
    $('#survey_question_ids_' + treeCategoryQuestionId).prop( "checked", check );
    return false;
  });

  $('.tree-category-question-selector input').click(function(event) {
    const {treeCategoryQuestionId} = $(event.currentTarget).closest('.tree-category-question-selector')[0].dataset;
    var check = $("input[name='question-" + treeCategoryQuestionId + "']").prop("checked");

    $("input[name='question-" + treeCategoryQuestionId + "']").prop("checked", check);
    $('#survey_question_ids_' + treeCategoryQuestionId).prop( "checked", check );
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
