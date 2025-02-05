# Artifix

A mono-repo style repository with CI/CD via GitHub Actions and Terraform which allows one to create a private, globally scaled, protected Hex Registry on top of S3 and Cloudfront.

The idea behind Artifix is as follows:
- All of the packages that your organization uses as dependencies should be placed inside the [`packages/`](packages/) directory. 
- The packages directory should contain inside of it only Mix projects, specifically, Mix projects which are "ready-to-package".
- Each package will first go through a [CI Pipeline](.github/workflows/packages_ci.yaml), where it will be checked for formatting (`mix format --check-formatted`), unused dependencies (`mix deps.unlock --check-unused`), compiling without warnings or errors (`mix compile --warnings-as-errors`), and its tests will be run (`mix test`). Should any of these quality checks for one package fail, the whole pipeline will fail.
- Each package will be built with `mix hex.build` to build a tarball of the package.
- The [`.tool-versions`](.tool-versions) file in the root of the repository is used to determine what Elixir version packages the tarball - this is unrelated to the matrix of OTP/Elixir versions that the packages are tested with.
- Everything is driven by the CI/CD pipeline, which will build the child packages and build the Hex Registry structure.
- The Hex Registry will be uploaded to S3.
- A CloudFront Distribution will be placed above the S3 bucket to allow for global caching of the packages.
- If an auth key (or a list of auth keys) is given, a CloudFront Function will be added to the CloudFront Distribution, along with a CloudFront KeyValueStore, which can be used to authenticate and protect the Hex Registry.

Here's the fun part though - this is just a template repository! You can customize the behavior however you wish! The actual goal of Artifix is to provide a pattern that everyone can use to build a Hex Registry, which automatically deploys to a global CDN, and allows for authorization via Auth Keys.

## What Does The Name `Artifix` Mean?

I don't know. I was thinking about "artifacts", and Elixir, and Hex, and Phoenix, and how they all have the letter "x" in them... so I thought about how to combine the word "artifacts" with the letter "x" - and "Artifix" came out!

## Working with Artifix

This is a template repository, with certain things that you will need to replace and update as you create a new repository from it. You can start by creating a repository from the template.

### Preparing your AWS Account

