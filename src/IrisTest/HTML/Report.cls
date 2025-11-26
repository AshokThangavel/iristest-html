Class IrisTest.HTML.Report Extends %RegisteredObject
{
Property FileName As %String(MAXLEN = 150);

Property AbsoluteFileName As %String(MAXLEN = 5000);

Property UnitTestId As %Integer;

Property HTMLStream As %Stream.TmpCharacter;

Parameter UTResultGbl As STRING = "^UnitTest.Result";

Parameter UTReportGbl As STRING = "^IrisTest.UTReport";

/// Parameters
/// pUnitTestId - UnitTest Id
/// filename will be "ut-"_UnitTestId_yyyymmddhhmmss.html e.g ut-88_20250709170704.html
ClassMethod GenerateReport(pUnitTestId As %Integer = "", pFilePath As %String = "")
{
    if 'pUnitTestId||('$data(@..#UTResultGbl(pUnitTestId))) {
        return $$$ERROR($$$GeneralError,"unit test id is invalid")
    }
    set obj = ..%New(pUnitTestId, pFilePath)
    do obj.Generate()
    return $$$OK
}

Method Generate() As %Status
{
    set tUnitTestId = ..UnitTestId
    if '$data(@..#UTResultGbl(..UnitTestId),utinfo) {
		do ..HTMLStream.Write("<h1> No test result found for id "_..UnitTestId_"</h1>")
        goto End
		quit
	}
    do ..BuildSystemInfo()
    set testSuite=""
    for {
        set testSuite = $order(@..#UTResultGbl(tUnitTestId,testSuite)) quit:testSuite=""
        set testCase=""
        for {
            set testCase = $order(@..#UTResultGbl(tUnitTestId,testSuite,testCase)) quit:testCase=""
            ;
            set caseId=tUnitTestId_"||"_testSuite
            set testCase1 = tUnitTestId_"||"_testSuite_"||"_testCase
            ;
            &SQL(Select Status,Duration,Name INTO :status,:Duration,:Name from %UnitTest_Result.TestSuite where TestInstance=:tUnitTestId)
            ;
            set status = ..Status(status)
            ; print test suite
            ;
            do ..HTMLStream.WriteLine("    <div class=""summary"">")
            do ..HTMLStream.WriteLine("      <div class=""summary__data"">")
            do ..HTMLStream.WriteLine("        <h2>Test Suite</h2>")
            do ..HTMLStream.WriteLine("        <div class=""additional-summary prefix"">")
            do ..HTMLStream.WriteLine("        </div>")
            do ..HTMLStream.WriteLine("        <p class=""run-count""> <b>"_testSuite_"</b> status <span class="""_status_""">"_status_"</span>. tests took "_Duration_" s.</p>")
            ;
            ; print testcase
            &SQL(Select Name,Duration,Status,ErrorAction,ErrorDescription INTO
                            :Name,:Duration,:Status,:ErrorAction,:ErrorDescription
                    from %UnitTest_Result.TestCase where TestSuite=:caseId)
            set Status =..Status(status)
            ;
            do ..HTMLStream.WriteLine("        <h2>Test case</h2>")
            do ..HTMLStream.WriteLine("    <div class=""summary"">")
            do ..HTMLStream.WriteLine("      <div class=""summary__data"">")
            do ..HTMLStream.WriteLine("        <div class=""additional-summary prefix"">")
            do ..HTMLStream.WriteLine("        </div>")
            do ..HTMLStream.WriteLine("        <p class=""run-count""> <b>"_Name_"</b> status <span class="""_Status_""">"_Status_"</span>. tests took "_Duration_" s.</p>")
            ;
            do ..HTMLStream.WriteLine("        <p class=""filter"">(Un)check the boxes to filter the results.</p>")
            ; print check box
            &SQL(
                Select   SUM(CASE WHEN Status = 0 THEN 1 ELSE 0 END) AS failed,
                SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS passed,
                SUM(CASE WHEN Status = 2 THEN 1 ELSE 0 END) AS skipped
                INTO :failed,:passed,:skipped
                from %UnitTest_Result.TestMethod where TestCase=:testCase1
            )
            ;
            do ..HTMLStream.WriteLine("        <div class=""summary__reload"">")
            do ..HTMLStream.WriteLine("          <div class=""summary__reload__button hidden"" onclick=""location.reload()"">")
            do ..HTMLStream.WriteLine("            <div>There are still tests running. <br />Reload this page to get the latest results!</div>")
            do ..HTMLStream.WriteLine("          </div>")
            do ..HTMLStream.WriteLine("        </div>")
            do ..HTMLStream.WriteLine("        <div class=""summary__spacer""></div>")
            do ..HTMLStream.WriteLine("        <div class=""controls"">")
            do ..HTMLStream.WriteLine("          <div class=""filters"">")
            do ..HTMLStream.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""failed"" />")
            do ..HTMLStream.WriteLine("            <span class=""failed"">"_failed_" Failed,</span>")
            do ..HTMLStream.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""passed"" />")
            do ..HTMLStream.WriteLine("            <span class=""passed"">"_passed_" Passed,</span>")
            do ..HTMLStream.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""skipped"" disabled/>")
            do ..HTMLStream.WriteLine("            <span class=""skipped"">"_skipped_" Skipped</span>")
            do ..HTMLStream.WriteLine("          </div>")
            do ..HTMLStream.WriteLine("          <div class=""collapse"">")
            do ..HTMLStream.WriteLine("            <button id=""show_all_details"">Show all details</button>&nbsp;/&nbsp;<button id=""hide_all_details"">Hide all details</button>")
            do ..HTMLStream.WriteLine("          </div>")
            do ..HTMLStream.WriteLine("        </div>")
            do ..HTMLStream.WriteLine("      </div>")
            ;
            do ..HTMLStream.WriteLine("      <div class=""additional-summary summary"">")
            do ..HTMLStream.WriteLine("      </div>")
            do ..HTMLStream.WriteLine("      <div class=""additional-summary postfix"">")
            do ..HTMLStream.WriteLine("      </div>")
            do ..HTMLStream.WriteLine("    </div>")
            ;
            ; Print test result
            do ..HTMLStream.WriteLine("    <table id=""results-table"">")
            do ..HTMLStream.WriteLine("      <thead id=""results-table-head"">")
            do ..HTMLStream.WriteLine("        <tr>")
            do ..HTMLStream.WriteLine("          <th class=""sortable"" data-column-type=""result"">Result</th>")
            do ..HTMLStream.WriteLine("          <th class=""sortable"" data-column-type=""testId"">Test</th>")
            do ..HTMLStream.WriteLine("          <th class=""sortable"" data-column-type=""duration"">Duration</th>")
            do ..HTMLStream.WriteLine("          <th>Links</th>")
            do ..HTMLStream.WriteLine("        </tr>")
            do ..HTMLStream.WriteLine("      </thead>")
            ;
            ; print test cases
            set case=""
            for {
                set case=$order(@..#UTResultGbl(tUnitTestId,testSuite,testCase,case),1,data) quit:case=""
                set status = ..Status($listget(data,1))
                do ..HTMLStream.WriteLine("<tbody class=""results-table-row "_status_""" id=""testi.py::test_failure"">")
                do ..HTMLStream.WriteLine("<tr class=""collapsible"" data-id=""test_2"">")
                do ..HTMLStream.WriteLine("<td class=""col-result collapsed"">"_status_"</td><td class=""col-testId"">"_case_"</td><td class=""col-duration"">"_$listget(data,2)_"</td><td class=""col-links""></td></tr>")
                ;
                set caseDetails = ""
                set data=""
                do ..HTMLStream.WriteLine("  <tr class=""extras-row"">")
                do ..HTMLStream.WriteLine("    <td class=""extra"" colspan=""4"">")
                do ..HTMLStream.WriteLine("      <div class=""extraHTML""></div>")
                do ..HTMLStream.WriteLine("      <div class=""media hidden"">")
                do ..HTMLStream.WriteLine("        <div class=""media-container"">")
                do ..HTMLStream.WriteLine("          <div class=""media-container__nav--left"">&lt;</div>")
                do ..HTMLStream.WriteLine("          <div class=""media-container__viewport"">")
                do ..HTMLStream.WriteLine("            <img src="""">")
                do ..HTMLStream.WriteLine("            <video controls="""">")
                do ..HTMLStream.WriteLine("              <source src="""" type=""video/mp4"">")
                do ..HTMLStream.WriteLine("            </video>")
                do ..HTMLStream.WriteLine("          </div>")
                do ..HTMLStream.WriteLine("          <div class=""media-container__nav--right"">&gt;</div>")
                do ..HTMLStream.WriteLine("        </div>")
                do ..HTMLStream.WriteLine("        <div class=""media__name""></div>")
                do ..HTMLStream.WriteLine("        <div class=""media__counter""></div>")
                do ..HTMLStream.WriteLine("      </div>")
                do ..HTMLStream.WriteLine("      <div class=""logwrapper"">")
                do ..HTMLStream.WriteLine("        <div class=""logexpander""></div>")
                do ..HTMLStream.WriteLine("        <div class=""log"">")
                for {
                    set caseDetails=$order(@..#UTResultGbl(tUnitTestId,testSuite,testCase,case,caseDetails),1,data) quit:caseDetails=""
                    set mstatus = ..Status($listget(data))
                    do ..HTMLStream.WriteLine("<span><span class="""_mstatus_""">"_mstatus_"</span> "_ $translate($listtostring($list(data,2,4)),","," ")_"</span><br>")
                }
                do ..HTMLStream.WriteLine("</div>")
                do ..HTMLStream.WriteLine("      </div>")
                do ..HTMLStream.WriteLine("    </td>")
                do ..HTMLStream.WriteLine("  </tr>")
                do ..HTMLStream.WriteLine("</tbody>")
            }
            ; end of print test cases
            do ..HTMLStream.WriteLine("    </table>")
            }
    }
	do ..HTMLStream.WriteLine("  </body>")
End
    do ..HTMLStream.WriteLine("  </html>")
    set htmlFileBin = ##class(%Stream.FileBinary).%New()
    set htmlFileBin.Filename=..AbsoluteFileName
    set sc = htmlFileBin.CopyFromAndSave(..HTMLStream)
    if $$$ISERR(sc){
        return sc
    }
    else {
        write !,"fileName is : ",..AbsoluteFileName
    }
	return $$$OK
}

/// setup file generated path
ClassMethod SetUTReportHtmlPath(path As %String)
{
	set @..#UTReportGbl("html") = $listbuild(path,$zdatetime($now()))
}

ClassMethod Status(status As %Integer) [ CodeMode = expression ]
{
$case(status,0:"failed",1:"passed",:"skipped")
}

Method BuildSystemInfo()
{
    set utinfo = $get(@..#UTResultGbl(..UnitTestId))
	do ..HTMLStream.WriteLine("<!DOCTYPE html>")
	do ..HTMLStream.WriteLine("<html>")
	do ..HTMLStream.WriteLine("  <head>")
	do ..HTMLStream.WriteLine("    <meta charset=""utf-8""/>")
	do ..HTMLStream.WriteLine("    <title id=""head-title"">"_..FileName_"</title>")
	do ..HTMLStream.WriteLine("<style>")
	do ..HTMLStream.WriteLine("body {font-family: Helvetica, Arial, sans-serif;font-size: 12px;/* do not increase min-width as some may use split screens */min-width: 800px;color: #999;}h1 {font-size: 24px;color: black;}h2 {font-size: 16px;color: black;}p {color: black;}a {color: #999;}table {border-collapse: collapse;}/****************************** * SUMMARY INFORMATION ******************************/#environment td {padding: 5px;border: 1px solid #e6e6e6;vertical-align: top;}#environment tr:nth-child(odd) {background-color: #f6f6f6;}#environment ul {margin: 0;padding: 0 20px;}/****************************** * TEST RESULT COLORS ******************************/span.passed,.passed .col-result {color: green;}span.skipped,span.xfailed,span.rerun,.skipped .col-result,.xfailed .col-result,.rerun .col-result {color: orange;}span.error,span.failed,span.xpassed,.error .col-result,.failed .col-result,.xpassed .col-result {color: red;}.col-links__extra {margin-right: 3px;}/****************************** * RESULTS TABLE * * 1. Table Layout * 2. Extra * 3. Sorting items * ******************************//*------------------ * 1. Table Layout *------------------*/#results-table {border: 1px solid #e6e6e6;color: #999;font-size: 12px;width: 100%;}#results-table th,#results-table td {padding: 5px;border: 1px solid #e6e6e6;text-align: left;}#results-table th {font-weight: bold;}/*------------------ * 2. Extra *------------------*/.logwrapper {max-height: 230px;overflow-y: scroll;background-color: #e6e6e6;}.logwrapper.expanded {max-height: none;}.logwrapper.expanded .logexpander:after {content: ""collapse [-]"";}.logwrapper .logexpander {z-index: 1;position: sticky;top: 10px;width: max-content;border: 1px solid;border-radius: 3px;padding: 5px 7px;margin: 10px 0 10px calc(100% - 80px);cursor: pointer;background-color: #e6e6e6;}.logwrapper .logexpander:after {content: ""expand [+]"";}.logwrapper .logexpander:hover {color: #000;border-color: #000;}.logwrapper .log {min-height: 40px;position: relative;top: -50px;height: calc(100% + 50px);border: 1px solid #e6e6e6;color: black;display: block;font-family: ""Courier New"", Courier, monospace;padding: 5px;padding-right: 80px;white-space: pre-wrap;}div.media {border: 1px solid #e6e6e6;float: right;height: 240px;margin: 0 5px;overflow: hidden;width: 320px;}.media-container {display: grid;grid-template-columns: 25px auto 25px;align-items: center;flex: 1 1;overflow: hidden;height: 200px;}.media-container--fullscreen {grid-template-columns: 0px auto 0px;}.media-container__nav--right,.media-container__nav--left {text-align: center;cursor: pointer;}.media-container__viewport {cursor: pointer;text-align: center;height: inherit;}.media-container__viewport img,.media-container__viewport video {object-fit: cover;width: 100%;max-height: 100%;}.media__name,.media__counter {display: flex;flex-direction: row;justify-content: space-around;flex: 0 0 25px;align-items: center;}.collapsible td:not(.col-links) {cursor: pointer;}.collapsible td:not(.col-links):hover::after {color: #bbb;font-style: italic;cursor: pointer;}.col-result {width: 130px;}.col-result:hover::after {content: "" (hide details)"";}.col-result.collapsed:hover::after {content: "" (show details)"";}#environment-header h2:hover::after {content: "" (hide details)"";color: #bbb;font-style: italic;cursor: pointer;font-size: 12px;}#environment-header.collapsed h2:hover::after {content: "" (show details)"";color: #bbb;font-style: italic;cursor: pointer;font-size: 12px;}/*------------------ * 3. Sorting items *------------------*/.sortable {cursor: pointer;}.sortable.desc:after {content: "" "";position: relative;left: 5px;bottom: -12.5px;border: 10px solid #4caf50;border-bottom: 0;border-left-color: transparent;border-right-color: transparent;}.sortable.asc:after {content: "" "";position: relative;left: 5px;bottom: 12.5px;border: 10px solid #4caf50;border-top: 0;border-left-color: transparent;border-right-color: transparent;}.hidden, .summary__reload__button.hidden {display: none;}.summary__data {flex: 0 0 550px;}.summary__reload {flex: 1 1;display: flex;justify-content: center;}.summary__reload__button {flex: 0 0 300px;display: flex;color: white;font-weight: bold;background-color: #4caf50;text-align: center;justify-content: center;align-items: center;border-radius: 3px;cursor: pointer;}.summary__reload__button:hover {background-color: #46a049;}.summary__spacer {flex: 0 0 550px;}.controls {display: flex;justify-content: space-between;}.filters,.collapse {display: flex;align-items: center;}.filters button,.collapse button {color: #999;border: none;background: none;cursor: pointer;text-decoration: underline;}.filters button:hover,.collapse button:hover {color: #ccc;}.filter__label {margin-right: 10px;} ")
	do ..HTMLStream.WriteLine("</style>")
	do ..HTMLStream.WriteLine("  </head>")
	do ..HTMLStream.WriteLine("  <body>")
	do ..HTMLStream.WriteLine("    <h1 id=""title"">"_..FileName_"</h1>")
	do ..HTMLStream.WriteLine("    <p>Report generated on "_$listget(utinfo,1)_" by iris-ut.html</p>")
	do ..HTMLStream.WriteLine("    <div id=""environment-header"">")
	do ..HTMLStream.WriteLine("      <h2>Environment</h2>")
	do ..HTMLStream.WriteLine("    </div>")
	do ..HTMLStream.WriteLine("    <table id=""environment"">")
	do ..HTMLStream.WriteLine("    <!-- TEMPLATES -->")
	;Do ..HTMLStream.WriteLine("    <template1 >")
	;
	do ..HTMLStream.WriteLine("      <tr>")
	do ..HTMLStream.WriteLine("        <td>Machine</td>")
	do ..HTMLStream.WriteLine("        <td>"_$listget(utinfo,3)_"</td>")
	do ..HTMLStream.WriteLine("      </tr>")
	;
	do ..HTMLStream.WriteLine("      <tr>")
	do ..HTMLStream.WriteLine("        <td>Instance</td>")
	do ..HTMLStream.WriteLine("        <td>"_$listget(utinfo,4)_"</td>")
	do ..HTMLStream.WriteLine("      </tr>")
	;
	do ..HTMLStream.WriteLine("      <tr>")
	do ..HTMLStream.WriteLine("        <td>version</td>")
	do ..HTMLStream.WriteLine("        <td>"_$listget(utinfo,5)_"</td>")
	do ..HTMLStream.WriteLine("      </tr>")
	;
	do ..HTMLStream.WriteLine("      <tr>")
	do ..HTMLStream.WriteLine("        <td>Namespace</td>")
	do ..HTMLStream.WriteLine("        <td>"_$listget(utinfo,6)_"</td>")
	do ..HTMLStream.WriteLine("      </tr>")
	;
	do ..HTMLStream.WriteLine("</table>")
}

Method %OnNew(pUnitTestId As %Integer = "", pFilePath As %String = "") As %Status
{
    set ..UnitTestId = pUnitTestId
    set ..FileName = "ut-"_..UnitTestId_$translate($zdatetime($horolog,3)," -:")_".html"
	set tAbsoluteFileName=""
	if $data(@..#UTReportGbl("html"),filepath) {
		set tAbsoluteFileName = ##class(%File).NormalizeDirectory($listget(filepath))_..FileName
	}
    elseif pFilePath'="" {
		set tAbsoluteFileName = ##class(%File).NormalizeDirectory(pFilePath)_..FileName
	}
	else{
		set tAbsoluteFileName = ##class(%File).NormalizeDirectory($SYSTEM.Util.ManagerDirectory())_..FileName
	}
	set:tAbsoluteFileName'="" ..AbsoluteFileName=tAbsoluteFileName
    return $$$OK
}

}