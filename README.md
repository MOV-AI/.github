# .github

## - name: Publish to project data viewer
This step publishes data to the [project data viewer website](https://personal-7vf0v2cu.outsystemscloud.com/ProjectDataViewer5/). The site is used to visualize which packages are installed in the spawner container in the projects. By default this step is disabled. To enable set the `use_project_data_viewer` parameter to true in the workflow file of your project. If failed the step is skipped.

The credentials to the site is given in the [confluence page](https://movai.atlassian.net/wiki/spaces/MF/pages/2403074053/Project+Data+Viewer).