Artifix uses GitHub Actions to apply the Terraform plan found in the [`terraform/`](terraform/) directory to your AWS Account. This means that you will need to prepare your AWS Account to allow GitHub Actions to assume IAM Roles in the account. The workflows use the [`configure-aws-credentials` action](https://github.com/aws-actions/configure-aws-credentials) to configure credentials - so follow the instructions found there to create an OIDC provider for GitHub.

In addition to the GitHub OIDC Provider, Artifix makes the assumption that you will be using an S3 Bucket for your Terraform backend. So, make sure to create this bucket in your account.

When you've got this bucket set up, you'll need to create an IAM Role for your new repository that has the required access for the GitHub Actions to run. This includes the necessary access to the Terraform specific resources (creating the various resources necessary for the set up of the registry itself), and the necessary access for the repository to upload to the Registry itself.

A minimal policy that includes the necessary permissions may look something like this:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "acm:DeleteCertificate",
                "acm:AddTagsToCertificate",
                "acm:ListTagsForCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:GetHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets",
                "route53:ListTagsForResource"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:GetBucketPolicy",
                "s3:PutBucketPolicy",
                "s3:GetBucketAcl",
                "s3:PutBucketAcl",
                "s3:PutBucketVersioning",
                "s3:GetBucketVersioning",
                "s3:PutBucketPublicAccessBlock",
                "s3:GetBucketPublicAccessBlock",
                "s3:PutBucketOwnershipControls",
                "s3:GetBucketOwnershipControls",
                "s3:PutEncryptionConfiguration",
                "s3:GetEncryptionConfiguration",
                "s3:ListBucket",
                "s3:GetBucketCORS",
                "s3:GetBucketWebsite",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketRequestPayment",
                "s3:GetBucketLogging",
                "s3:GetBucketMetadataTableConfiguration",
                "s3:GetBucketNotification",
                "s3:GetBucketObjectLockConfiguration",
                "s3:GetBucketPolicyStatus",
                "s3:GetBucketTagging",
                "s3:GetLifecycleConfiguration",
                "s3:GetAnalyticsConfiguration",
                "s3:GetAccessPointConfigurationForObjectLambda",
                "s3:GetIntelligentTieringConfiguration",
                "s3:GetInventoryConfiguration",
                "s3:GetMetricsConfiguration",
                "s3:GetReplicationConfiguration",
                "s3:GetStorageLensConfiguration",
                "s3:GetStorageLensConfigurationTagging"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateDistribution",
                "cloudfront:GetDistribution",
                "cloudfront:UpdateDistribution",
                "cloudfront:DeleteDistribution",
                "cloudfront:GetFunction",
                "cloudfront:CreateFunction",
                "cloudfront:UpdateFunction",
                "cloudfront:DeleteFunction",
                "cloudfront:PublishFunction",
                "cloudfront:DescribeFunction",
                "cloudfront:CreateKeyValueStore",
                "cloudfront:DeleteKeyValueStore",
                "cloudfront:ListKeyValueStores",
                "cloudfront:UpdateKeyValueStore",
                "cloudfront:DescribeKeyValueStore",
                "cloudfront-keyvaluestore:DescribeKeyValueStore",
                "cloudfront-keyvaluestore:ListKeys",
                "cloudfront-keyvaluestore:GetKey",
                "cloudfront-keyvaluestore:UpdateKeys",
                "cloudfront-keyvaluestore:PutKey",
                "cloudfront-keyvaluestore:DeleteKey",
                "cloudfront:CreateOriginAccessControl",
                "cloudfront:GetOriginAccessControl",
                "cloudfront:DeleteOriginAccessControl",
                "cloudfront:TagResource"
            ],
            "Resource": "*"
        }
    ]
}
```

This policy may seem scary because it has a bunch of lines! But don't worry, this is just all of the fine-grained configurations that we need for each individual call that Terraform makes while it is ensuring the configuration of the AWS Account you are deploying to matches the configuration described in the Terraform modules here.

### Replacing References to Me!

I, [@probably-not](https://github.com/probably-not), own this repository. So, there's a few different references to me in various files - luckily, these can be easily replaced!

First, the [`CODEOWNERS`](.github/CODEOWNERS) file. I'm the owner of this repository, so I'm the one marked in the CODEOWNERS. For yours - make sure you are marked as the CODEOWNER. You may also remove this file completely - it is up to you whether you want to keep it or not.

Next, the [`dependabot.yml`](.github/dependabot.yml) file. I typically use Dependabot to keep my dependencies up to date. Here, the Dependabot configuration is set specifically to keep the GitHub actions and the Terraform details up to date, with me as the reviewer. You can keep this file, you can also remove it if you want to manage dependency updates with a different tool. If you do keep it, just make sure that again - you are marked as the reviewer and not me.

In addition to replacing references to me, feel free to delete the two examples that are in the [`packages`](./packages/) directory. They are simply there for me to test how things are working... you probably don't need them for yourself.

### Configuring the Repository

Once you've made sure that your AWS Account is prepared, and that you've finished replacing references to me from within the repository, you can now configure the repository with the final details before letting the CI/CD take over.

#### Configuring the Infrastructure

In the [`vars.tfvars`](./vars.tfvars) file, you'll find multiple variables that you can configure to your liking. Descriptions of these variables can be found in the [`terraform/variables.tf`](./terraform/variables.tf) file. There's not a lot! This template makes a few assumptions about your current infrastructure - for example, it's not going to create a Route53 Hosted Zone for you, it assumes that is already created - but there's really not too much to create, so the variables is a very small list.

#### Configuring the GitHub Actions

You will need to set the following GitHub Actions Secrets:
- `HEX_REGISTRY_PRIVATE_KEY`: This needs to be the private key of your Hex Registry. The public key can be distributed to whomever is using your registry, but this private key must be kept secret.
- `AWS_IAM_ROLE_ARN`: The ARN of the IAM Role that the GitHub Actions will assume. See the above "Preparing your AWS Account" section for more.
- `TERRAFORM_BACKEND_S3_REGION`: The region for the S3 Bucket where the terraform state will be stored.
- `TERRAFORM_BACKEND_S3_BUCKET`: The name of the S3 Bucket where the terraform state will be stored. This should be a separate bucket from the actual Hex Registry bucket - we don't want to expose the Terraform state on CloudFront accidentally.
- `TERRAFORM_BACKEND_S3_KEY`: The key in the above mentioned S3 Bucket where the terraform state will be placed.

#### Optional Configurations

You may want to set the following GitHub Actions Secrets:
- `HEX_REGISTRY_NAME`: This needs to be set to the name of your registry. By default, it is set to "artifix", however, this could potentially clash with other registries with the same name... so you can set it to a new name based on whatever you'd like!


### Configuring the Auth Keys

In addition to the secrets that you need to configure above, you may also set the `HEX_REGISTRY_AUTH_KEYS` secret as a list of comma separated auth keys. This will be read by the action and added to the applying of the Terraform modules, in order to add the auth keys to the CloudFront KeyValueStore.

You don't have to set them via the secret! You can also add them to the [`vars.tfvars`](./vars.tfvars) file if you don't mind commiting your list of auth keys to the repository, or you can find some other way of injecting them into the action that creates and manages the terraform infrastructure. Like I've said a couple of times in the README, this is just a template and you can adjust it however you see fit.

## Contributing

Feel free to fork and make PRs!

1. [Fork it!](http://github.com/probably-not/artifix/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](https://github.com/probably-not/artifix/compare)
