_ = require 'underscore'
sd = require('sharify').data
qs = require 'querystring'
Backbone = require 'backbone'
StepView = require './step.coffee'
mediator = require '../../../../lib/mediator.coffee'
Followable = require '../mixins/followable.coffee'
Partner = require '../../../../models/partner.coffee'
LocationModalView = require '../../components/location_modal/index.coffee'
{ FollowButton, Following } = require '../../../../components/follow_button/index.coffee'
Profiles = require '../../../../collections/profiles.coffee'
analytics = require '../../../../lib/analytics.coffee'
suggestedTemplate = -> require('../../templates/suggested_profiles.jade') arguments...

module.exports = class SuggestionsView extends StepView
  _.extend @prototype, Followable

  suggestedTemplate: ->
    suggestedTemplate arguments...

  kind: 'default'
  followKind: 'default'
  locationRequests: []

  events:
    'click .personalize-skip': 'advance'
    'click .pfa-remove': 'unfollow'
    'click .grid-item': 'followSuggestion'
    'click .personalize-suggestions-more': 'loadNextPage'
    'click #personalize-suggestions-location': 'changeLocation'
    'click #personalize-suggestions-unfollow-all': 'unfollowAll'
    'click .partner-profile-cover': (e) -> e.preventDefault()

  initialize: (options = {}) ->
    super

    @following = new Following null, kind: @followKind

    @ensureLocation()
    @setup()

  # Delegates to the follow button
  followSuggestion: (e) ->
    $(e.currentTarget).find('.follow-button').click()

  ensureLocation: ->
    unless @user.hasLocation()
      @user.approximateLocation success: @renderLocation

  renderLocation: =>
    @$('#personalize-suggestions-location').text @user.location().singleWord()

  unfollowAll: (e) ->
    e.preventDefault()
    @following.unfollowAll @following.map (follow) ->
      follow.get(follow.kind).id
    analytics.track.click "Clicked 'Unfollow all' on personalize #{@kind} suggestions"

  setup: ->
    @initializeFollowable()
    @fetchAndRenderSuggestions()

  render: ->
    @$el.html @template(user: @user, state: @state, autofocus: @autofocus())
    @setupSearch mode: 'profiles', restrictType: @restrictType
    this

  changeLocation: (e) ->
    e.preventDefault()

    @existingSuggestions = @suggestions.pluck('id')
    @listenToOnce @user, 'sync', ->
      @$container.attr 'data-state', 'loading'
      @renderLocation()
      @setup()

    new LocationModalView width: '500px', user: @user
    analytics.track.click "Clicked to change location on personalize #{@kind} suggestions"

  setupFollowButton: (model, el) ->
    key = model.id
    @followButtonViews ?= {}
    @followButtonViews[key].remove() if @followButtonViews[key]?
    @followButtonViews[key] = new FollowButton
      analyticsUnfollowMessage: "Unfollowed #{@kind} from personalize #{@kind} suggestions"
      analyticsFollowMessage: "Followed #{@kind} from personalize #{@kind} suggestions"
      notes: 'Followed from /personalize'
      following: @following
      model: model
      modelName: @kind
      el: el

  renderSuggestions: ->
    (@$container ?= @$('#personalize-suggestions-container')).
      attr 'data-state', 'loaded'

    (@$suggestions ?= @$('#personalize-suggestions')).
      html @suggestedTemplate(suggestions: @suggestions)

    @postRenderSuggestions()

  postRenderSuggestions: ->
    @locationRequests = @locationRequests.concat @fetchAndRenderLocations()
    # Attach FollowButton views
    @suggestions.each (model) =>
      button = @setupFollowButton model, @$suggestions.find(".follow-button[data-id='#{model.id}']")

  fetchAndRenderLocations: ->
    @suggestions.map (profile) =>
      partner = new Partner(profile.get 'owner')
      partner.locations().fetch
        success: =>
          @$suggestions.
            find(".personalize-suggestion-location[data-id='#{partner.id}']").
            html partner.displayLocations(@user.get('location')?.city)

  loadNextPage: (e) ->
    e.preventDefault()
    ($target = $(e.currentTarget)).attr 'data-state', 'loading'
    @suggestions.getNextPage().then (response) ->
      if response.length
        $target.attr 'data-state', 'loaded'
      else
        $target.hide()
    analytics.track.click "Clicked for next page on personalize #{@kind} suggestions"

  fetchAutoFollowedProfiles: ->
    new Backbone.Collection().fetch
      url: "#{sd.API_URL}/api/v1/me/follow/profiles?auto=1&size=48"
      success: (collection, response, options) =>
        if response.length
          @followsToSuggestions collection
          @following.syncFollows @suggestions.pluck 'id'
          @renderSuggestions()

  followsToSuggestions: (collection) ->
    @suggestions.reset _.filter collection.pluck('profile'), (profile) =>
      _.contains @restrictType, profile.owner_type

  fetchAndRenderSuggestions: (options = {}) ->
    @suggestions = new Profiles
    if @state.get 'reonboarding'
      @fetchAutoFollowedProfiles().then =>
        # Fallback if the user doesn't actually have auto-follows
        @fetchSuggestions() unless @suggestions.length
    else
      @fetchSuggestions()

  fetchSuggestions: ->
    @suggestions.fetch
      url: "#{sd.API_URL}/api/v1/me/suggested/profiles"
      data: owner_type: @restrictType
      success: =>
        @following.followAll @suggestions.pluck('id')
        @following.unfollowAll(@existingSuggestions) if @existingSuggestions?
        @renderSuggestions()

  remove: ->
    @searchBarView?.remove()
    _.each @locationRequests, (xhr) -> xhr.abort()
    _.each @followButtonViews, (view) -> view.remove()
    super
