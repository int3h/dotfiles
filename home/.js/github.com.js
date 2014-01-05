// Add a table of contents to any GitHub MarkDown content


// TODO: Style the TOC better. Look into making it match the repo menu at the right of the screen.
//	This menu has the CSS class .sunken-menu, and uses CSS gradients for its effect. We should also
//	look into the fact that the page is unbalanced now; the main content *and* the right repo menu
//	are what is centered in the a normal GitHub page. This makes the MarkDown content be a little
//	off center to the left naturally, and then the TOC hangs way off to the left on top of that.

// TODO: (maybe) have the TOC scroll with the page after scrolling past its normal position. This
//	will require a way to scroll the TOC itself if it's longer than the browser height.

(function() {
	// A bunch of logic in this script deals with the fact that GitHub's links mainly don't use the
	// regular <a href='...'> HTML links. Instead, it uses the pjax library
	// (https://github.com/defunkt/jquery-pjax), which fetches page content with AJAX and
	// and dynamically replaces some predefined content area with the new content.
	// This means we can't just run this script once on page load. We instead have to watch the
	// content of the page with DOM Mutation Observers and try to detect when new content of
	// interest has been loaded, then re-run our 'add a table-of-contents' code.
	//
	// I should note that there's no way to directly interact with pjax via a Chrome content script.
	// Chrome sandboxes the content script, meaning it doesn't see anything the JavaScript on the
	// page does. Normally, I'd be able to watch for the custom jquery event "pjax:end", but that
	// doesn't work. It's also impossible to hook page-based JS functions, or do anything else
	// sophisticated. About all I can do is receive standard DOM events.

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
				margin-left: 1em;\
				text-indent: -1em;\
			}\
		\
			#mdTOC > ul ul {\
				margin-left: 1.50em;\
				font-size: 0.8em;\
				margin-bottom: 0.5em;\
			}\
		\
			#mdTOC > ul li:only-child {\
				margin-left: 0em;\
				text-indent: 0em;\
			}\
		\
			#mdTOC > ul li.empty:only-child ul {\
				margin-left: 1em;\
				font-size: 1em;\
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


	function addToc() {
		// Try to find MarkDown content on this page. If there is none, then stop.
		var mdBody = $(".markdown-body").not(".comment-body");
		if(mdBody.length < 1) { return false; }

		// Create a new DIV to hold our TOC
		var toc = $("<div id='mdTOC'></div>");

		// Find all top-level anchors to the MD and add them to the TOC. Also recurse and add
		// sub-headings, etc. for each top-level anchor.
		var h1List = $("<ul></ul>");
		toc.append(h1List);
		var h1li = null;
		var h2List = null;

		mdBody.find("h1, h2").each(function(index, headingEl) {
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
					h1li = $("<li class='empty'></li>");
					h1List.append(h1li);
					h2List = $("<ul><ul>");
					h1li.append(h2List);
				}
				
				var h2Content = extractAnchor(heading);
				h2List.append($("<li><a href='" + h2Content["url"] + "'>" + h2Content["text"] + "</a></li>"));
			}
		});

		toc.css("position", "absolute");

		// Ugly hack to make sure the TOC is positioned next to the top of the MarkDown body.
		// After a pjax load, the position of the markdown-body may change, even after the new MarkDown
		// body element has been added. I can't figure out a clean way to watch for this change
		// directly (a DOM observer of the MarkDown body element's attributes doesn't work,) so I
		// just set some timers to run soon after we add the TOC.
		function setPositition() {
			var markdownTop = mdBody.offset()["top"];
			toc.css("top", markdownTop);
		}
		setPositition();
		window.setTimeout(setPositition, 100);
		window.setTimeout(setPositition, 200);
		window.setTimeout(setPositition, 500);
		window.setTimeout(setPositition, 1000);

		$("#js-repo-pjax-container").prepend(toc);
	}


	function setup() {
		// Observer that watches the pjax content area and detects when the content has been reloaded.
		// It does this by looking for the addition of #readme and #files nodes, which only are added
		// when GitHub is totally changing the page.
		var observer = new MutationObserver(function(mutations) {
			mutations.forEach(function(mutation) {
				if(mutation.addedNodes != null && mutation.addedNodes.length > 0) {
					for(var i = 0; i < mutation.addedNodes.length; i++) {
						if(mutation.addedNodes[i].id == "readme" || mutation.addedNodes[i].id == "files") {
							addToc();
						}
					}
				}
			});
		});

		// Make sure this page has a repo-style pjax area, which we'll watch for MarkDown content
		// with the above observer.
		// My testing indicates that there can only be 1 pjax content area per page. If we don't find
		// a repo-style one, then only a whole new, regular page load (<a href='...'>) will cause
		// this to change; GH can't or won't change the pjax content area via pjax content.
		// Therefore, it's sufficient to check for this container once on page load.
		var pjaxArea = $("#js-repo-pjax-container");
		if(pjaxArea.length > 0) {
			addToc();
			observer.observe(pjaxArea[0], {childList: true, subtree: true});
		} else {
			//console.log("No repo-style pjax content area found. Not adding a TOC.")
		}
	}


	if(document.readyState != "complete" && document.readyState != "interactive") {
		//console.log("TOC: running later because readyState is " + document.readyState)
		$(document).on("ready", setup);
	} else {
		//console.log("TOC: running now")
		setup();
	}
	//console.log("TOC: end of script file executed");
})();
