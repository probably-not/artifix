# Artifix

A mono-repo style repository with CI/CD via GitHub Actions and Terraform which allows one to create a private, globally scaled, protected Hex Registry on top of S3 and Cloudfront.

The idea behind Artifix is as follows:
- All of the packages that your organization uses as dependencies should be placed inside the [`packages/`](packages/) directory. 
- The packages directory should contain inside of it only Mix projects, specifically, Mix projects which are "ready-to-package".
- Each package will first have its tests run with `mix test`. Should the tests for one package fail, the whole pipeline will fail.
- Each package will be built with `mix hex.build` to build a tarball of the package.
- Everything is driven by the CI/CD pipeline, which will build the child packages and build the Hex Registry structure.
- The Hex Registry will be uploaded to S3.
- A CloudFront Distribution will be placed above the S3 bucket to allow for global caching of the packages.
- If an auth key (or a list of auth keys) is given, a CloudFront Function will be added to the CloudFront Distribution, along with a CloudFront KeyValueStore, which can be used to authenticate and protect the Hex Registry.

## Working with Artifix

This is a template repository, with certain things that you will need to replace and update as you create a new repository from it. You can start by creating a repository from the template.

### Preparing your AWS Account

Artifix uses GitHub Actions to apply the Terraform plan found in the [`terraform/`](terraform/) directory to your AWS Account. This means that you will need to prepare your AWS Account to allow GitHub Actions to assume IAM Roles in the account. The workflows use the [`configure-aws-credentials` action](https://github.com/aws-actions/configure-aws-credentials) to configure credentials - so follow the instructions found there to create an OIDC provider for GitHub, and set up an IAM Role for your repository with the following minimum permissions:

```json
{}
```

### Replacing References to Me!

I, [@probably-not](https://github.com/probably-not), own this repository. So, there's a few different references to me in various files - luckily, these can be easily replaced!

First, the [`CODEOWNERS`](.github/CODEOWNERS) file. I'm the owner of this repository, so I'm the one marked in the CODEOWNERS. For yours - make sure you are marked as the CODEOWNER. You may also remove this file completely - it is up to you whether you want to keep it or not.

Next, the [`dependabot.yml`](.github/dependabot.yml) file. I typically use Dependabot to keep my dependencies up to date. Here, the Dependabot configuration is set specifically to keep the GitHub actions and the Terraform details up to date, with me as the reviewer. You can keep this file, you can also remove it if you want to manage dependency updates with a different tool. If you do keep it, just make sure that again - you are marked as the reviewer and not me.

### Configuring the Repository

Once you've made sure that your AWS Account is prepared, and that you've finished replacing references to me from within the repository, you can now configure the repository with the final details before letting the CI/CD take over.

You will need to set the following GitHub Actions Secrets:
- `AWS_IAM_ROLE_ARN`: The ARN of the IAM Role that the GitHub Actions will assume. See the above "Preparing your AWS Account" section for more.
