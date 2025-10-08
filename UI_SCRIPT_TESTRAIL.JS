name: Execute Automation Script
description: Adds a button to test run all TCs in test run by automation framework. It will call API to get the list of "CASE ID" belong to test run and pass this list as meta data to trigger automation framework.
author: Duc Vu
version: 1.0
includes: ^runs/view
excludes: 

js:
$(document).ready(
    function() {
	var rd = uiscripts.context.run;	
	const test_run_id = uiscripts.context.run.id;
    const URL_TESTRAIL = "http://localhost:8000/index.php?/api/v2/get_tests/" + test_run_id;
    // ProxyPass "/trigger" "http://host.docker.internal:5000/"
    // ProxyPassReverse "/trigger" "http://host.docker.internal:5000/"
    // Maping /trigger with http://host.docker.internal:5000/ (Flask server) in testrail/apache - Apache Reverse Proxy
    const URL_AUTO = "/trigger/run-tests";
	var check = uiscripts.context.suite;

	//Create Execute Button
	const BUTTON = $('<a class="toolbar-button toolbar-button-last content-header-button button-start button-responsive" href="javascript:void(0)">Execute Automation</a>');
	$(".toolbar.content-header-toolbar.page-title-content-header").append(BUTTON);


    BUTTON.click(
	    function()
        {
            alert('Executing Automation Script for Test Run ID: ' + test_run_id);
            $.ajax({
                //URL should be the URL of the Slack App's Incoming Webhook
                url: URL_TESTRAIL,
                headers: {
                    "Authorization": "Basic " + btoa("ducvubuihong25102000@gmail.com" + ":" + "admin"),
                    "Content-Type": "application/json"
                },
                type: "GET",
                dataType: "json"
            })
	        .done(function (reply) {
                var list_tcs = reply.tests.map(test => "C" + test.case_id);
			    console.log("POST to Testrail API succeeded");
                console.log(reply);
                console.log("-------------------------------------------------------");
                console.log(list_tcs);
	    	})
	    	.fail(function (xhr, status, errorThrown) {
                console.log("Status:", status);
			    console.log("Error in POST to Testrail API: " + errorThrown.toString());
                console.log("Response:", xhr.responseText);
	    	})

            // Trigger Automation Framework
            $.ajax({
                url: URL_AUTO,
                type: "POST",
                dataType: "json",
                contentType: "application/json",
                data: JSON.stringify({"tags": ["TC_sample_12", "TC_sample_22"]})
            })
	        .done(function (reply) {
			    console.log("POST to Robot Framework API server succeeded");
                console.log(reply);
                console.log("###############################################################");
                alert('Automation Script Triggered for Test Run ID: ' + test_run_id);
	    	})
	    	.fail(function (xhr, status, errorThrown) {
                console.log("Status:", status);
			    console.log("Error in POST to Robot Framework API server: " + errorThrown.toString());
                console.log("Response:", xhr.responseText);
                alert('Executing Automation Script for Test Run ID: ' + test_run_id + ' failed. Please check the log for more details!');
	    	})

            
	    }
	);
});