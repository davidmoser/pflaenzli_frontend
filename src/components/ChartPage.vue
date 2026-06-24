<template>
  <div>
    <h1>Moisture and Pump Action Graph</h1>
    <apexcharts type="line" :options="chartOptions" :series="series"></apexcharts>
  </div>
</template>

<script>
import axios from "axios";
import moment from 'moment-timezone';
import {defineAsyncComponent} from "vue";

// Approx. max daily reference evapotranspiration (ET₀) in the Swiss lowlands in
// midsummer (~6–7 mm/day). Used as the right-axis ceiling unless the data exceeds it.
const ET0_AXIS_MAX = 7;

export default {
  components: {
    apexcharts: defineAsyncComponent(() => import('vue3-apexcharts')),
  },

  data() {
    return {
      chartOptions: {
        chart: {
          id: 'moisture-level',
          group: 'moisture-pump',
          toolbar: {
            show: true,
            tools: {
              download: false,
              selection: true,
              zoom: true,
              zoomin: false,
              zoomout: false,
              pan: true,
              reset: true,
              customIcons: [
                {
                  icon: '<img src="/d.png" width="20">',
                  index: 1, // Negative index to place it at the start or adjust as needed
                  title: 'Day View',
                  class: 'custom-icon-day',
                  click: (chart, options, e) => {
                    this.setTimeInterval(1);
                  }
                },
                {
                  icon: '<img src="/w.png" width="20">',
                  index: 2,
                  title: 'Week View',
                  class: 'custom-icon-week',
                  click: (chart, options, e) => {
                    this.setTimeInterval(7);
                  }
                },
                {
                  icon: '<img src="/m.png" width="20">',
                  index: 3,
                  title: 'Month View',
                  class: 'custom-icon-month',
                  click: (chart, options, e) => {
                    this.setTimeInterval(31);
                  }
                }
              ]
            },
            autoSelected: 'zoom'
          }
        },
        xaxis: {
          type: 'datetime',
          title: {
            text: 'Timestamp'
          },
          labels: {
            datetimeUTC: false
          },
          // Hide the full-height vertical crosshair line (the tooltip popup is kept).
          crosshairs: {
            show: false
          }
        },
        yaxis: [{
          seriesName: 'Moisture',
          title: {
            text: 'Moisture Level'
          }
        }, {
          seriesName: 'ET₀',
          opposite: true,
          title: {
            text: 'ET₀ (mm)'
          },
          min: 0,
          max: ET0_AXIS_MAX,
        }, {
          // Hidden axis that keeps the pump dots pinned to the top (y = 1), unchanged.
          seriesName: 'Pump State',
          opposite: true,
          show: false,
          min: 0,
          max: 1,
        }],
        markers: {
          size: [0, 0, 5]
        },
        tooltip: {
          enabled: true,
          shared: true,
          x: {
            show: false,
          }
        }
      },
      series: [{
        name: 'Moisture',
        type: 'line',
        color: '#008FFB',
        data: [] // Data fetched from API
      }, {
        name: 'ET₀',
        type: 'line',
        color: '#FEB019',
        data: [] // Data fetched from API
      }, {
        name: 'Pump State',
        type: 'scatter',
        color: '#FF4560',
        data: [] // Data fetched from API
      }]
    };
  },
  mounted() {
    this.loadData();
    this.setTimeInterval(1)
  },
  methods: {
    async loadData() {
      const endDate = moment().format();
      const startDate = moment().subtract(1, 'months').format();

      const params = {start: startDate, end: endDate};

      const moistureResponse = await axios.get('sensor', {params});
      const pumpResponse = await axios.get('pump', {params});
      // Schedule is filtered by date (schedule_date is a DateField), same start/end logic.
      const scheduleParams = {
        start: moment(startDate).format('YYYY-MM-DD'),
        end: moment(endDate).format('YYYY-MM-DD'),
      };
      const scheduleResponse = await axios.get('schedule', {params: scheduleParams});

      this.series[0].data = moistureResponse.data.map(item => ({
        x: item.timestamp,
        y: item.moisture_level,
      }));

      const et0Data = scheduleResponse.data
        .map(item => ({x: moment(item.schedule_date).valueOf(), y: item.et0}));
      this.series[1].data = et0Data;

      this.series[2].data = pumpResponse.data.map(item => ({
        x: item.timestamp,
        y: item.action ? 1 : 0
      }));

      // Keep the Swiss midsummer ceiling unless the data climbs higher.
      const maxEt0 = et0Data.reduce((max, point) => Math.max(max, point.y), 0);
      const axisMax = Math.max(ET0_AXIS_MAX, Math.ceil(maxEt0));
      this.chartOptions = {
        ...this.chartOptions,
        yaxis: this.chartOptions.yaxis.map((axis, i) => i === 1 ? {...axis, max: axisMax} : axis)
      };
    }, setTimeInterval(days) {
      const minTimestamp = moment().subtract(days - 1, 'days').startOf('day').valueOf();
      const maxTimestamp = moment().add(1, 'day').startOf('day').valueOf();

      this.chartOptions = {
        ...this.chartOptions,
        xaxis: {
          ...this.chartOptions.xaxis,
          min: minTimestamp,
          max: maxTimestamp
        }
      };

    },
  }
};
</script>