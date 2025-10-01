# Contributing to VS Code Server on GCP

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Documentation](#documentation)

## 🤝 Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please be respectful and constructive in all interactions.

## 🚀 Getting Started

### Prerequisites

1. **Install Required Tools**
   ```bash
   # Terraform
   brew install terraform  # macOS
   # or download from https://www.terraform.io/downloads

   # Google Cloud SDK
   brew install google-cloud-sdk  # macOS
   # or download from https://cloud.google.com/sdk/docs/install

   # Pre-commit hooks (optional but recommended)
   pip install pre-commit
   ```

2. **Fork and Clone**
   ```bash
   # Fork the repository on GitHub
   git clone https://github.com/YOUR_USERNAME/vscode-server-gcp.git
   cd vscode-server-gcp/terraform
   ```

3. **Set Up Development Environment**
   ```bash
   # Initialize Terraform
   terraform init

   # Install pre-commit hooks
   pre-commit install
   ```

## 🔄 Development Workflow

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make Your Changes**
   - Follow the coding standards below
   - Add tests for new features
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   # Format code
   terraform fmt -recursive

   # Validate configuration
   terraform validate

   # Run security checks
   tfsec .
   checkov -d .

   # Plan changes
   terraform plan
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   # Then create a Pull Request on GitHub
   ```

## 📝 Coding Standards

### Terraform Style Guide

1. **File Organization**
   - One resource type per file when possible
   - Group related resources together
   - Use descriptive file names

2. **Naming Conventions**
   ```hcl
   # Resources: use underscores
   resource "google_compute_instance" "vscode_server" {}

   # Variables: use underscores
   variable "instance_count" {}

   # Locals: use underscores
   locals {
     resource_name = "example"
   }
   ```

3. **Formatting**
   ```hcl
   # Always run terraform fmt
   terraform fmt -recursive

   # Use consistent indentation (2 spaces)
   resource "google_compute_network" "vpc" {
     name                    = "my-network"
     auto_create_subnetworks = false
   }
   ```

4. **Comments**
   ```hcl
   # Use comments to explain WHY, not WHAT
   # Good:
   # Disable auto-create to have full control over subnet configuration
   auto_create_subnetworks = false

   # Bad:
   # Set auto_create_subnetworks to false
   auto_create_subnetworks = false
   ```

5. **Variable Definitions**
   ```hcl
   variable "example" {
     type        = string
     description = "Clear, concise description"
     default     = "default-value"

     validation {
       condition     = can(regex("^[a-z0-9-]+$", var.example))
       error_message = "Must contain only lowercase letters, numbers, and hyphens."
     }
   }
   ```

### Documentation Standards

1. **README Updates**
   - Update README.md for new features
   - Include usage examples
   - Document breaking changes

2. **Inline Documentation**
   - Add comments for complex logic
   - Document non-obvious decisions
   - Explain security considerations

3. **Variable Documentation**
   - Provide clear descriptions
   - Include examples when helpful
   - Document validation rules

## 🧪 Testing Guidelines

### Pre-Deployment Testing

1. **Syntax and Formatting**
   ```bash
   terraform fmt -check -recursive
   terraform validate
   ```

2. **Security Scanning**
   ```bash
   # Run tfsec
   tfsec . --minimum-severity MEDIUM

   # Run Checkov
   checkov -d . --framework terraform
   ```

3. **Plan Review**
   ```bash
   terraform plan -out=tfplan
   # Review the plan carefully
   ```

### Integration Testing

1. **Deploy to Test Environment**
   ```bash
   # Use a test project
   terraform apply -var="project_id=test-project"
   ```

2. **Verify Functionality**
   - Check all resources are created
   - Verify network connectivity
   - Test VS Code Server access
   - Validate monitoring and logging

3. **Clean Up**
   ```bash
   terraform destroy -var="project_id=test-project"
   ```

## 📝 Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples
```bash
feat(network): add support for custom VPC CIDR ranges

Add variables for configuring custom CIDR ranges for VPC and subnets.
This allows users to specify their own IP address ranges instead of
using the default values.

Closes #123
```

```bash
fix(compute): correct instance template disk configuration

The boot disk size was not being applied correctly due to incorrect
parameter name. Changed from disk_size to disk_size_gb.

Fixes #456
```

## 🔄 Pull Request Process

1. **Before Submitting**
   - Ensure all tests pass
   - Update documentation
   - Add entry to CHANGELOG.md
   - Rebase on latest main branch

2. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Terraform fmt
   - [ ] Terraform validate
   - [ ] Security scan (tfsec/checkov)
   - [ ] Manual testing in test environment

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex code
   - [ ] Documentation updated
   - [ ] CHANGELOG.md updated
   - [ ] No new warnings generated
   ```

3. **Review Process**
   - At least one approval required
   - All CI checks must pass
   - Address all review comments
   - Squash commits if requested

4. **After Merge**
   - Delete your branch
   - Update your local main branch
   - Close related issues

## 📚 Documentation

### What to Document

1. **New Features**
   - Usage examples
   - Configuration options
   - Best practices

2. **Breaking Changes**
   - Migration guide
   - Deprecation notices
   - Version compatibility

3. **Bug Fixes**
   - Root cause explanation
   - Impact assessment
   - Prevention measures

### Documentation Locations

- **README.md**: User-facing documentation
- **CHANGELOG.md**: Version history and changes
- **Inline comments**: Code-level documentation
- **variables.tf**: Variable descriptions
- **outputs.tf**: Output descriptions

## 🐛 Reporting Bugs

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. See error

**Expected behavior**
What you expected to happen.

**Environment**
- Terraform version:
- Provider versions:
- OS:

**Additional context**
Any other relevant information.
```

## 💡 Feature Requests

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Additional context**
Any other context or screenshots.
```

## 🙏 Thank You

Thank you for contributing to this project! Your efforts help make this tool better for everyone.

---

For questions or discussions, please open an issue or reach out to the maintainers.
