// Add a table of contents to any GitHub MarkDown content


// TODO: Style the TOC better. Look into making it match the repo menu at the right of the screen.
//	This menu has the CSS class .sunken-menu, and uses CSS gradients for its effect. We should also
//	look into the fact that the page is unbalanced now; the main content *and* the right repo menu
//	are what is centered in the a normal GitHub page. This makes the MarkDown content be a little
//	off center to the left naturally, and then the TOC hangs way off to the left on top of that.
// TODO: (maybe) have the TOC scroll with the page after scrolling past its normal position. This
//	will require a way to scroll the TOC itself if it's longer than the browser height.
// TODO: Make this script more reslient to running before the page is loaded. This hasn't been a
//	problem so far, but if it were to run before the .markdown-body element is loaded, it wouldn't
//	run at all; and if it runs before all the headers are loaded, the TOC will be missing items. We
//	want to run ASAP (not when the page finishes fully loading) to appear snappy to the user, but we
//	might then want to put event watchers when new items are added to the page.

(function() {
	// Try to find MarkDown content on this page. If there is none, then stop.
	if($(".markdown-body").length < 1) { return false; }

	// Create the <style> element for all our new content
	$("head").append(
		'<style type="text/css">\
			#mdTOC {\
				 width: 230px;\
				 float: left;\
				 margin-left: -270px;\
				 padding: 10px;\
				 border-right: 1px solid black;\
				 font-weight: bold;\
				 font-size: 1.3em;\
			}\
		\
			#mdTOC ul{\
				list-style-type: none;\
			}\
		\
			#mdTOC > ul li {\
				margin-left: 1.25em;\
				text-indent: -1.25em;\
			}\
		\
			#mdTOC > ul ul {\
				font-size: 0.8em;\
				margin-bottom: 0.5em;\
			}\
		</style>');
	

	// Given a GitHub MarkDown-style header object (either an h1 or h2 containing text + a link),
	// extract its title and url, and return them in a object of the form {'text', 'url', 'element'}
	function extractAnchor(element) {
		var jqElement = element; 

		var text = $.trim(jqElement.text());
		var url = "#" + jqElement.find("a").attr("name");
		
		return {"text": text, "url": url, "element": element};
	}


	// Create a new DIV to hold our TOC
	var toc = $("<div id='mdTOC'></div>");

	// Find all top-level anchors to the MD and add them to the TOC. Also recurse and add
	// sub-headings, etc. for each top-level anchor.
	var h1List = $("<ul></ul>");
	toc.append(h1List);
	var h1li = null;
	var h2List = null;

	$(".markdown-body > h1, .markdown-body > h2").each(function(index, headingEl) {
		var heading = $(headingEl);

		if(heading.is("h1")) {
			// Is a h1
			var h1Content = extractAnchor(heading);
			h1li = $("<li><a href='" + h1Content["url"] + "'>" + h1Content["text"] + "</a></li>");
			h1List.append(h1li);

			h2List = $("<ul></ul>");
			h1li.append(h2List);
		} else { // Is a h2
			// If h1li is null, that means there is not an h1 element before this h2 element. Create
			// an empty list element as a placeholder for the non-existent h1, and then create a
			// new list for this h2, and append it to the placeholder h1 li.
			if(h1li == null) {
				h1li = $("<li></li>");
				h1List.append(h1li);
				h2List = $("<ul><ul>");
				h1li.append(h2List);
			}
			
			var h2Content = extractAnchor(heading);
			h2List.append($("<li><a href='" + h2Content["url"] + "'>" + h2Content["text"] + "</a></li>"));
		}
	});


	$(".md").before(toc);
})();
