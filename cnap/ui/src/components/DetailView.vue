<template>
  <el-row :gutter="20">
    <el-col :span="4">
        <div class="grid-content ep-bg-purple" >
          <StreamView style="width: 90%; height: 80%; text-align: center;"
            :stream="{name: stream_name,
                      url: stream_url}"
           />
        </div>
    </el-col>
    <el-col :span="16">
      <div class="grid-content">
        <el-row :gutter="20" class="line-item">
          <el-col  :span="5">
            <div style="text-align: left;">
              <el-text size="large">Pipeline ID</el-text>
            </div>
          </el-col>
          <el-col :span="19">
            <div style="text-align: left;">
              {{ pipeline_id }}
            </div>
          </el-col>
        </el-row>
        <el-row :gutter="20" class="line-item">
          <el-col :span="5">
            <div style="text-align: left;">
              <el-text size="large">Model Name</el-text>
            </div>
          </el-col>
          <el-col :span="19">
            <div style="text-align: left;">
              <el-text size="large">{{ model_name }}</el-text>
            </div>
          </el-col>
        </el-row>
        <el-row :gutter="20" class="line-item">
          <el-col :span="5">
            <div style="text-align: left;">
              <el-text size="large">Stream Name</el-text>
            </div>
          </el-col>
          <el-col :span="19">
            <div style="text-align: left;">
              <el-text size="large">{{ stream_name }}</el-text>
            </div>
          </el-col>
        </el-row>
        <el-row :gutter="20" class="line-item">
          <el-col :span="5">
            <div style="text-align: left;">
              <el-text size="large">Input Speed</el-text>
            </div>
          </el-col>
          <el-col :span="19">
            <div style="text-align: left;">
              <el-text size="large"> {{ input_fps }} (FPS)</el-text>
            </div>
          </el-col>
        </el-row>
        <el-row :gutter="20" class="line-item">
          <el-col :span="5">
            <div style="text-align: left;">
              <el-text size="large">Infer Speed</el-text>
            </div>
          </el-col>
          <el-col :span="19">
            <div style="text-align: left;">
              <el-text size="large">{{ infer_fps }} (FPS)</el-text>
            </div>
          </el-col>
        </el-row>
        <div v-if="is_secure == 1">
          <el-row :gutter="20" class="line-item">
            <el-col :span="5">
              <div style="text-align: left;">
                <el-text size="large">RTMR[0]</el-text>
              </div>
            </el-col>
            <el-col :span="19">
              <div style="text-align: left;">
                <el-text size="large">{{ rtmr_0 }}</el-text>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" class="line-item">
            <el-col :span="5">
              <div style="text-align: left;">
                <el-text size="large">RTMR[1]</el-text>
              </div>
            </el-col>
            <el-col :span="19">
              <div style="text-align: left;">
                <el-text size="large">{{ rtmr_1 }}</el-text>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" class="line-item">
            <el-col :span="5">
              <div style="text-align: left;">
                <el-text size="large">RTMR[2]</el-text>
              </div>
            </el-col>
            <el-col :span="19">
              <div style="text-align: left;">
                <el-text size="large">{{ rtmr_2 }}</el-text>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" class="line-item">
            <el-col :span="5">
              <div style="text-align: left;">
                <el-text size="large">RTMR[3]</el-text>
              </div>
            </el-col>
            <el-col :span="19">
              <div style="text-align: left;">
                <el-text size="large">{{ rtmr_3 }}</el-text>
              </div>
            </el-col>
          </el-row>
        </div>
      </div>
    </el-col>
    <el-col :span="4">
      <div class="grid-content" >
        <vue-echarts class="line" :option="getOption_fps()" ref="chart" style="height: 90%; width: 90%;"/>
      </div>
    </el-col>
  </el-row>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import StreamView from './StreamView.vue';
import { VueEcharts } from 'vue3-echarts';
import type { EChartsOption } from 'echarts';

const props = defineProps({
  pipeline_id: {
    type: String,
    default: ''
  },
  model_name: {
    type: String,
    default: 'dummy model',
  },
  stream_name: {
    type:String,
    default: 'dummy stream'
  },
  input_fps: {
    type: Number,
    default: 0
  },
  infer_fps: {
    type: Number,
    default: 0
  },
  stream_url: {
    type: String,
    default: 'dummy url'
  },
  now_time: {
    type: String,
    default: ""
  },
  is_secure: {
    type: Number,
    default: 1
  },
  rtmr_0: {
    type: String,
    default: "095a7840b11b4a90195f4c83132cb316db265496ecfb1a0146e6e74f2c1009a2ac3634da12d2b7e22e661a5ec7df5bc5"
  },
  rtmr_1: {
    type: String,
    default: "1c702cbdb8a74442df94e8df701127b0fb31eb5cfe5237ecde6e353f6546b94098c90fb944e1522b320941eb99b7c805"
  },
  rtmr_2: {
    type: String,
    default: "0fdcd44ab078d6693bdb44ff19c579f4b411bac832ed54a768d9ba17e01ba9b9a96df4e0b45ac26bbf8361dcb056bbb9"
  },
  rtmr_3: {
    type: String,
    default: "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
  },
});

const is_secure = props.is_secure;
const rtmr_0 = props.rtmr_0;
const rtmr_1 = props.rtmr_1;
const rtmr_2 = props.rtmr_2;
const rtmr_3 = props.rtmr_3;

const max_points = 5;

const data_source_fps: Array<[string, number, number]>= [];

function getOption_fps() : EChartsOption {
  data_source_fps.push([props.now_time, props.infer_fps, Math.max(props.input_fps - props.infer_fps, 0)]);
  if (data_source_fps.length > max_points) {
    data_source_fps.splice(0, 1);
  }

  return {
    legend: {},
    tooltip: {},
    dataset: {
        dimensions:  ['product', 'Infer FPS', 'Drop FPS'],
        source: data_source_fps
    },
    color: ['#007bff', '#dc3545', '#007bff'],
    xAxis: {
        type: 'category',
        axisTick: {
            show: false
        },
    },
    yAxis: {
        show: true,
        axisTick: {
            show: false
        },
        axisLine: {
            show: false
        },
        splitLine: {
            show: true
        },
    },
    series: [
        {type: 'line'},
        {type: 'line'},
        {type: 'line'}
    ],
    grid: {
        left: '5%',
        right: '2%',
        bottom: '10',
        containLabel: true,
      }
  }
}

onMounted(() => {
})
</script>

<style>
.grid-field {
  margin: 10px;
  align-content: left;
  text-align: left;
}

.line-item {
  margin: 20px;
}

.grid-content {
  border-radius: 4px;
  min-height: 120px;
  height: 100%;
  text-align: left;
}

.image {
  width: 100%;
  height: 95%;
  display: block;
}
</style>
