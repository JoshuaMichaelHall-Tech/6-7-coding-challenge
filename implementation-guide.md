# 6/7 Coding Challenge - Ruby Installer Guide

This guide will help you implement the Ruby-based installer for your 6/7 Coding Challenge environment. This replaces the problematic shell script with a more robust Ruby implementation.

## Benefits of the Ruby Installer

- **Improved reliability**: Avoids shell script parsing issues
- **Cross-platform compatibility**: Works on macOS, Linux, and WSL
- **Enhanced error handling**: Better error messages and recovery options
- **Retroactive logging support**: Easily log entries for previous days
- **Cleaner code organization**: More maintainable script structure

## Installation Steps

1. **Save the installer script**:
   
   ```bash
   mkdir -p ~/bin
   curl -o ~/bin/cc-installer.rb https://raw.githubusercontent.com/yourrepo/6-7-coding-challenge/main/scripts/cc-installer.rb
   chmod +x ~/bin/cc-installer.rb
   ```

   Or simply copy the script content from the artifact into a new file at `~/bin/cc-installer.rb`.

2. **Run the installer**:

   ```bash
   ruby ~/bin/cc-installer.rb
   ```

   The installer will:
   - Check your environment for prerequisites
   - Create the necessary directory structure
   - Install all the required scripts
   - Set up aliases in your `.zshrc`
   - Initialize the day counter
   - Set up git integration

3. **Source your zshrc file**:

   ```bash
   source ~/.zshrc
   ```

4. **Verify installation**:

   ```bash
   ccstatus
   ```

## Core Commands

After installation, you'll have access to these commands:

| Command    | Description                                           |
|------------|-------------------------------------------------------|
| `ccstart`  | Start the day's coding session with the right files   |
| `cclog`    | Record your progress in the weekly log                |
| `ccpush`   | Commit changes and increment the day counter          |
| `ccstatus` | Show your overall challenge progress                  |
| `ccupdate` | Update scripts to the latest version                  |
| `ccuninstall` | Remove scripts and configuration                   |

## Using Retroactive Logging

One of the key features is the ability to log entries for previous days:

```bash
# Log the current day (standard usage)
cclog

# Log a specific previous day
cclog 5
```

This is useful if you forget to log your progress on a particular day.

## Directory Structure

The installer creates this directory structure:

```
~/projects/6-7-coding-challenge/
├── phase1_ruby/          # Phase 1 directories
│   ├── week01/
│   │   ├── day1/
│   │   ├── day2/
│   │   └── ...
│   ├── week02/
│   └── ...
├── logs/                 # Log files
│   ├── phase1/
│   │   ├── week01.md
│   │   ├── week02.md
│   │   └── ...
└── ...
```

## Troubleshooting

### Common Issues

1. **Ruby not installed**:
   - Install Ruby using your package manager
   - macOS: `brew install ruby`
   - Ubuntu/Debian: `sudo apt install ruby`

2. **Permission errors**:
   - Ensure the script is executable: `chmod +x ~/bin/cc-installer.rb`
   - Check file permissions in your home directory

3. **Path issues**:
   - Make sure `~/bin` is in your PATH: `echo $PATH`
   - Add it if needed: `echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc`

4. **Existing installation conflicts**:
   - Use the `--force` option: `ruby ~/bin/cc-installer.rb --install --force`
   - Or uninstall first: `ruby ~/bin/cc-installer.rb --uninstall`

### Debugging

For more detailed output when troubleshooting:

```bash
ruby ~/bin/cc-installer.rb --verbose
```

## Command Line Options

The installer supports these options:

```
Usage: cc-installer.rb [options]
    --install                     Force fresh installation
    --update                      Update existing installation
    --uninstall                   Remove installation
-f, --force                       Force operation without prompts
-v, --verbose                     Verbose output
    --version                     Show version information
-h, --help                        Show help message
```

## Manual Update Process

If you need to manually update your installation:

```bash
# Download the latest installer
curl -o ~/bin/cc-installer.rb https://raw.githubusercontent.com/yourrepo/6-7-coding-challenge/main/scripts/cc-installer.rb
chmod +x ~/bin/cc-installer.rb

# Run the update
ruby ~/bin/cc-installer.rb --update
```

## Customization

If you need to modify the scripts:

1. Edit the main installer at `~/bin/cc-installer.rb`
2. Make your changes to the script generation methods
3. Run `ruby ~/bin/cc-installer.rb --update` to update your scripts

## Further Help

If you encounter any issues not covered in this guide:

1. Check the error message for clues
2. Make sure all prerequisites are installed
3. Try running with the `--verbose` flag for more information
4. Consult the existing documentation in your repository

Happy coding with your 6/7 Challenge journey!
