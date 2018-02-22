/**
 * You must include the dependency on 'ngMaterial'
 */
var myApp = angular.module('myApp', ['ngMaterial']);

myApp.controller('appCtrl', function ($scope, $http) {
    var baseUrl = 'http://localhost:9494';

    $scope.icon = 'img/60.png';
    $scope.tables = [];
    $scope.database = "";
    $scope.schema = "";
    $scope.countOfTables = 0;

    $http({method: 'OPTIONS', url: baseUrl + '/tables'})
        .then(function (returnData) {

            $scope.tables = returnData.data.tables;
            $scope.database = returnData.data.database;
            $scope.schema = returnData.data.schema;
            $scope.countOfTables = returnData.data.tables.length;

        }, function (reason) {
            console.log(reason);
        });

    $scope.isOpen = false;

    $scope.demo = {
        isOpen: false,
        count: 0,
        selectedDirection: 'right'
    };

});



