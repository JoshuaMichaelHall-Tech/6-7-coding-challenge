# Log Backup and Restore

The 6/7 Coding Challenge now includes robust log backup and restore capabilities to help you maintain your progress across different computers or system reinstallations.

## Backup Options

You can back up your logs in three different ways:

1. **Local Backup**: Saves your logs to a timestamped directory in your home folder
2. **Git Repository**: Creates a special branch in your git repository with your logs
3. **Custom Location**: Allows you to specify any directory for your backup

### Using Backup Commands

```zsh
# Backup logs using the alias
ccbackup

# Or using the installer directly
ruby ~/bin/cc-installer.rb --backup-logs
```

When you run the backup command, you'll be prompted to choose your backup method:

```
Backing Up Log Files
===================

Where would you like to backup your logs?
1) Local backup (in your home directory)
2) To the git repository
3) Custom location

Enter your choice (1-3):
```

### Backup Details

#### Local Backup

When choosing local backup, your logs will be saved to:
```
~/cc-logs-backup-YYYYMMDDHHMMSS/
```

This directory will contain:
- All your weekly log files, organized by phase
- A `backup-info.json` file with metadata about the backup
- A `restore.rb` script for easy restoration

#### Git Repository Backup

When choosing git repository backup:
- A new branch named `logs-backup-YYYYMMDDHHMMSS` will be created
- Your logs will be committed to this branch
- Your original branch will be restored after the backup
- You'll be given the option to push the backup branch to your remote repository

#### Custom Location Backup

When choosing a custom location, you'll be prompted to enter the full path where you want to store your backup.

## Restore Options

You can restore your logs from any of the backup methods:

1. **Local Backup**: Restore from a previously created local backup
2. **Git Repository**: Restore from a backup branch in your git repository
3. **Custom Location**: Restore from any directory containing a backup

### Using Restore Commands

```zsh
# Restore logs using the alias
ccrestore

# Or using the installer directly
ruby ~/bin/cc-installer.rb --restore-logs
```

When you run the restore command, you'll be prompted to choose your restore method:

```
Restoring Log Files
==================

Where would you like to restore logs from?
1) Local backup
2) From git repository
3) Custom location

Enter your choice (1-3):
```

### Restore Details

#### Local Backup Restore

When choosing to restore from a local backup:
1. You'll see a list of available backups with their timestamps
2. The current day number from each backup will be displayed if available
3. You'll be asked to confirm before existing logs are overwritten
4. You'll have the option to update your day counter to match the backup

#### Git Repository Restore

When choosing to restore from a git repository:
1. You'll see a list of available backup branches
2. The selected branch will be temporarily checked out
3. Logs will be copied from the branch to your logs directory
4. Your original branch will be restored afterward

#### Custom Location Restore

When choosing to restore from a custom location:
1. You'll be prompted to enter the full path to the backup directory
2. Logs will be copied from that location to your logs directory
3. You'll have the option to update your day counter to match the backup

## Synchronizing Between Computers

The backup and restore features are particularly useful when you need to:

1. **Switch Computers**: Back up from one computer and restore on another
2. **Reinstall Your System**: Back up before reinstallation and restore afterward
3. **Collaborate**: Share progress with others (though the challenge is designed for individual use)

### Best Practices

- **Regular Backups**: Create a backup at least weekly
- **Git Repository**: For maximum safety, use git repository backups and push to a remote
- **Verify Restores**: After restoring, run `ccstatus` to verify your progress is correctly restored
- **Day Counter**: Always choose to update your day counter when restoring to maintain consistency

## Troubleshooting

If you encounter issues with backup or restore:

- **Missing Directories**: Ensure your challenge is properly installed with `ccstatus`
- **Git Issues**: Make sure your repository is properly configured
- **Permissions**: Check that you have write permissions to the backup location
- **Corrupt Backups**: If a backup is corrupt, try an older backup or manual restoration

For advanced troubleshooting, examine the `backup-info.json` file in your backup directory.
