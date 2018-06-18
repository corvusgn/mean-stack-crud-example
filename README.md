# Tutorial Building CRUD App from Scratch using MEAN Stack (Angular 2)

+ [Documentation for jenkins job: mean_build](#jj1)
    + [Variables](#Table1)

This source code is part of tutorial [Tutorial Building CRUD App from Scratch using MEAN Stack (Angular 2)](https://www.djamware.com/post/58cf4e1c80aca72df8d1cf7e/tutorial-building-crud-app-from-scratch-using-mean-stack-angular-2)

If you think this source code is useful, it will be great if you just give it star or just buy me a cup of cofee [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5WK24UVWUGBN)

# MeanApp

This project was generated with [angular-cli](https://github.com/angular/angular-cli) version 1.0.0-beta.28.3.

## Development server
Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive/pipe/service/class/module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `-prod` flag for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).
Before running the tests make sure you are serving the app via `ng serve`.

## Deploying to GitHub Pages

Run `ng github-pages:deploy` to deploy to GitHub Pages.

## Further help

To get more help on the `angular-cli` use `ng help` or go check out the [Angular-CLI README](https://github.com/angular/angular-cli/blob/master/README.md).

## <a name="jj1"></a> Documentation for jenkins job: mean_build

This job automatically builds docker image from [mean-stack-crud-example](https://github.com/unicanova/mean-stack-crud-example), when you pushing something, no matter what, in repository and pushed it to google container registry. After that, installs a helm chart or performs its upgrade. 
You can start this job manually in Jenkins UI, for this you need to specify following [variables](#Table1)

#### <a name="Table1"></a> Variables

| Variable name | Variables description | Default Value |
| ------------- | --------------------- | ------------- |
| gitRepo | A link to the repository from which the image will be compiled (in the repository should be Dockerfile) | https://github.com/unicanova/mean-stack-crud-example |
| gitChartRepo | helm chart repository | git@github.com:unicanova/blockchain-app.git |
| realCommitSha | Full commit SHA, from which the image will be builded | not specified |
| registryURL | Docker private registry address, where the image will be pushed | https:/gcr.io |
| registryName | Docker private registry name (It is necessary for the image to be in the repository) | gcr.io/trusty-gradient-182808 |
| imageName | Docker image name | mean |
| buildBranchName | the name of the branch from which to build docker image | not specified |
| gitCredentials | credentials id for git repository | 42345-3453-53756-25678589 |
| releaseName | name of release | blockchain-app |
| googleContainerRegistryCreds | credentials for google container registry | secret-gce-creds |
| googleKuberDeployer | credentials for deploy to kubernetes cluster | kubernetes_secret |
| zone | zone of kubernetes cluster | europe-west1-b |
| projectName | project name in GCE | trusty-gradient-182808 |
| TEST | on/off test app in docker container (repositroy must contain second Dockerfile named Dockerfile.test) | off |
