# CICD Template for Shiny web apps hosted on Azure

## Description

This is a template repo that makes it as easy to develop and deploy shiny apps on Azure using Docker images. With very little configuration, the Shiny CI/CD pipeline is easily automated.

The CICD pipline does the following:
1. Deploy a container registry
2. Build a Docker image running the provided R script
3. Push the image to the registry
4. Deploy a web app
5. (Optional) Enable Key vault access

Commits to 'main' triggers a workflow run that deploys a container image for testing. It may also be triggered manually. 

A second workflow deploying a webapp for production use may be triggered manually. 

## Getting started

### Clone the repo and connect with GitHub

If using RStudio, the simplest approach might be to create a new project via version control.

*Should this fail, you may not have the necessary permissions to clone repos within the organisation. You may need to generate personal access token (PAT) and use the `git clone <repo-url>` command from a terminal.*

1. Go to File > New Project > Version Control > Git
2. Paste in the url for this repo and provide your own name for the project
3. Click Create Project
4. Open a terminal in RStudio (it should open in the current working directory) and run the following commands:

```
git remote set-url origin <url-for-this-repo>
git push
```

Your local project is now connected to your new GitHub repo.
Changes can be committed through the RStudio interface or the command line, e.g. as shown below.

```
git add .
git commit -m "a short message describing any changes"
git push
```

Note that the GitHub Actions workflow, which builds and deploys your web app, is triggered by commits to the 'main' branch. You may therefore want to commit your work using feature branches. `git checkout -b feature_branch_name` and `git switch` are useful commands.

### Required code changes

Make sure to modify the following files:

- app.R
  
- install_deps.R
    - There are other ways to install R packages, but this will be most familiar to R users.

- .github/workflows/workflow.yml and .github/workflows/workflow_release_prod.yml
   1. set the correct values for all variables under `ENV:`

### Connecting GitHub to Azure

For the workflow to work, GitHub must be granted permission to make changes to your Azure environment. This can be done using the Azure CLI.

1. First, login to Azure. The command opens a browser window with the Azure login page.

```
az login
```

The value for "id" in the JSON output will be your subscription id.

2. Then, run the following command to create a Service Principal with access to your resource group. Please see the note below regarding permissions and roles.

```
az ad sp create-for-rbac \
      --name "appname" \
      --role Owner \
      --scopes /subscriptions/<your-subscription-id>/resourceGroups/<your-resource-group-name> \
      --sdk-auth
```

*Note: if you get an error saying "No connection adapters were found...", run the command below and try again.*

```
export MSYS_NO_PATHCONV=1
```

*Note that using the 'Owner' role is not considered best practice as it allows the SP to perform much more than we actually need. You may therefore choose to create a more restricted custom role and assign it to the SP. This may be based on the Contributor role with added permissions to assign managed identities.*

3. Copy the JSON output.
4. In your GitHub repo, go to Settings > Secrets and variables > Actions
5. Create a new repository secret. It should be called AZURE_CREDENTIALS and its value should be the JSON string you just copied.

### Testing your Dockerized SHiny app locally

The below commands build and run a Docker image. You will need to have Docker Desktop installed.

```
docker build -t appname .
docker run -p 3838:3838 imagename
```

The -t (tag) parameter lets you provide a name for you Docker image. Make sure you're running these commands from the directory where the Dockerfile is located. The dot (.) indicates that the files and folders used to build the image are in the current directory.

The -p parameter assigns a port mapping. You might have notices that the Docker Image exposes port 3838.

## Deploying for test and production

The GitHub Actions workflow is set up such that test releases are triggered by commits to the main branch. The test release wortkflow may also be triggered manually. Deployment of apps for production use can only be triggered manually. This setup is intended as a safeguard allowing users to test that the test application runs correctly before deploying the same changes that go into production.

### Post-deployment setup

After deployment, there are a number of settings to consider. For instance, you may choose to scale you app depending on your requirements or setup an identity provider and require users to authenticate. 


