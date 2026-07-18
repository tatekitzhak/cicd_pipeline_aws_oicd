# terraform_and_gitHub_action_workflows
Automate AWS Infra Deployment using Terraform and GitHub Actions Workflows

## To create an OIDC identity provider (IdP) in AWS and specify its audience for GitHub (AWS CLI)
- Provider URL (Issuer URL): `https://token.actions.githubusercontent.com`
- Audience (Client ID): `sts.amazonaws.com`
- `https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/`

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<Account ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:sub": "repo:Ran-Itzhack/terraform_and_gitHub_action_workflows:ref:refs/heads/<ExampleBranch>",
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<Account ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:<BRANCH_NAME>/<REPOSITORY_NAME>:*"
                }
            }
        }
    ]
}
```


I Have is build scritp:

 build1:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Build Application
        run: |
          echo "Building... (simulating build output)"
          echo "This is some data" > build_output.txt

      - name: Upload Build Data
        uses: actions/upload-artifact@v4 # compresses and uploads the entire contents of your current working directory to GitHub's servers as a downloadable zip file named "build-artifact-output"
        with:
          name: build-artifact-output # This is the name required if another job needs to download it later
          path: ./build
          if-no-files-found: error

I would like do something like this:

 build1:
    name: build1
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

     
      - name: Download artifact # from triggering previous runing action workflow
        if: github.event_name == 'workflow_run'
        uses: actions/download-artifact@v4
        with:
          name: build-artifact-output
          run-id: ${{ github.event.workflow_run.id }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          path: ./build
      - run:  |
          pwd
          ls  -ltra
      - run: |
          tree .
          ls -R

organize for me the script


Error:


failed 3 minutes ago in 4s
1s
0s
0s
0s
Node 20 is being deprecated. This workflow is running with Node 24 by default. If you need to temporarily use Node 20, you can set the ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION=true environment variable. For more information see: https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
Run actions/upload-artifact@v4
  with:
    name: build-artifact-output
    path: ./build
    if-no-files-found: error
    compression-level: 6
    overwrite: false
    include-hidden-files: false
(node:2279) [DEP0040] DeprecationWarning: The `punycode` module is deprecated. Please use a userland alternative instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
Error: No files were found with the provided path: ./build. No artifacts will be uploaded.


My script:

 # --- Build application and produce artifact for CD ---
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v6

      - name: Build Application
        run: |
          echo "Building... (simulating build output)"
          echo "This is some data" > build_output.txt

      - name: Upload Build Data
        uses: actions/upload-artifact@v4 # compresses and uploads the entire contents of your current working directory to GitHub's servers as a downloadable zip file named "build-artifact-output"
        with:
          name: build-artifact-output # This is the name required if another job needs to download it later
          path: ./build
          if-no-files-found: error


