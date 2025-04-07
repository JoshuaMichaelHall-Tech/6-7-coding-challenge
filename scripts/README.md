# 6/7 Coding Challenge Scripts

This directory contains the Ruby scripts that power the 6/7 Coding Challenge. These scripts have been completely rewritten in version 3.0.0 to support configuration flexibility, allowing users to customize the challenge to their needs.

## Script Overview

| Script | Description |
|--------|-------------|
| `cc-installer.rb` | Main installer that generates all other scripts |
| `cc-start-day.rb` | Initializes the environment for a new challenge day |
| `cc-log-progress.rb` | Records progress in weekly log files |
| `cc-push-updates.rb` | Commits changes, pushes to remote, and increments the day counter |
| `cc-status.rb` | Displays challenge progress and statistics |
| `cc-config.rb` | Views and modifies configuration settings |
| `cc-update.rb` | Updates scripts to the latest version |
| `cc-uninstall.rb` | Removes scripts and configuration |

## Configuration System

All scripts now use a shared configuration system through the `lib/cc_config.rb` module. This provides:

- Consistent access to user preferences
- Flexible path handling
- Customizable challenge structure
- Theme and display options

## Installation

The recommended way to install these scripts is:

```bash
# 1. Make the installer executable
chmod +x cc-installer.rb

# 2. Move it to your bin directory
mkdir -p ~/bin
cp cc-installer.rb ~/bin/

# 3. Run the installer
ruby ~/bin/cc-installer.rb
```

The installer will:
- Create necessary directories
- Install all scripts
- Set up configurations
- Add aliases to your `.zshrc`

## Command Usage

After installation, the following commands will be available:

### ccstart

Initializes the environment for the current day.

```bash
# Standard usage
ccstart

# Options are handled through configuration
```

### cclog

Records progress in weekly log files.

```bash
# Log the current day
cclog

# Log a specific day
cclog 5

# Usage with custom configuration doesn't require additional flags
```

### ccpush

Commits changes and increments the day counter.

```bash
# Standard usage
ccpush

# Auto-push behavior is controlled via configuration
```

### ccstatus

Displays challenge progress and statistics.

```bash
# Standard usage
ccstatus

# Display output is controlled via configuration
```

### ccconfig

Views and modifies configuration settings.

```bash
# View current configuration
ccconfig

# Update configuration interactively
ccconfig --interactive

# Set a specific value
ccconfig --set user.name="Your Name"
ccconfig --set paths.base_dir=~/my-custom-location

# Reset to defaults
ccconfig --reset
```

### ccupdate

Updates scripts to the latest version.

```bash
# Standard usage
ccupdate

# Force update
ccupdate --force
```

### ccuninstall

Removes scripts and configuration.

```bash
# Standard usage
ccuninstall

# Force uninstall without prompts
ccuninstall --force
```

## Development and Customization

### Adding New Functionality

To add new functionality:

1. Create a new script in this directory
2. Use the same code structure as existing scripts
3. Include the configuration module
4. Add an alias in the installer

### Modifying Scripts

To modify existing scripts:

1. Edit the script file
2. Run `ccupdate` to regenerate the installed versions
3. Test your changes

### Custom Configuration Parameters

To add new configuration parameters:

1. Edit `lib/cc_config.rb` to add your parameters to the `DEFAULT_CONFIG`
2. Update relevant scripts to use the new parameters
3. Update `cc-config.rb` to handle the new parameters in its interactive mode

## Troubleshooting

### Script Errors

If you encounter errors:

1. Run the script with more detail:
   ```bash
   ruby ~/bin/cc-script-name.rb --verbose
   ```

2. Check your configuration:
   ```bash
   ccconfig
   ```

3. Ensure your paths are correct:
   ```bash
   ccconfig --set paths.base_dir=/correct/path
   ```

### Installation Issues

If installation fails:

1. Check prerequisites:
   ```bash
   which ruby
   which zsh
   ```

2. Try a fresh installation:
   ```bash
   ruby ~/bin/cc-installer.rb --install --force
   ```

3. Check for error messages in the output

## Script Architecture

These scripts follow a modular design:

1. **Configuration Module**: Central place for settings
2. **Installer**: Bootstraps the entire system
3. **Daily Scripts**: Handle the regular workflow
4. **Management Scripts**: Handle configuration and updates

This design makes it easy to extend the system while maintaining consistency across all scripts.

## Contributing

If you improve these scripts, please consider contributing your changes back to the main project. See the [CONTRIBUTING.md](../CONTRIBUTING.md) file for guidance.

---

For more information on using these scripts, see the main [README.md](../README.md) and [CUSTOMIZATION.md](../CUSTOMIZATION.md) files.