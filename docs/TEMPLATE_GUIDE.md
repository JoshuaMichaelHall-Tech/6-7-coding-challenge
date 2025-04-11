# Using 6/7 Coding Challenge as a Template
Part of the [6/7 Coding Challenge](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge) documentation. See [Documentation Index](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge/blob/main/DOCUMENTATION.md) for all guides.

This guide explains how to set up and use the 6/7 Coding Challenge repository as a GitHub template for others.

## Setting Up the Repository as a Template

As a repository owner, follow these steps to make your repository template-ready:

1. **On GitHub.com**:
   - Go to your repository
   - Click "Settings"
   - Scroll down to the "Template repository" section
   - Check the box to make this repository a template
   
2. **Update Template Files**:
   - Ensure TEMPLATE_README.md is present in the root directory
   - Verify .github/template-config.yml is present and configured
   - Make sure all documentation is updated for template users

## Creating a Repository from the Template

For users who want to start their own challenge:

1. Navigate to the repository on GitHub
2. Click the green "Use this template" button
3. Select "Create a new repository"
4. Name your repository (example: "my-coding-challenge")
5. Choose visibility (public or private)
6. Click "Create repository from template"

## Post-Creation Setup

After creating a repository from the template:

1. Clone your new repository locally
2. Run the installer with your personalized information
3. Customize the configuration for your specific goals
4. Replace the README.md with your own information

## Template Features

The template system:

1. Preserves the directory structure
2. Provides clean history (no commits from the original repository)
3. Allows for complete customization via the configuration system
4. Includes template-specific README and guides

## Excluding Files from Templates

Certain files should not be included when a user creates from your template:

- Development-specific configurations
- CI/CD workflows not relevant to individual users
- Your personal progress logs

These are configured in the `.github/template-config.yml` file.

## Best Practices

When maintaining a template repository:

1. Keep the core scripts updated in both the template and documentation
2. Clearly separate personal content from template content
3. Maintain comprehensive documentation for new users
4. Test the template creation process regularly

This template system allows anyone to start their own 6/7 Coding Challenge with minimal setup while maintaining the core philosophy of consistent practice and strategic rest.
