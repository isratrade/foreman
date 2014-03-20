var app = angular.module('foremanApp', ['ngResource']);

app.factory('hostgroupFactory', ['$resource', function($resource) {
  return $resource("/api/v2/hostgroups/:Id", {Id: "@Id" });
}]);

app.factory('puppetclassesFactory', ['$resource', function($resource) {
  return {
      Added:     $resource("/api/v2/hostgroups/:Id/environments/:envId/puppetclasses/added",     {Id: "@Id", envId: "@envId"}),
      Inherited: $resource("/api/v2/hostgroups/:Id/environments/:envId/puppetclasses/inherited", {Id: "@Id", envId: "@envId"}),
      Available: $resource("/api/v2/hostgroups/:Id/environments/:envId/puppetclasses/available", {Id: "@Id", envId: "@envId"})
  };
}]);

app.controller('hostgroupController', ['$scope', '$location', '$resource', 'hostgroupFactory', 'puppetclassesFactory', '$q',
  function($scope, $location, $resource, hostgroupFactory, puppetclassesFactory, $q) {

  // Populate drop-down fields
  $scope.apiEnvironments = $resource('/api/v2/environments',{per_page: 10000}).get();
  $scope.apiEnvironments.$promise.then(function (response) {
       $scope.environments = response.results;
  });

  $scope.apiSubnets = $resource('/api/v2/subnets',{per_page: 10000}).get();
  $scope.apiSubnets.$promise.then(function (response) {
       $scope.subnets = response.results;
  });

  $scope.apiDomains = $resource('/api/v2/domains',{per_page: 10000}).get();
  $scope.apiDomains.$promise.then(function (response) {
       $scope.domains = response.results;
  });

  $scope.apiSmartProxies = $resource('/api/v2/smart_proxies',{per_page: 10000}).get();
  $scope.apiSmartProxies.$promise.then(function (response) {
       $scope.smart_proxies = response.results;
  });

  $scope.apiArchitectures = $resource('/api/v2/architectures',{per_page: 10000}).get();
  $scope.apiArchitectures.$promise.then(function (response) {
       $scope.architectures = response.results;
  });

  $scope.apiOperatingsystems = $resource('/api/v2/operatingsystems',{per_page: 10000}).get();
  $scope.apiOperatingsystems.$promise.then(function (response) {
       $scope.operatingsystems = response.results;
  });

  $scope.apiMedia = $resource('/api/v2/media',{per_page: 10000}).get();
  $scope.apiMedia.$promise.then(function (response) {
       $scope.media = response.results;
  });

  $scope.apiPtables = $resource('/api/v2/ptables',{per_page: 10000}).get();
  $scope.apiPtables.$promise.then(function (response) {
       $scope.ptables = response.results;
  });

  $scope.apiComputeProfiles = $resource('/api/v2/compute_profiles',{per_page: 10000}).get();
  $scope.apiComputeProfiles.$promise.then(function (response) {
       $scope.compute_profiles = response.results;
  });

  $scope.hostgroup = {};
  $scope.hostgroup = hostgroupFactory.get({'Id': $scope.hostgroupId});

  var pickLists = $q.all([$scope.apiEnvironments.$promise, $scope.apiSubnets.$promise, $scope.apiDomains.$promise,
                          $scope.apiSmartProxies.$promise,   $scope.apiArchitectures.$promise, $scope.apiOperatingsystems.$promise,
                          $scope.apiMedia.$promise, $scope.apiPtables.$promise, $scope.apiComputeProfiles.$promise,
                          $scope.hostgroup.$promise
                         ]);

  pickLists.then(function() {
    // assign ng-model's based on id's retreive in $scope.hostgroup
    $scope.hostgroup.environment = $.grep($scope.environments, function(e){ return e.id == $scope.hostgroup.environment_id; })[0];
    $scope.hostgroup.compute_profile = $.grep($scope.compute_profiles, function(e){ return e.id == $scope.hostgroup.compute_profile_id; })[0];
    $scope.hostgroup.puppet_ca_proxy = $.grep($scope.smart_proxies, function(e){ return e.id == $scope.hostgroup.puppet_ca_proxy_id; })[0];
    $scope.hostgroup.puppet_proxy = $.grep($scope.smart_proxies, function(e){ return e.id == $scope.hostgroup.puppet_proxy_id; })[0];
    $scope.hostgroup.domain = $.grep($scope.domains, function(e){ return e.id == $scope.hostgroup.domain_id; })[0];
    $scope.hostgroup.subnet = $.grep($scope.subnets, function(e){ return e.id == $scope.hostgroup.subnet_id; })[0];
    $scope.hostgroup.architecture = $.grep($scope.architectures, function(e){ return e.id == $scope.hostgroup.architecture_id; })[0];
    $scope.hostgroup.operatingsystem = $.grep($scope.operatingsystems, function(e){ return e.id == $scope.hostgroup.operatingsystem_id; })[0];
    $scope.hostgroup.medium = $.grep($scope.media, function(e){ return e.id == $scope.hostgroup.medium_id; })[0];
    $scope.hostgroup.ptable = $.grep($scope.ptables, function(e){ return e.id == $scope.hostgroup.ptable_id; })[0];
    calcPuppetclasses();
  });

  $scope.environmentChanged = function () {
    calcPuppetclasses();
  }

  function calcPuppetclasses() {

    $scope.apiPuppetClassesAdded = puppetclassesFactory.Added.get({Id: $scope.hostgroupId, envId: $scope.hostgroup.environment.id, per_page: 10000, style: 'list'});
    $scope.apiPuppetClassesAdded.$promise.then(function (response) {
       $scope.addedPuppetClasses = response.results;
    });
    $scope.apiPuppetClassesInherited = puppetclassesFactory.Inherited.get({Id: $scope.hostgroupId, envId: $scope.hostgroup.environment.id, per_page: 10000, style: 'list'});
    $scope.apiPuppetClassesInherited.$promise.then(function (response) {
       $scope.inheritedPuppetClasses = response.results;
    });

    $scope.apiPuppetClassesAvailable = puppetclassesFactory.Available.get({Id: $scope.hostgroupId, envId: $scope.hostgroup.environment.id, per_page: 10000, style: 'list'});
    $scope.apiPuppetClassesAvailable.$promise.then(function (response) {
       $scope.availablePuppetClasses = response.results;
    });

    var pupetclassLists = $q.all([$scope.apiPuppetClassesAdded.$promise,
                                  $scope.apiPuppetClassesInherited.$promise,
                                  $scope.apiPuppetClassesAvailable.$promise
                                 ]);
    pupetclassLists.then(function() {
      $scope.availablePuppetClassesByModule = _.groupBy($scope.availablePuppetClasses, 'module_name');
    });
  }

  $scope.addPuppetclass = function (puppetclass) {
    $scope.addedPuppetClasses.push(puppetclass);
    avail = _.filter($scope.availablePuppetClasses, function (pc) { return pc.id !== puppetclass.id; });
    $scope.availablePuppetClasses = avail;
    $scope.availablePuppetClassesByModule = _.groupBy(avail, 'module_name');
  };

  $scope.removePuppetclass = function (puppetclass) {
    $scope.availablePuppetClasses.push(puppetclass);
    added = _.filter($scope.addedPuppetClasses, function (pc) { return pc.id !== puppetclass.id; });
    $scope.addedPuppetClasses = added;
    $scope.availablePuppetClassesByModule = _.groupBy($scope.availablePuppetClasses, 'module_name');
  };

  $scope.is_collapse_all = true
  $scope.is_collapse     = true

  $scope.toggleExpandAll = function (puppetclass) {
    $scope.is_collapse_all = !$scope.is_collapse_all
    //TODO it doesn't change each child scope created by ng-repeat
    $scope.is_collapse = !$scope.is_collapse
  };

  // THIS CHANGES ALL so I moved function include ng-click
  // $scope.toggleExpand = function (puppetclass) {
  //   $scope.is_collapse = !$scope.is_collapse
  // };



  // app.directive('hostgroupForm', function($http) {
  //   return {
  //     restrict: 'A',
  //     scope: true,
  //     controller: function($scope, $attrs) {
  //       if ($attrs.hostgroupForm == 0) {
  //         //console.log('new hostgroup');
  //       } else {
  //         $scope.current_location = null;
  //         $scope.current_organization = null;
  //         //console.log('existing hostgroup');
  //       }
  //     },
  //     link: function(scope, element, attrs) {
  //     }
  //   }
  // });

}]);
