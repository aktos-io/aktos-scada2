// taken from https://stackoverflow.com/a/31438726/1952991
var createDownload = function(filename,content,mimetype="text/plain"){
    // Set up the link
    var link = document.createElement("a");
    link.setAttribute("target","_blank");
    if(Blob !== undefined) {
        var blob = new Blob([content], {type: mimetype});
        link.setAttribute("href", URL.createObjectURL(blob));
    } else {
        link.setAttribute("href","data:"+mimetype+"," + encodeURIComponent(content));
    }
    link.setAttribute("download",filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

module.exports = {createDownload: createDownload}
