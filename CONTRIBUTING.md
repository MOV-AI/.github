<!-- MOV.AI CONTRIBUTING GUIDE -->
# Contributing

## Table of Contents
1. [Newcomers](#newcomers)
2. [Useful Links](#useful-links)
3. [Source Code Contribution Ways of Working](#source-code-contribution-ways-of-working)
4. [Branching Model](#branching-model)
5. [Code Style](#code-style)
6. [Testing](#testing)
7. [Review Process](#review-process)
8. [Issue Reporting](#issue-reporting)
9. [License Notice](#license-notice)

## Newcomers
If you are a newcomer contributor and have any questions, please do not hesitate to ask questions on the following channels:
- [MOVAI Slack Public Channel](movai.slack.com)
- [DevOps Team](mailto:devops@mov.ai)

## Useful Links
- [MOV.AI Documentation](https://docs.mov.ai)
- [MOV.AI Jira](https://movai.atlassian.net)
- [MOV.AI GitHub](https://github.com/MOV-AI)
- [Workflow Templates](https://github.com/MOV-AI/.github/tree/v3/.github/workflows)
- [Code Style Guide](https://github.com/MOV-AI/.github/blob/v3/CODE_STYLE.md) <!-- Add if exists -->

## Source Code Contribution Ways of Working
- For creation of repositories please follow the following rules:
  - Respect a coherent naming with at least one of these patterns: `system-subsystem-description` or `system-techno-description`
  - Use provided templates as much as you can and report issues
  - Do not necessarily use movai in the name of your repository
  - Avoid using the prefix `movai_` as this is used to hold MOVAI ROS packages
- Always implement solutions on a branch
- Make sure your commit messages are self speaking
- Once you're done, create a pull request and ask at least one of the maintainers for review
  - Remember to title your pull request properly as it will be used for release notes
  - Make sure to include Jira ID (if created) in the PR title
  - Assign yourself as the owner for the PR to dev branches
  - Assign the maintainers as the owner for the PR to main branches
- **NEVER EVER INSERT ANY CREDENTIAL, PASSWORD, CONFIDENTIAL INFORMATION IN YOUR CONTRIBUTIONS**
  - Use secrets for both private and public repositories

## Branching Model
- Use feature branches for new work (e.g., `feature/your-feature`)
- Use `dev` for development, `main` for production/stable releases
- Merge changes via pull requests; avoid direct pushes to `main`

## Code Style
- Follow the code style guide for your language (see Useful Links)
- Use linters and formatters where available
- Document public functions, classes, and workflows

## Testing
- Add or update tests for any new features or bug fixes
- Run all tests before submitting a pull request
- Ensure workflows pass CI checks

## Review Process
- Reviewers check for code quality, documentation, tests, and security
- Address review comments promptly
- Major changes may require discussion with maintainers

## Issue Reporting
- Report bugs or request features via GitHub Issues
- Provide clear descriptions, steps to reproduce, and screenshots/logs if relevant
- Tag issues appropriately (e.g., bug, enhancement, question)

## License Notice
All contributions to this repository are made under the [BSD-3-Clause License](LICENSE).
