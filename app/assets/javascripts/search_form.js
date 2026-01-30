document.addEventListener('turbolinks:load', function () {
  var transportSelect = document.querySelector('[data-transport-select]');
  if (!transportSelect) {
    return;
  }

  var stationSelects = document.querySelectorAll('[data-station-select]');
  var typeMap = {
    train: 'RailwayStation',
    plane: 'Airport',
    bus: 'BusStation'
  };

  function applyStationFilter() {
    var selectedType = typeMap[transportSelect.value] || null;

    stationSelects.forEach(function (select) {
      var currentValue = select.value;
      var hasCurrent = false;

      Array.prototype.forEach.call(select.options, function (option) {
        if (!option.value) {
          option.hidden = false;
          return;
        }

        var stationType = option.getAttribute('data-station-type');
        var visible = !selectedType || stationType === selectedType;
        option.hidden = !visible;

        if (visible && option.value === currentValue) {
          hasCurrent = true;
        }
      });

      if (!hasCurrent) {
        select.value = '';
      }
    });
  }

  transportSelect.addEventListener('change', applyStationFilter);
  applyStationFilter();
});
