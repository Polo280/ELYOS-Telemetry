.pragma library  // Ensures it is managed as singleton instance
// console.log("JS file loaded");

// Format a number of seconds in min:secs
function formatTime(seconds) {
    let minutes = Math.floor(seconds / 60);
    let remainingSeconds = seconds % 60;
    return minutes + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds;
}

// Format a main data store (list of lists) to string in csv format
function convertToCsv(data_store){
    let formatted_string = "";
    let sublist_size = data_store[0].length;

    for(let j=0; j < sublist_size; j++){
        // Iterate through lists
        for(let i=0; i < data_store.length; i++){
            // Add data to csv format
            formatted_string += data_store[i][j];
            if(i == data_store.length - 1){
                formatted_string += "\n";
            }else{
                formatted_string += ",";
            }
        }
    }
    return formatted_string;
}
