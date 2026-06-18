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

export default {
  components: {
    apexcharts: defineAsyncComponent(() => import('vue3-apexcharts'))
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
          }
        },
        yaxis: [{
          title: {
            text: 'Moisture Level'
          }
        }, {
          opposite: true,
          title: {
            text: 'Pump State'
          },
          min: 0,
          max: 1,
        }],
        markers: {
          size: [0, 5]
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
      this.series[0].data = moistureResponse.data.map(item => ({
        x: item.timestamp,
        y: item.moisture_level,
      }));
      this.series[1].data = pumpResponse.data.map(item => ({
        x: item.timestamp,
        y: item.action ? 1 : 0
      }));
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