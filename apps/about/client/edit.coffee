_ = require 'underscore'
require '../../../lib/vendor/hulk'
sectionsTemplates = require '../templates/sections.jade'
{ DATA } = sd = require('sharify').data
GeminiForm = require '../../../components/gemini_form/view.coffee'
{ crop } = require '../../../components/resizer/index.coffee'

hulkCallback = (data) ->
  render(data)
  return unless confirm "Are you sure you want to update the about page " +
                        "(these changes can't be undone)?"
  $('.hulk-save').addClass 'is-loading'
  $.ajax
    type: 'POST'
    url: '/about/edit'
    data: data
    error: -> alert "Whoops. Something went wrong, try again. If it doesn't work ask Craig."
    success: -> location.assign '/about'

render = (data) ->
  renderData = JSON.parse(JSON.stringify(data))
  $('#about-edit-example').html sectionsTemplates _.extend renderData,
    crop: crop

initImageUploads = ->
  $('input, textarea').each ->
    return unless $(this).val().match(/\.jpg|\.png/)
    $(this).after("<div class='about-edit-upload-form'>Replace Image</div>")
    $(this).before("<img src='#{$(this).val()}' class='about-preview-image'>")
    new GeminiForm
      el: $form = $(this).next()
      onUploadComplete: (res) =>
        url = res.url + $form.find('[name=key]').val()
          .replace('${filename}', encodeURIComponent(res.files[0].name))
        $(this).val(url).trigger 'keyup'
        $(this).prev('img').attr 'src', url
        $form.removeClass 'is-loading'
    $form.find('input').change -> $form.addClass 'is-loading'

setupArrayAddRemove = ->
  addX = ($el) ->
    $el.append $remove = $ "<button class='about-edit-remove'>✖</button>"
    $remove.click -> $el.remove()
  $('.hulk-array').each ->
    $(this).children('.hulk-array-element').each -> addX $(this)
    $(this).append $button = $ "<button class='avant-garde-button'>Add another</button>"
    $button.click ->
      $(this).before $el = $(this).prev().clone()
      addX $el

module.exports.init = ->
  $.hulk '#about-edit-hulk', DATA, hulkCallback,
    separator: null
    permissions: "values-only"
  $('button').addClass 'avant-garde-button'
  $('#about-edit-hulk *:hidden').remove()
  $('textarea, input').on 'keyup', _.debounce (-> render $.hulkSmash('#about-edit-hulk')), 300
  render(DATA)
  initImageUploads()
  setupArrayAddRemove()