Class IrisTest.HTML.Report Extends %RegisteredObject
{

/// Parameters
/// pUnitTestId - UnitTest Id
/// filename will be UnitTestId_yyyymmddhhmmss.html e.g 88_20250709170704.html
ClassMethod Generate(pUnitTestId As %Integer = 89, pFilePath As %String = "") as %String
{
	If pFilePath="" {
		Set pFilePath = ##class(%File).NormalizeDirectory($LG(^UTReport("html")))
	}
	Set file = ##class(%File).%New(pFilePath_pUnitTestId_"_"_$TR($ZDT($H,3)," -:")_".html")
	Set st= file.Open("NW")
	If $$$ISERR(st) {
		Write $SYSTEM.OBJ.DisplayError(st) Quit
	}
	If '$Data(^UnitTest.Result(pUnitTestId),utinfo) {
		Do file.Write("<h1> No test result found for id "_pUnitTestId_"</h1>")
		GoTo End
		Quit
	}
	Set utinfo = ^UnitTest.Result(pUnitTestId)
	Set testSuite = $O(^UnitTest.Result(pUnitTestId,""))
	Set testCase = $O(^UnitTest.Result(pUnitTestId,testSuite,""))
	;
	Set caseId=pUnitTestId_"||"_testSuite
	Set testCase1 = pUnitTestId_"||"_testSuite_"||"_testCase
	;
	&SQL(Select Status,Duration,Name INTO :status,:Duration,:Name from %UnitTest_Result.TestSuite where TestInstance=:pUnitTestId)
	;
	Set status = ..Status(status)
	Do file.WriteLine("<!DOCTYPE html>")
	Do file.WriteLine("<html>")
	Do file.WriteLine("  <head>")
	Do file.WriteLine("    <meta charset=""utf-8""/>")
#;	Do file.WriteLine("    <title id=""head-title"">"_pArgs("reportName")_"</title>")  
	Do file.WriteLine("    <title id=""head-title"">"_testCase_"</title>")  
	Do file.WriteLine("<style>")
	Do file.WriteLine("body {font-family: Helvetica, Arial, sans-serif;font-size: 12px;/* do not increase min-width as some may use split screens */min-width: 800px;color: #999;}h1 {font-size: 24px;color: black;}h2 {font-size: 16px;color: black;}p {color: black;}a {color: #999;}table {border-collapse: collapse;}/****************************** * SUMMARY INFORMATION ******************************/#environment td {padding: 5px;border: 1px solid #e6e6e6;vertical-align: top;}#environment tr:nth-child(odd) {background-color: #f6f6f6;}#environment ul {margin: 0;padding: 0 20px;}/****************************** * TEST RESULT COLORS ******************************/span.passed,.passed .col-result {color: green;}span.skipped,span.xfailed,span.rerun,.skipped .col-result,.xfailed .col-result,.rerun .col-result {color: orange;}span.error,span.failed,span.xpassed,.error .col-result,.failed .col-result,.xpassed .col-result {color: red;}.col-links__extra {margin-right: 3px;}/****************************** * RESULTS TABLE * * 1. Table Layout * 2. Extra * 3. Sorting items * ******************************//*------------------ * 1. Table Layout *------------------*/#results-table {border: 1px solid #e6e6e6;color: #999;font-size: 12px;width: 100%;}#results-table th,#results-table td {padding: 5px;border: 1px solid #e6e6e6;text-align: left;}#results-table th {font-weight: bold;}/*------------------ * 2. Extra *------------------*/.logwrapper {max-height: 230px;overflow-y: scroll;background-color: #e6e6e6;}.logwrapper.expanded {max-height: none;}.logwrapper.expanded .logexpander:after {content: ""collapse [-]"";}.logwrapper .logexpander {z-index: 1;position: sticky;top: 10px;width: max-content;border: 1px solid;border-radius: 3px;padding: 5px 7px;margin: 10px 0 10px calc(100% - 80px);cursor: pointer;background-color: #e6e6e6;}.logwrapper .logexpander:after {content: ""expand [+]"";}.logwrapper .logexpander:hover {color: #000;border-color: #000;}.logwrapper .log {min-height: 40px;position: relative;top: -50px;height: calc(100% + 50px);border: 1px solid #e6e6e6;color: black;display: block;font-family: ""Courier New"", Courier, monospace;padding: 5px;padding-right: 80px;white-space: pre-wrap;}div.media {border: 1px solid #e6e6e6;float: right;height: 240px;margin: 0 5px;overflow: hidden;width: 320px;}.media-container {display: grid;grid-template-columns: 25px auto 25px;align-items: center;flex: 1 1;overflow: hidden;height: 200px;}.media-container--fullscreen {grid-template-columns: 0px auto 0px;}.media-container__nav--right,.media-container__nav--left {text-align: center;cursor: pointer;}.media-container__viewport {cursor: pointer;text-align: center;height: inherit;}.media-container__viewport img,.media-container__viewport video {object-fit: cover;width: 100%;max-height: 100%;}.media__name,.media__counter {display: flex;flex-direction: row;justify-content: space-around;flex: 0 0 25px;align-items: center;}.collapsible td:not(.col-links) {cursor: pointer;}.collapsible td:not(.col-links):hover::after {color: #bbb;font-style: italic;cursor: pointer;}.col-result {width: 130px;}.col-result:hover::after {content: "" (hide details)"";}.col-result.collapsed:hover::after {content: "" (show details)"";}#environment-header h2:hover::after {content: "" (hide details)"";color: #bbb;font-style: italic;cursor: pointer;font-size: 12px;}#environment-header.collapsed h2:hover::after {content: "" (show details)"";color: #bbb;font-style: italic;cursor: pointer;font-size: 12px;}/*------------------ * 3. Sorting items *------------------*/.sortable {cursor: pointer;}.sortable.desc:after {content: "" "";position: relative;left: 5px;bottom: -12.5px;border: 10px solid #4caf50;border-bottom: 0;border-left-color: transparent;border-right-color: transparent;}.sortable.asc:after {content: "" "";position: relative;left: 5px;bottom: 12.5px;border: 10px solid #4caf50;border-top: 0;border-left-color: transparent;border-right-color: transparent;}.hidden, .summary__reload__button.hidden {display: none;}.summary__data {flex: 0 0 550px;}.summary__reload {flex: 1 1;display: flex;justify-content: center;}.summary__reload__button {flex: 0 0 300px;display: flex;color: white;font-weight: bold;background-color: #4caf50;text-align: center;justify-content: center;align-items: center;border-radius: 3px;cursor: pointer;}.summary__reload__button:hover {background-color: #46a049;}.summary__spacer {flex: 0 0 550px;}.controls {display: flex;justify-content: space-between;}.filters,.collapse {display: flex;align-items: center;}.filters button,.collapse button {color: #999;border: none;background: none;cursor: pointer;text-decoration: underline;}.filters button:hover,.collapse button:hover {color: #ccc;}.filter__label {margin-right: 10px;} ")
	Do file.WriteLine("</style>")
	Do file.WriteLine("  </head>")
	Do file.WriteLine("  <body>")
#;	Do file.WriteLine("    <h1 id=""title"">"_pArgs("reportName")_"</h1>")
	Do file.WriteLine("    <h1 id=""title"">"_testCase_"</h1>")
	Do file.WriteLine("    <p>Report generated on "_$LG(utinfo,1)_" by iris-ut.html</p>")
	Do file.WriteLine("    <div id=""environment-header"">")
	Do file.WriteLine("      <h2>Environment</h2>")
	Do file.WriteLine("    </div>")
	Do file.WriteLine("    <table id=""environment"">")
	Do file.WriteLine("    <!-- TEMPLATES -->")
	;Do file.WriteLine("    <template1 >")
	;
	Do file.WriteLine("      <tr>")
	Do file.WriteLine("        <td>Machine</td>")
	Do file.WriteLine("        <td>"_$LG(utinfo,3)_"</td>")
	Do file.WriteLine("      </tr>")
	;
	Do file.WriteLine("      <tr>")
	Do file.WriteLine("        <td>Instance</td>")
	Do file.WriteLine("        <td>"_$LG(utinfo,4)_"</td>")
	Do file.WriteLine("      </tr>")
	;
	Do file.WriteLine("      <tr>")
	Do file.WriteLine("        <td>version</td>")
	Do file.WriteLine("        <td>"_$LG(utinfo,5)_"</td>")
	Do file.WriteLine("      </tr>")
	;
	Do file.WriteLine("      <tr>")
	Do file.WriteLine("        <td>Namespace</td>")
	Do file.WriteLine("        <td>"_$LG(utinfo,6)_"</td>")
	Do file.WriteLine("      </tr>")
	;
	Do file.WriteLine("</table>")
	; print test suite
	;
	Do file.WriteLine("    <div class=""summary"">")
	Do file.WriteLine("      <div class=""summary__data"">")
	Do file.WriteLine("        <h2>Test Suite</h2>")
	Do file.WriteLine("        <div class=""additional-summary prefix"">")
	Do file.WriteLine("        </div>")
	Do file.WriteLine("        <p class=""run-count"">"_Name_" status <span class="""_status_""">"_status_"</span>. tests took "_Duration_" s.</p>")
	;
	; print testcase
	&SQL(Select Name,Duration,Status,ErrorAction,ErrorDescription INTO
					:Name,:Duration,:Status,:ErrorAction,:ErrorDescription
			 from %UnitTest_Result.TestCase where TestSuite=:caseId)
	Set Status =..Status(status)
	;
	Do file.WriteLine("        <h2>Test case</h2>")
	Do file.WriteLine("    <div class=""summary"">")
	Do file.WriteLine("      <div class=""summary__data"">")
	Do file.WriteLine("        <div class=""additional-summary prefix"">")
	Do file.WriteLine("        </div>")
	Do file.WriteLine("        <p class=""run-count"">"_Name_" status <span class="""_Status_""">"_Status_"</span>. tests took "_Duration_" s.</p>")
	;
	Do file.WriteLine("        <p class=""filter"">(Un)check the boxes to filter the results.</p>")
	; print check box
	&SQL(
		Select   SUM(CASE WHEN Status = 0 THEN 1 ELSE 0 END) AS failed,
		SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS passed,
		SUM(CASE WHEN Status = 2 THEN 1 ELSE 0 END) AS skipped
		INTO :failed,:passed,:skipped
		from %UnitTest_Result.TestMethod where TestCase=:testCase1
	)
	;
	Do file.WriteLine("        <div class=""summary__reload"">")
	Do file.WriteLine("          <div class=""summary__reload__button hidden"" onclick=""location.reload()"">")
	Do file.WriteLine("            <div>There are still tests running. <br />Reload this page to get the latest results!</div>")
	Do file.WriteLine("          </div>")
	Do file.WriteLine("        </div>")
	Do file.WriteLine("        <div class=""summary__spacer""></div>")
	Do file.WriteLine("        <div class=""controls"">")
	Do file.WriteLine("          <div class=""filters"">")
	Do file.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""failed"" />")
	Do file.WriteLine("            <span class=""failed"">"_failed_" Failed,</span>")
	Do file.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""passed"" />")
	Do file.WriteLine("            <span class=""passed"">"_passed_" Passed,</span>")
	Do file.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""skipped"" disabled/>")
	Do file.WriteLine("            <span class=""skipped"">"_skipped_" Skipped</span>")
	Do file.WriteLine("          </div>")
	Do file.WriteLine("          <div class=""collapse"">")
	Do file.WriteLine("            <button id=""show_all_details"">Show all details</button>&nbsp;/&nbsp;<button id=""hide_all_details"">Hide all details</button>")
	Do file.WriteLine("          </div>")
	Do file.WriteLine("        </div>")
	Do file.WriteLine("      </div>")
	;
	Do file.WriteLine("      <div class=""additional-summary summary"">")
	Do file.WriteLine("      </div>")
	Do file.WriteLine("      <div class=""additional-summary postfix"">")
	Do file.WriteLine("      </div>")
	Do file.WriteLine("    </div>")
	;
	; Print test result
	Do file.WriteLine("    <table id=""results-table"">")
	Do file.WriteLine("      <thead id=""results-table-head"">")
	Do file.WriteLine("        <tr>")
	Do file.WriteLine("          <th class=""sortable"" data-column-type=""result"">Result</th>")
	Do file.WriteLine("          <th class=""sortable"" data-column-type=""testId"">Test</th>")
	Do file.WriteLine("          <th class=""sortable"" data-column-type=""duration"">Duration</th>")
	Do file.WriteLine("          <th>Links</th>")
	Do file.WriteLine("        </tr>")
	Do file.WriteLine("      </thead>")
	;
	; print test cases
	Set case=""
	For {
		Set case=$O(^UnitTest.Result(pUnitTestId,testSuite,testCase,case),1,data) Quit:case=""
		Set status = ..Status($LG(data,1))
		Do file.WriteLine("<tbody class=""results-table-row "_status_""" id=""testi.py::test_failure"">")
		Do file.WriteLine("<tr class=""collapsible"" data-id=""test_2"">")
		Do file.WriteLine("<td class=""col-result collapsed"">"_status_"</td><td class=""col-testId"">"_case_"</td><td class=""col-duration"">"_$LG(data,2)_"</td><td class=""col-links""></td></tr>")
		;
		Set caseDetails = ""
		set data=""
		Do file.WriteLine("  <tr class=""extras-row"">")
		Do file.WriteLine("    <td class=""extra"" colspan=""4"">")
		Do file.WriteLine("      <div class=""extraHTML""></div>")
		Do file.WriteLine("      <div class=""media hidden"">")
		Do file.WriteLine("        <div class=""media-container"">")
		Do file.WriteLine("          <div class=""media-container__nav--left"">&lt;</div>")
		Do file.WriteLine("          <div class=""media-container__viewport"">")
		Do file.WriteLine("            <img src="""">")
		Do file.WriteLine("            <video controls="""">")
		Do file.WriteLine("              <source src="""" type=""video/mp4"">")
		Do file.WriteLine("            </video>")
		Do file.WriteLine("          </div>")
		Do file.WriteLine("          <div class=""media-container__nav--right"">&gt;</div>")
		Do file.WriteLine("        </div>")
		Do file.WriteLine("        <div class=""media__name""></div>")
		Do file.WriteLine("        <div class=""media__counter""></div>")
		Do file.WriteLine("      </div>")
		Do file.WriteLine("      <div class=""logwrapper"">")
		Do file.WriteLine("        <div class=""logexpander""></div>")
		Do file.WriteLine("        <div class=""log"">")
		For {
			Set caseDetails=$O(^UnitTest.Result(pUnitTestId,testSuite,testCase,case,caseDetails),1,data) Quit:caseDetails=""
			Set mstatus = ..Status($LG(data))
			Do file.WriteLine("<span><span class="""_mstatus_""">"_mstatus_"</span> "_ $TR($LTS($Li(data,2,4)),","," ")_"</span><br>")
		}
		Do file.WriteLine("</div>")
		Do file.WriteLine("      </div>")
		Do file.WriteLine("    </td>")
		Do file.WriteLine("  </tr>")
		Do file.WriteLine("</tbody>")
	}
	; end of print test cases
	Do file.WriteLine("    </table>")
	Do file.WriteLine("  </body>")
	Do file.WriteLine("  <footer>")
	;
	;close file
End	Do file.Close()
	Quit file.Name
}

/// setup file generated path
ClassMethod SetUTReportHtmlPath(path = "")
{
	Set ^UTReport("html") = $LB(path,$ZDT($NOW()))
}

ClassMethod Status(status As %Integer) [ CodeMode = expression ]
{
$Case(status,0:"failed",1:"passed",:"skipped")
}

}
