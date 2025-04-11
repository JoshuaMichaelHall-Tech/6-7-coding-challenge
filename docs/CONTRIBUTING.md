# Contributing to 6/7 Coding Challenge
Part of the [6/7 Coding Challenge](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge) documentation. See [Documentation Index](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge/blob/main/DOCUMENTATION.md) for all guides.

Thank you for considering contributing to the 6/7 Coding Challenge! This guide will help you get started with making improvements to the project.

## Ways to Contribute

There are many ways you can help improve the 6/7 Coding Challenge:

1. **Bug fixes**: Identifying and fixing issues with the scripts
2. **Documentation improvements**: Enhancing guides, READMEs, and comments
3. **Feature enhancements**: Adding new functionality to the challenge
4. **Usability improvements**: Making the system more user-friendly
5. **Creating templates**: Contributing project templates for different phases

## Getting Started

### 1. Fork the Repository

Start by forking the repository to your own GitHub account. This gives you a personal copy to work with.

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR-USERNAME/6-7-coding-challenge.git
cd 6-7-coding-challenge
```

### 3. Install with Development Options

```bash
# Install the scripts in development mode
ruby scripts/cc-installer.rb --verbose
```

### 4. Create a Branch

Create a branch for your changes:

```bash
git checkout -b feature/your-feature-name
```

## Development Guidelines

### Code Standards

- Follow Ruby style guidelines
- Add comments for complex functionality
- Keep methods focused on a single responsibility
- Use consistent naming conventions

### Testing Your Changes

Before submitting a pull request, please test your changes thoroughly:

1. **Test on a fresh installation**: Ensure your changes work for new users
2. **Test on an existing installation**: Check that upgrades work correctly
3. **Test edge cases**: Consider unusual configurations or inputs
4. **Test cross-platform**: If possible, test on both macOS and Linux

### Updating Documentation

If your changes affect user-facing functionality, please update the relevant documentation:

- `README.md`: For changes to main features
- `CUSTOMIZATION.md`: For configuration changes
- `docs/getting-started.md`: For changes to the setup process
- Script comments: For technical implementation details

## Making a Pull Request

### 1. Commit Your Changes

```bash
git add .
git commit -m "Brief description of your changes"
```

### 2. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 3. Create a Pull Request

Go to your fork on GitHub and click the "New Pull Request" button. Provide a clear description of your changes and why they should be included.

### 4. PR Guidelines

A good pull request:

- Has a clear purpose and solves a specific problem
- Includes tests or manual testing instructions
- Updates relevant documentation
- Adheres to the project's style and coding standards
- Does not break existing functionality

## Feature Request Process

If you have an idea for a new feature but don't want to implement it yourself:

1. Open an issue with the label "feature request"
2. Describe the feature and why it would be valuable
3. Include any relevant examples or mockups

## Code Review Process

After submitting a pull request:

1. Maintainers will review your code
2. They may suggest changes or improvements
3. Once approved, your code will be merged into the main project

## Community Guidelines

- Be respectful and constructive in discussions
- Help others when they have questions
- Give credit where credit is due
- Focus on the best outcome for the project and its users

## Project Structure

Understanding the project structure will help you make effective contributions:

```
6-7-coding-challenge/
├── README.md                     # Main project documentation
├── CUSTOMIZATION.md              # Customization guide
├── CONTRIBUTING.md               # This file
├── docs/                         # Additional documentation
├── lib/                          # Shared code modules
│   └── cc_config.rb              # Configuration handling module
├── scripts/                      # CLI script templates
│   ├── cc-installer.rb           # Main installer
│   ├── cc-start-day.rb           # Daily environment setup
│   ├── cc-log-progress.rb        # Progress logging
│   ├── cc-push-updates.rb        # Git integration
│   ├── cc-status.rb              # Progress tracking
│   ├── cc-config.rb              # Configuration management
│   ├── cc-update.rb              # Update script
│   └── cc-uninstall.rb           # Uninstallation script
└── project-templates/            # Phase-specific templates
    ├── ruby/                     # Ruby project templates
    ├── python/                   # Python project templates
    └── javascript/               # JavaScript project templates
```

## License

By contributing to this project, you agree that your contributions will be licensed under the project's MIT License.

---

Thank you for contributing to the 6/7 Coding Challenge! Your efforts help create a better tool for everyone pursuing mastery through consistent practice.