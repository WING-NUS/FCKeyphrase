(function( elsevierKP, $, undefined) {

  /* Private properties */
  var articleDOI;
  var secureAuthtoken;
  var searchTerms;

  /* Public methods */
  elsevierKP.contextInfoCallback = function(response) {
    articleDOI = response["doi"];
    secureAuthtoken = response["secureAuthtoken"];
    searchTerms = response["searchTerms"];
    
    var params = {};
    var postdata = { doi: articleDOI };
    params[gadgets.io.RequestParameters.METHOD] = gadgets.io.MethodType.POST;
    params[gadgets.io.RequestParameters.CONTENT_TYPE] = gadgets.io.ContentType.TEXT;
    params[gadgets.io.RequestParameters.POST_DATA] = gadgets.io.encodeValues(postdata);
    $("#contextInfo").html("<span class=\"ex1\">Checking cache for DOI: " + articleDOI + ". Please wait...</span>");

    var cacheUrl = "http://wing.comp.nus.edu.sg/FCKeyphrase/keyphrase.cgi";
    gadgets.io.makeRequest(cacheUrl, elsevierKP.cacheCallback, params);
  };

  elsevierKP.cacheCallback = function(response) {
    if (response.text == "") {
      $("#contextInfo").html("<span class=\"ex1\">Retrieving text of article with DOI: " + articleDOI + ". Please wait...</span>");

      var requestHeaders = {};
      requestHeaders['X-ELS-APIKey'] = "<INSERT API KEY HERE>";
      requestHeaders['X-ELS-Authtoken'] = secureAuthtoken; // fetch authtoken from context call
      requestHeaders['Accept'] = "text/xml";

      var contentSearchUrl = "http://api.elsevier.com/content/article/DOI:" + articleDOI + "?view=FULL";
      gadgets.sciverse.makeContentApiRequest(contentSearchUrl, elsevierKP.articleCallback, requestHeaders);
    } else {
      elsevierKP.keyphraseCallback(response);
    }
  };

  elsevierKP.articleCallback = function(response) {
    $("#contextInfo").html("<span class=\"ex1\">Got article text, forwarding to service, please wait...</span>");

    var params = {};
    var postdata;
    if (response) {
      postdata = { 
        text: response["text"], 
        doi: articleDOI
      };
    } else {
      postdata = { 
        doi: articleDOI
      };
    }

    params[gadgets.io.RequestParameters.METHOD] = gadgets.io.MethodType.POST;
    params[gadgets.io.RequestParameters.CONTENT_TYPE] = gadgets.io.ContentType.TEXT;
    params[gadgets.io.RequestParameters.POST_DATA] = gadgets.io.encodeValues(postdata);

    var keyphraseUrl = "http://wing.comp.nus.edu.sg/FCKeyphrase/keyphrase.cgi";
    gadgets.io.makeRequest(keyphraseUrl, elsevierKP.keyphraseCallback, params);
  };


  elsevierKP.keyphraseCallback = function(response) {
    if (response.text.trim() == "") {
      setTimeout(elsevierKP.articleCallback, 5000); // wait 5 seconds 
      return;
    }

    var myText;
    myText = "<div class=\"ex1\">Keywords found in this document:</br><ul>";
     
    var lines = response.text.split(",");
    for (var i = 0; i < lines.length && i < 5; i++) {
      myText = myText + "<li>" + lines[i].trim() + "</li>";
    } 
    myText = myText + "</div>";
    
    $("#contextInfo").html(myText); 
    gadgets.window.adjustHeight();   
  };
   
  elsevierKP.getCheckboxValues = function() {
    var keyPhraseTerms = "";

    if (searchTerms != "") {
      keyPhraseTerms = searchTerms;
    }

    for (var i=0; i < document.keyPhrases.term.length; i++) {
      if (document.keyPhrases.term[i].checked) {
        if (keyPhraseTerms == "") {
          keyPhraseTerms = "\"" + document.keyPhrases.term[i].value + "\""; 
        } else {
          keyPhraseTerms = keyPhraseTerms + " AND \"" + document.keyPhrases.term[i].value + "\""; 
        }
      }
    }
     
    gadgets.window.adjustHeight();   
  }
  
  /* When DOM is ready */
  $(document).ready(function() {
    gadgets.sciverse.getContextInfo(elsevierKP.contextInfoCallback);
  });
}( window.elsevierKP = window.elsevierKP || {}, jQuery ));
