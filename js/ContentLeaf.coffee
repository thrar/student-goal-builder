define [
  "text!html/content-item.html"
], (template) ->

  class NameView extends Marionette.ItemView
    tagName: "span"
    template: "{{text}}"
    globalName: undefined

    events:
      "click": -> @trigger "toggle"

    serializeData: ->
      return text: if @globalName?.length > 0 then @globalName else @model.get "text"


    getText: ->
      return @model.get "text"


    useGlobals: (globals) ->
      @globalName = globals.name
      @render()


    clearAll: ->
      @globalName = undefined
      @render()



  class TextView extends Marionette.ItemView
    tagName: "span"
    template: "{{text}}"

    events:
      "click": -> @trigger "toggle"

    getText: ->
      return @model.get "text"


    clearAll: ->



  class EnterTextView extends Marionette.ItemView
    tagName: "input"
    attributes: ->
      text = @model.get "text"
      if 0 is text.indexOf "["
        return placeholder: text.substring 1, text.length - 1
      return {}
    template: " "

    events:
      "click": -> @trigger "check"
      "input": -> @trigger "check"


    getText: ->
      val = @$el.val()
      return if val.length > 0 then val else @model.get "text"


    clearAll: -> @$el.val ""



  class SelectItem extends Marionette.ItemView
    tagName: "option"
    template: "{{value}}"



  class SelectView extends Marionette.CollectionView
    tagName: "select"
    childView: SelectItem

    events:
      "mousedown": -> @trigger "check"
      "change": -> @trigger "check"


    initialize: ->
      text = @model.get "text"
      content = text.substring 1, text.length - 1
      options = content.split "/"
      @collection = new Backbone.Collection _.map options, (option) -> value: option


    getText: ->
      return @$el.val()


    clearAll: -> @$el.val @children.first().model.get "value"



  class ContentLeaf extends Marionette.CompositeView
    tagName: "li"
    className: "list-group-item leaf"
    template: template
    childViewContainer: ".text-item"

    ui:
      checkbox: "input"

    events:
      "click input": "updateText"
      "click": (e) ->
        if e.target is @el
          @ui.checkbox.prop "checked", !@hasChecked()
          @updateText()


    childEvents:
      "toggle": ->
        @ui.checkbox.prop "checked", !@hasChecked()
        @updateText()
      "check": ->
        @ui.checkbox.prop "checked", true
        @updateText()


    initialize: ->
      items = @parseParts @model.get "text"
      @collection = new Backbone.Collection(items)


    parseParts: (text) ->
      parts = []
      mode = "text"
      current = ""
      for char in text
        switch char
          when "["
            if mode is "bracket"
              current += char
            else
              if current.length > 0 then parts.push text: current, mode: mode
              mode = "bracket"
              current = char
          when "]"
            if mode is "bracket"
              parts.push text: current + char, mode: mode
              current = ""
              mode = "text"
            else
              current += char
          when "_"
            if mode is "field"
              current += char
            else
              if current.length > 0 then parts.push text: current, mode: mode
              mode = "field"
              current = char
          else
            if mode is "field"
              parts.push text: current, mode: mode
              mode = "text"
              current = char
            else
              current += char
      if current.length > 0 then parts.push text: current, mode: mode
      return parts


    childView: (options) ->
      model = options.model
      text = model.get "text"
      switch model.get "mode"
        when "bracket"
          if text.substring(1, text.length - 1).toLowerCase() in [ "he/she", "his/her", "her/his", "him/her", "himself/herself", "herself/himself" ] then return new TextView options
          if text.toLowerCase() is "[name]" then return new NameView options
          if text.indexOf("/") > 0 then return new SelectView options
          return new EnterTextView options
        when "field" then return new EnterTextView options
      return new TextView options


    getText: ->
      if !@hasChecked() then return ""
      text = ""
      @children.each (child) ->
        text += child.getText()
      return $.trim text


    hasChecked: ->
      return @ui.checkbox.is(":checked")


    updateText: ->
      if @hasChecked() then @$el.addClass "list-group-item-info" else @$el.removeClass "list-group-item-info"
      @trigger "updatetext"


    clearAll: ->
      @ui.checkbox.prop "checked", false
      @$el.removeClass "list-group-item-info"
      @children.each (child) ->
        child.clearAll()


    useGlobals: (globals) ->
      @children.each (child) ->
        child.useGlobals? globals