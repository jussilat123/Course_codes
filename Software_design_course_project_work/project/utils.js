.pragma library

function min(arr){
    if (!Array.isArray(arr) || !arr.length) {
        return undefined;
    }
    return arr.reduce( (a,b) => a<b ? a : b);
}

function max(arr){
    if (!Array.isArray(arr) || !arr.length) {
        return undefined;
    }
    return arr.reduce( (a,b) => a>b ? a : b);
}

function yesterday(){
    var today = new Date();
    var yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return yesterday
}

function linspace(min, max, n){
    var d = [];
    for (var i = 0; i < n; i++){
        d.push(min + i * (max - min) / (n - 1));
    }
    return d;
}

function unique(arr){
    return [...new Set(arr)];
}

function average(arr){
    const sum = arr.reduce((a, b) => a + b, 0);
    const avg = (sum / arr.length) || 0;
    return avg;
}

function range(begin, end) {
    begin = parseInt(begin);
    end = parseInt(end);
    return [...Array(end-begin).keys()].map(val => val + begin);
}
