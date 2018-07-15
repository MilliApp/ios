var GetURL = function() {};
GetURL.prototype = {
run: function(arguments) {
    arguments.completionFunction({"URL": document.URL,
                                 "title": document.title,
                                 "body": document.body.innerHTML
                                 });
}
};
var ExtensionPreprocessingJS = new GetURL;

