# 6/7 Coding Challenge Maintenance Guide

*Part of the [6/7 Coding Challenge](../README.md) documentation. See [Documentation Index](../DOCUMENTATION.md) for all guides.*

**Related guides:**
- [Backup & Restore](backup-restore-docs.md)
- [Customization Guide](CUSTOMIZATION.md)
- [Getting Started](getting-started.md)

## Table of Contents
- [Version Management](#version-management)
- [Backup and Restore Procedures](#backup-and-restore-procedures)
- [Repository Maintenance](#repository-maintenance)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)

## Version Management

The 6/7 Coding Challenge uses a versioning system to track script changes and improvements. The current version is **3.1.1**.

### Checking Your Version

To check your installed version:

```zsh
ccconfig | grep version
```

### Updating to the Latest Version

The challenge includes a built-in update mechanism:

```zsh
# Standard update
ccupdate

# Force update without prompts
ccupdate --force

# Verbose update with additional information
ccupdate --verbose
```

### Version History

- **3.1.1**: Current stable version with backup/restore improvements
- **3.1.0**: Added retroactive logging capabilities
- **3.0.0**: Complete rewrite with configuration flexibility

## Backup and Restore Procedures

Regular backups ensure you never lose your challenge progress. The system offers three backup methods.

### Creating Backups

```zsh
# Run the backup command
ccbackup
```

You will be prompted to choose your backup method:

1. **Local backup**: Creates a timestamped directory in your home folder
   ```
   ~/cc-logs-backup-YYYYMMDDHHMMSS/
   ```

2. **Git repository backup**: Creates a special branch in your repository
   ```
   logs-backup-YYYYMMDDHHMMSS
   ```

3. **Custom location backup**: Saves files to your specified directory

### Restoring from Backups

```zsh
# Run the restore command
ccrestore
```

The restore process will:
1. Show available backups with timestamps
2. Let you select which backup to use
3. Copy log files back to their proper locations
4. Optionally update your day counter

### Automated Backup Strategies

Consider setting up a cron job for regular backups:

```zsh
# Edit your crontab
crontab -e

# Add weekly backup (Sundays at midnight)
0 0 * * 0 $HOME/bin/cc-installer.rb --backup-logs
```

## Repository Maintenance

Regular maintenance keeps your challenge repository healthy and organized.

### Git Repository Cleanup

If you're using Git, periodic cleanup helps maintain performance:

```zsh
# Navigate to your challenge directory
cd ~/projects/6-7-coding-challenge

# Remove untracked files and directories
git clean -fd

# Prune old references
git remote prune origin

# Optimize repository
git gc --aggressive
```

### Log Directory Organization

As your challenge progresses, you may want to archive old phases:

```zsh
# Create an archive directory
mkdir -p ~/projects/6-7-coding-challenge/archive

# Move completed phase logs (example for Phase 1)
mv ~/projects/6-7-coding-challenge/logs/phase1 ~/projects/6-7-coding-challenge/archive/
```

### Configuration Reset

If you encounter persistent issues, you can reset your configuration:

```zsh
# Reset to default configuration
ccconfig --reset

# Re-create your customizations interactively
ccconfig --interactive
```

## Troubleshooting Common Issues

### Day Counter Issues

If your day counter becomes incorrect:

```zsh
# Check current day
cat ~/.cc-current-day

# Manually set day counter
echo "42" > ~/.cc-current-day
```

### Script Permission Problems

If scripts lose execute permissions:

```zsh
# Fix permissions
chmod +x ~/bin/cc-*.rb
```

### Git Integration Problems

If Git integration isn't working:

```zsh
# Check Git configuration
cd ~/projects/6-7-coding-challenge
git config --list

# Set Git configuration if needed
git config user.name "Your Name"
git config user.email "your@email.com"
```

### Restoring Lost Templates

If you accidentally delete template files:

```zsh
# Reinstall with template preservation
ccupdate --force
```

### Configuration File Corruption

If your configuration file becomes corrupted:

```zsh
# Backup existing config
cp ~/.cc-config.json ~/.cc-config.json.bak

# Reset configuration
ccconfig --reset
```

---

For additional support or to report issues, please open an issue on the GitHub repository or consult the [Contributing Guide](CONTRIBUTING.md).