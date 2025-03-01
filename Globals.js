.pragma library

// Data storage control
var data_chunk_size = 10;
var autosave_time_secs = 10;
var autosave_time_aux = 0;
var ready_to_save = false;
var get_data_en = false;

// Define variables to record and fill CSV with performance summary
var main_data_store = [];
var time_record = [];
var speed_record = [];
var accelX_record = [];
var accelY_record = [];
var accelZ_record = [];
var voltage_record = [];
var current_record = [];
var lora_latency_record = [];
