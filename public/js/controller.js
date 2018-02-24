/**
 * You must include the dependency on 'ngMaterial'
 */
var myApp = angular.module('myApp', ['ngMaterial']);

myApp.config(function ($mdThemingProvider) {

    // Extend the red theme with a different color and make the contrast color black instead of white.
    // For example: raised button text will be black instead of white.
    var neonRedMap = $mdThemingProvider.extendPalette('red', {
        '500': '#ff0000',
        'contrastDefaultColor': 'dark'
    });

    // Register the new color palette map with the name <code>neonRed</code>
    $mdThemingProvider.definePalette('neonRed', neonRedMap);

    // Use that theme for the primary intentions
    $mdThemingProvider.theme('default')
        .primaryPalette('neonRed');

});

myApp.controller('appCtrl', function ($scope, $http) {
    var baseUrl = 'http://localhost:9494/api';

    $scope.icon = 'img/60.png';

    $http({method: 'GET', url: baseUrl + '/tables'})
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



