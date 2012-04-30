$ = jQuery.sub()

class App.TemplateUI extends App.Controller
  events:
    'click [data-type=template_save]':   'create',
    'click [data-type=template_select]': 'select',
    'click [data-type=template_delete]': 'delete',

  constructor: ->
    super

    # fetch item on demand
    fetch_needed = 1
#    if App.User.exists(@user_id)
#      @user = App.User.find(@user_id)
#      @log 'exists', @user
#      fetch_needed = 0
#      @render()

    if fetch_needed
      @reload()

  reload: =>
      App.Template.bind 'refresh', =>
        @log 'loading....'
        @render()
        App.Template.unbind 'refresh'
      App.Template.fetch()

  render: =>
    @configure_attributes = [
      { name: 'template_id', display: '', tag: 'select', multiple: false, null: true, nulloption: true, relation: 'Template', class: 'span2', default: @template_id  },
    ]
    form = @formGen( model: { configure_attributes: @configure_attributes, className: '' } )

    template = {}
    if @template_id
      template = App.Template.find(@template_id)

    # insert data
    @html App.view('template')(
      form:     form,
      template: template,
    )


  delete: (e) =>
    e.preventDefault()

    # get params
    params = @formParam(e.target)
    template = App.Template.find( params['template_id'] )
    template.destroy()
    @template_id = undefined
    @render()

  select: (e) =>
    e.preventDefault()

    # get params
    params = @formParam(e.target)

    template = App.Template.find( params['template_id'] )
    Spine.trigger 'ticket_create_rerender', template.attributes()

  create: (e) =>
    e.preventDefault()
    
    # get params
    params = @formParam(e.target)
    name = params['template_name']
#    delete params['template_name']
    
    template = App.Template.findByAttribute( 'name', name )
    if !template
      template = new App.Template

    options = params
    template.load(
      name:    params['template_name']
      options: options
    )

    # validate form
    errors = template.validate()
    
    # show errors in form
    if errors
      @log 'error new', errors
    else
      template.save(
        success: (r) =>
          @template_id = r.id
          @render()

        error: =>
          @log 'save failed!'
      )
