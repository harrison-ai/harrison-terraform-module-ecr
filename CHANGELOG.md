# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3]
* Add tags to the `aws_ecr_repository` resource.
* Update providers and docker compose.

## [0.1.2]
* Adds the ability to override the default lifecycle policy with a custom user supplied policy

Please note that when switching from the default to user supplied lifecycle policy, it may be neccessary to `terraform apply` twice.  This is due to a nuance in the terraform resource lifecycle and not easily worked around

## [0.1.1]
* Update terraform minimum to 1.2 and aws provider minimum to 4.0

## [0.1.0]
* Initial version
