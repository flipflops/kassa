describe("alert", function () {
  var scope, ctrl, model, $compile;
  var element;

  beforeEach(module('ui.bootstrap.alert'));
  beforeEach(module('template/alert/alert.html'));

  beforeEach(inject(function ($rootScope, _$compile_, $controller) {

    scope = $rootScope;
    $compile = _$compile_;

    element = angular.element(
        "<div><alert ng-repeat='alert in alerts' type='alert.type'" +
        "close='removeAlert($index)'>{{alert.msg}}" +
        "</alert></div>");

    scope.alerts = [
      { msg:'foo', type:'success'},
      { msg:'bar', type:'error'},
      { msg:'baz' }
    ];
  }));

  function createAlerts() {
    $compile(element)(scope);
    scope.$digest();
    return element.find('.alert');
  }

  function findCloseButton(index) {
    return element.find('.alert button').eq(index);
  }

  it("should generate alerts using ng-repeat", function () {
    var alerts = createAlerts();
    expect(alerts.length).toEqual(3);
  });

  it("should use correct alert type", function () {
    var alerts = createAlerts();
    expect(alerts.eq(0)).toHaveClass('alert-success');
    expect(alerts.eq(1)).toHaveClass('alert-error');
    expect(alerts.eq(2)).toHaveClass('alert-info');
  });

  it("should fire callback when closed", function () {

    var alerts = createAlerts();

    scope.$apply(function () {
      scope.removeAlert = jasmine.createSpy();
    });

    findCloseButton(1).click();
    expect(scope.removeAlert).toHaveBeenCalledWith(1);
  });

});
