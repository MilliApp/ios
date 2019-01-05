var GetURL = function() {};
GetURL.prototype = {
run: function(arguments) {
    arguments.completionFunction({"articleUrl": document.URL,
                                 "title": document.title,
                                 "html": document.body.innerHTML,
                                 "domain": document.location.hostname
                                 });
}
};
var ExtensionPreprocessingJS = new GetURL;

