<template>
  <div>
    <h1>Moisture and Pump Action Graph</h1>
    <apexcharts type="line" :options="chartOptions" :series="series"></apexcharts>
  </div>
</template>

<script>
import axios from "axios";
import VueApexCharts from "vue3-apexcharts";
import moment from 'moment-timezone';

export default {
  components: {
    apexcharts: VueApexCharts
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
              download: true,
              selection: true,
              zoom: true,
              zoomin: true,
              zoomout: true,
              pan: false,
              reset: true
            },
            autoSelected: 'zoom'
          }
        },
        xaxis: {
          type: 'datetime',
          title: {
            text: 'Timestamp'
          },
          min: moment().subtract(2, 'days').startOf('day').valueOf(),
          max: moment().add(1, 'days').startOf('day').valueOf(),
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
          shared: false,
          intersect: true
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
  },
  methods: {
    async loadData() {
      const endDate = moment().format();
      console.log(endDate);
      const startDate = moment().subtract(3, 'months').format();

      const params = {start: startDate, end: endDate};
      //const params = {start: '2024-01-01T00:00Z', end: '2024-12-31T00:00Z'};
      const moistureResponse = await axios.get('http://localhost:8000/api/sensor', {params});
      const pumpResponse = await axios.get('http://localhost:8000/api/pump', {params});
      this.series[0].data = moistureResponse.data.map(item => ({
        x: item.timestamp,
        y: item.moisture_level,
      }));
      this.series[1].data = pumpResponse.data.map(item => ({
        x: item.timestamp,
        y: item.action ? 1 : 0
      }));
    }
  }
};
</script>
