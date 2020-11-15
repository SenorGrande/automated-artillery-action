# automated-artillery-action
GitHub action to run Artillery Load Tests and output reports and logs

## Configuration
This Action will commit an Artillery HTML report to the repo it is used on. This feature requires a GitHub access token, create one for your GitHub account with permission to write to repos.
Create a secret on the repo called `TOKEN` and store the access token in the secret.
This secret will be passed as an environment variable called `GITHUB_TOKEN` to the action.

### Example Usage

The following example will allow the action to be triggered manually from the GitHub actions tab on your repo.

**Parameters**
artillery_path: Path and name of the artillery YAML file (REQUIRED)
output_path: Path for the HTML report to be pushed to (OPTIONAL) If unset, the report will be saved in the root directory of the repo.

```bash
name: Auto Artillery
on: [workflow_dispatch]

jobs:
  artillery-job:
    runs-on: ubuntu-latest
    name: Run Load Test
    steps:
    - uses: actions/checkout@v1
    - name: Artillery
      uses: SenorGrande/automated-artillery-action@v1.0.0
      env:
        GITHUB_TOKEN: ${{ secrets.TOKEN }}
      with:
        artillery_path: 'index.yml'
        output_path: 'reports'
```

To run this action with a cron, replace `on: [workflow_dispatch]` with the following:

```bash
on:
  schedule:
    - cron: '0 * * * *'
```