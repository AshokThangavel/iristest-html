# iristest-html
`iristest-html` is a lightweight HTML report generator that converts raw InterSystems IRIS `%UnitTest` output into a clean, modern, and easy-to-read HTML report. It enables you to produce clear, interactive test reports directly from InterSystems IRIS.

It helps developers, testers, and teams visualize test results, share test runs, and improve traceability in both development and CI/CD pipelines.

## 🔧 Features

- ✅ Generates HTML reports from IRIS `%UnitTest` results
- 📊 Summary of passed, failed, and skipped tests
- 🧭 Filterable and collapsible test views
- 📂 Static, portable reports (no server needed)
- ⚙️ Easy to integrate into DevOps pipelines

## ⚙️ Installation

### Clone the Repository
```bash
git clone https://github.com/AshokThangavel/iristest-html.git
cd iristest-html
````

### Running the Application with Docker

Build and start the app using Docker Compose:

```bash
docker-compose up --build
```

### Stopping the Application

To stop and remove the running containers:

```bash
docker-compose down
```
## Usage

Run the code below to set the report path:
```objectscript
do ##class(IrisTest.HTML.Report).SetUTReportHtmlPath(pPath)
```
Run the code below to get the previously defined path:
```objectscript
do ##class(IrisTest.HTML.Report).GetUTReportHtmlPath()
```

If you define the path through `SetUTReportHtmlPath()`, you do **not** need to pass the file path when generating the report.
If you *do* pass a file path, that path will be used.
Otherwise, the default location within the `manager directory` will be selected.

- **pUnitTestId** — Integer
- **pFilePath** — Directory path (file name not required)

```objectscript
set st = ##class(IrisTest.HTML.Report).GenerateReport(pUnitTestId, pFilePath)
```
On success, the generated file name is printed
