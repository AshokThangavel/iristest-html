# iristest-html
HTML report viewer and generator.

Generate clean, interactive HTML reports from InterSystems IRIS %UnitTest results — save them as static files or view them directly in your browser.

![Made with ObjectScript](https://img.shields.io/badge/made%20with-ObjectScript-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🚀 Overview

`iristest-html` is a lightweight reporting tool that transforms raw IRIS `%UnitTest` output into a modern, readable HTML report.

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
### Usage

Set the path for the generated report under the global
`^IrisTest.UTReport("html")`.

If you define `^IrisTest.UTReport("html")`, you do **not** need to pass the file path when generating the report.
If you *do* pass a file path, that path will be used.
Otherwise, the default location within the `manager directory` will be selected.

- **pUnitTestId** — Integer
- **pFilePath** — Directory path (file name not required)

```objectscript
set st = ##class(IrisTest.HTML.Report).GenerateReport(pUnitTestId, pFilePath)
```
On success, the generated file name is printed