App = Ember.Application.create();

App.Store = DS.Store.extend({
  revision: 12,
  adapter: DS.RESTAdapter.extend({
    url: 'http://0.0.0.0:3000',
    namespace: 'api'
  })
});

App.Router.map(function() {
  this.resource('about');
});


App.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('about');
  }
});

Ember.Handlebars.registerBoundHelper('date', function(date) {
  return moment(date).fromNow();
});

var showdown = new Showdown.converter();
Ember.Handlebars.registerBoundHelper('markdown', function(input) {
  return new Ember.Handlebars.SafeString(showdown.makeHtml(input));
});

