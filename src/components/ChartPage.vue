<template>
  <div>
    <h1>Moisture and Pump Action Graph</h1>
    <apexcharts type="line" :options="chartOptions" :series="series"></apexcharts>
  </div>
</template>

<script>
import axios from "axios";
import moment from 'moment-timezone';
import ApexCharts from "apexcharts";
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
          // ApexCharts 5's initial render animation can leave the line series
          // undrawn until a resize; disabling it draws the curves immediately
          // (also cheaper to render, especially on mobile).
          animations: {
            enabled: false
          },
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
          // The visible window (day/week/month) is set entirely via
          // ApexCharts.exec('zoomX', ...) in setTimeInterval — NOT via min/max here.
          // A config min/max would be re-applied on every updateSeries and override
          // the selected window (reverting week/month back to day).
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
          },
          min: 0,
          max: 100,
          // ApexCharts 5 defaults axis labels to 2 decimals; keep whole numbers.
          labels: {
            formatter: (val) => val.toFixed(0)
          },
        }, {
          seriesName: 'ET₀',
          opposite: true,
          title: {
            text: 'ET₀ (mm)'
          },
          min: 0,
          max: ET0_AXIS_MAX,
          tickAmount: ET0_AXIS_MAX,
          labels: {
            formatter: (val) => val.toFixed(0)
          },
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
      }],
      // Full month of data, kept so each view can be re-windowed (filtered) below.
      raw: {moisture: [], et0: [], pump: []}
    };
  },
  mounted() {
    this.loadData();
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

      // Keep the full month; x as numeric ms so all series window uniformly.
      this.raw = {
        moisture: moistureResponse.data.map(item => ({x: moment(item.timestamp).valueOf(), y: item.moisture_level})),
        et0: scheduleResponse.data.map(item => ({x: moment(item.schedule_date).valueOf(), y: item.et0})),
        pump: pumpResponse.data.map(item => ({x: moment(item.timestamp).valueOf(), y: item.action ? 1 : 0})),
      };
      this.setTimeInterval(1); // initial day view
    }, setTimeInterval(days) {
      const minTimestamp = moment().subtract(days - 1, 'days').startOf('day').valueOf();
      const maxTimestamp = moment().add(1, 'day').startOf('day').valueOf();

      // Filter each series to the visible window so out-of-window points don't exist.
      // ApexCharts clips line paths tightly but clips markers with padding, so a pump
      // marker just outside the window would otherwise leak past the y-axis.
      const clip = (points) => points.filter(p => p.x >= minTimestamp && p.x <= maxTimestamp);
      this.series[0].data = clip(this.raw.moisture);
      this.series[1].data = clip(this.raw.et0);
      this.series[2].data = clip(this.raw.pump);

      // Set the exact window via zoomX, in nextTick so it runs AFTER the updateSeries
      // triggered by the assignments above (otherwise updateSeries re-ranges the x-axis
      // to the data and the window is lost). zoomX (not a chartOptions reassignment)
      // avoids the updateOptions/toolbar remount that drops the customIcons handlers.
      this.$nextTick(() => {
        ApexCharts.exec(this.chartOptions.chart.id, 'zoomX', minTimestamp, maxTimestamp);
      });
    },
  }
};
</script>