# App Library

### Overview

The app library is a set or Tercen operators that reach a particular development standard. An operator will be added to the library if:
* it can be installed on Tercen
* it includes unit tests and testing is successful
* it conforms to the expected standards of operator repository structure and content

### Automated checks

* Results in library-report.json
* CI and Release workflows are populated -> if not, put in the no_test or no_release_operators list
* Tests are successful -> success_operators (if not, failed_operators)

### Manual checks

* Operator functionality is not redundant with another one
* Repository name is compliant with the developer's guide recommendations
* Repository description is populated and relevant
* README file is populated and relevant
* Operator usage section is populated and accurate (input projection, properties, output relations)
* Operator.json is compliant with the developer's guide recommendations (URL, tags, container version)
* Semantic versioning is used

### Operator resource settings

* operator_resource_settings_auto.json
* operator_resource_settings_custom.json
