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
          <div v-else-if="index == 1" class="stream-card-secure">
              <DetailView
                :pipeline_id="store.state.pipelines[index].pipeline_id"
                :stream_name="store.state.pipelines[index].stream_name"
                :model_name="store.state.pipelines[index].model_name"
                :input_fps="store.state.pipelines[index].input_fps"
                :infer_fps="Math.min(store.state.pipelines[index].infer_fps, store.state.pipelines[index].input_fps)"
                :stream_url="store.state.stream_urls[index]"
                :now_time="store.state.now_time"
                :is_secure="1"
                :rtmr_0="'b6e1faef4ad20ccbf57ccbc9be0e88755f8ba0a4c0442d32d01683b99149dc67c0aa35ca4f9e7ad9a72b05471c6d0e38'"
                :rtmr_1="'2654f6523d5ac09d1b8aefe55a3a6d85f5124447154739371c31466cd72d9e54e0db496142ffcac347094f125a70c291'"
                :rtmr_2="'e70ac3e9154f46590406e5ad793dfdbafaf64ade55139b2c4a0de733c9ea888c5bd23a34bd5b53c22f44925349e125ac'"
                />
          </div>
          <div v-else-if="index == 2" class="stream-card-secure">
              <DetailView
                :pipeline_id="store.state.pipelines[index].pipeline_id"
                :stream_name="store.state.pipelines[index].stream_name"
                :model_name="store.state.pipelines[index].model_name"
                :input_fps="store.state.pipelines[index].input_fps"
                :infer_fps="Math.min(store.state.pipelines[index].infer_fps, store.state.pipelines[index].input_fps)"
                :stream_url="store.state.stream_urls[index]"
                :now_time="store.state.now_time"
                :is_secure="1"
                :rtmr_0="'6e36456b1dc72a0a95f6364d6f04b7518d9f6fb2257e3991c523c3bb27bbd8844d09cfd54b2a8480285dd1c36f514390'"
                :rtmr_1="'e1b659ff5c69e7b1410c70d404b0fa8605a374ef0bd8fc4377d0c7e392507605b314dd742bc25d7baee5de073695c6f0'"
                :rtmr_2="'3ccc898ab08b717d6c9ebf7b3e4934d62b988567635afe6d8854fa0804ef69fdf3986af264d9388d3132b74e55616b26'"
                />
          </div>
          <div v-else-if="index == 3" class="stream-card-secure">
              <DetailView
                :pipeline_id="store.state.pipelines[index].pipeline_id"
                :stream_name="store.state.pipelines[index].stream_name"
                :model_name="store.state.pipelines[index].model_name"
                :input_fps="store.state.pipelines[index].input_fps"
                :infer_fps="Math.min(store.state.pipelines[index].infer_fps, store.state.pipelines[index].input_fps)"
                :stream_url="store.state.stream_urls[index]"
                :now_time="store.state.now_time"
                :is_secure="1"
                :rtmr_0="'e71d67b8557577c70b33df6cb29b8ee47bbcb74183a9cca6cf0ba4542f02edecb74b0e026a885131c606f92b72bb72e0'"
                :rtmr_1="'fbc18e73a9b97761c49f3cdec1367779c3783347ccd95ead44555021febcb9dada6e2f79c39b5907dda2d1745284b6d9'"
                :rtmr_2="'24970a0c9abac909d937dd05d0737e76d3a4a4efd3a26d0a3d99b4ff18732beebc3505df50767aabae988bfafe34b046'"
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
