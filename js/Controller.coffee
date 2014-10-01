define [
], ->

  class Controller extends Marionette.Controller

    initialize: (options) ->
      @content = options.content
      @result = options.result
      @listenTo @content, "updatetext", @onTextUpdate
      @listenTo @result, "updateglobals", @onTextUpdate
      @listenTo @result, "clearall", -> @content.clearAll()


    onTextUpdate: ->
      values = @result.getGlobalValues()
      @content.useGlobals values
      @result.setText @processPlaceholders @content.getText(), values


    processPlaceholders: (text, values) ->
      if values.gender?
        text = text.replace /\. \[Name\]/g, if values.gender is "male" then ". He" else ". She"
        text = text.replace /\[He\/She\]/g, if values.gender is "male" then "He" else "She"
        text = text.replace /\[he\/she\]/g, if values.gender is "male" then "he" else "she"
        text = text.replace /\[His\/Her\]/g, if values.gender is "male" then "His" else "Her"
        text = text.replace /\[his\/her\]/g, if values.gender is "male" then "his" else "her"
        text = text.replace /\[Her\/His\]/g, if values.gender is "male" then "His" else "Her"
        text = text.replace /\[her\/his\]/g, if values.gender is "male" then "his" else "her"
        text = text.replace /\[Him\/Her\]/g, if values.gender is "male" then "Him" else "Her"
        text = text.replace /\[him\/her\]/g, if values.gender is "male" then "him" else "her"
        text = text.replace /\[herself\/himself\]/g, if values.gender is "male" then "himself" else "herself"
        text = text.replace /\[himself\/herself\]/g, if values.gender is "male" then "himself" else "herself"

      if values.name?.length > 0
        text = text.replace /\[Name\]/g, values.name

      text = text.replace /\ a\ (a|e|i|o|u)/g, " an $1"

      return $.trim text