# iristest-html
HTML report viewer and generator.

Generate clean, interactive HTML reports from InterSystems IRIS %UnitTest results — save them as static files or view them directly in your browser.

![Made with ObjectScript](https://img.shields.io/badge/made%20with-ObjectScript-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🚀 Overview

`iristest-html` is a lightweight reporting tool that transforms raw IRIS `%UnitTest` output into a modern, readable HTML report — inspired by tools like `pytest-html`.

It helps developers, testers, and teams visualize test results, share test runs, and improve traceability in both development and CI/CD pipelines.

---

## 📸 Example

![HTML Report Screenshot](docs/example-report.png)

---

## 🔧 Features

- ✅ Generates HTML reports from IRIS `%UnitTest` results
- 📊 Summary of passed, failed, and skipped tests
- 🧭 Filterable and collapsible test views
- 📂 Static, portable reports (no server needed)
- ⚙️ Easy to integrate into DevOps pipelines

---

## 📦 Installation

You can install the utility as part of your IRIS project or package it as a ZPM module (coming soon).

For now, clone the repo or include the class in your environment:

```objectscript
; Load the class
Do $System.OBJ.Load("src/IrisTestHTML/Report.cls", "ck")

; Generate report
; file path is optional
; global for default fetch set ^UTReport("html") = $LB(filepath) 
Do ##class(IrisTest.HTML.Report).Generate(UnitTestId,filePath)
```
## Docker support
### Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.
### Installation
Clone/git pull the repo into any local directory
```
$ git clone https://github.com/rcemper/PR_iristest-html.git
```
To build and start the container run:
```
$ docker compose up -d && docker compose logs -f
```
To open IRIS Terminal do:
```
$ docker-compose exec iris iris session iris
USER>
```
or using **iTerm**:     
[http://localhost:42773/iterm/](http://localhost:42773/iterm/)    

To access IRIS System Management Portal:    
[http://localhost:42773/csp/sys/UtilHome.csp](http://localhost:42773/csp/sys/UtilHome.csp)

To access IRIS Standard Unit Test Portal:    
[http://localhost:42773/csp/sys/%25UnitTest.Portal.Home.zen?$NAMESPACE=USER](http://localhost:42773/csp/sys/%25UnitTest.Portal.Home.zen?$NAMESPACE=USER)

Viewing the last example produced during startup:    
[http://localhost:42773/csp/user/IrisTest.HTML.Viewer.cls](http://localhost:42773/csp/user/IrisTest.HTML.Viewer.cls)

