<template>
  <div class="pipelines-container">
    <div style="width: 100%;" v-if="store.state.pipelines.length != 0">
      <el-row>
        <el-col v-for="(o, index) in store.state.pipelines.length" :key="o" style="height:50% ;">
          <div v-if="index == 0" class="stream-card-secure">
              <DetailView
                :pipeline_id="store.state.pipelines[index].pipeline_id"
                :stream_name="store.state.pipelines[index].stream_name"
                :model_name="store.state.pipelines[index].model_name"
                :input_fps="store.state.pipelines[index].input_fps"
                :infer_fps="Math.min(store.state.pipelines[index].infer_fps, store.state.pipelines[index].input_fps)"
                :stream_url="store.state.stream_urls[index]"
                :now_time="store.state.now_time"
                :is_secure="1"
                />
          </div>
          <div v-else class="stream-card">
              <DetailView
                :pipeline_id="store.state.pipelines[index].pipeline_id"
                :stream_name="store.state.pipelines[index].stream_name"
                :model_name="store.state.pipelines[index].model_name"
                :input_fps="store.state.pipelines[index].input_fps"
                :infer_fps="Math.min(store.state.pipelines[index].infer_fps, store.state.pipelines[index].input_fps)"
                :stream_url="store.state.stream_urls[index]"
                :now_time="store.state.now_time"
                :is_secure="0"
                />
          </div>
        </el-col>
      </el-row>
    </div>
    <div v-else style="margin: auto auto">
      <h1>No pipeline found from database server</h1>
      <p/>
      <h3>{{ store.state.pipeline_db_server }}</h3>
    </div>
  </div>
</template>

<script setup lang="ts">
import DetailView from '../components/DetailView.vue';
import { useStore } from 'vuex';
import { onMounted, onUnmounted } from 'vue';
import { refreshPipeline } from "../store";
const store = useStore();

onMounted(() => {
  console.log("Pipeline View: onMounted");
  refreshPipeline();
})

onUnmounted(() => {
  console.log("Pipeline View: onUnMounted");
})
</script>

<style scoped>
.pipelines-container {
  min-height: 600px;
  display: flex;
}

.stream-card {
  height: 100%;
  width: 98%;
  margin: 5px;
  padding: 5px;
  display: block;
  border: 3px;
  background-color:azure;
  border-style: dashed;
}

.stream-card-secure {
  height: 100%;
  width: 98%;
  margin: 5px;
  padding: 5px;
  display: block;
  border: 10px;
  background-color:azure;
  border-style: dashed;
  border-color: red;
}

.image {
  width: 40%;
  display: block;
}
</style>
