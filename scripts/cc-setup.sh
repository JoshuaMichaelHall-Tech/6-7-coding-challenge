#!/bin/zsh

echo "Setting up your 6/7 Coding Challenge environment..."

# Create bin directory
mkdir -p ~/bin

# Copy the existing scripts directly
if [[ -f ./scripts/cc-start-day.sh ]]; then
  echo "Copying cc-start-day.sh to ~/bin..."
  cp ./scripts/cc-start-day.sh ~/bin/
  chmod +x ~/bin/cc-start-day.sh
fi

if [[ -f ./scripts/cc-log-progress.sh ]]; then
  echo "Copying cc-log-progress.sh to ~/bin..."
  cp ./scripts/cc-log-progress.sh ~/bin/
  chmod +x ~/bin/cc-log-progress.sh
fi

if [[ -f ./scripts/cc-push-updates.sh ]]; then
  echo "Copying cc-push-updates.sh to ~/bin..."
  cp ./scripts/cc-push-updates.sh ~/bin/
  chmod +x ~/bin/cc-push-updates.sh
fi

if [[ -f ./scripts/cc-status.sh ]]; then
  echo "Copying cc-status.sh to ~/bin..."
  cp ./scripts/cc-status.sh ~/bin/
  chmod +x ~/bin/cc-status.sh
fi

# Initialize day counter
echo "Initializing day counter to 1..."
echo "1" > ~/.cc-current-day

# Create directory structure
echo "Creating directory structure..."
BASE_DIR=~/projects/6-7-coding-challenge
mkdir -p $BASE_DIR/{logs,phase1_ruby,phase2_python,phase3_javascript,phase4_fullstack,phase5_ml_finance}
mkdir -p $BASE_DIR/logs/phase1

# Create week directories for phase 1
for i in {01..17}; do 
  mkdir -p $BASE_DIR/phase1_ruby/week$i
done

# Initialize git repository
if [[ ! -d "$BASE_DIR/.git" ]]; then
  echo "Initializing git repository..."
  cd $BASE_DIR
  git init
  
  # Create .gitignore
  cat > .gitignore << 'EOG'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~

# Environment files
.env
.env.local

# Language specific
*.gem
*.rbc
__pycache__/
*.py[cod]
node_modules/
EOG

  # Initial commit
  git add .
  git commit -m "Initial 6/7 Coding Challenge setup"
fi

# Add aliases to .zshrc
if ! grep -q "# 6/7 Coding Challenge aliases" ~/.zshrc; then
  echo "Adding aliases to .zshrc..."
  cat >> ~/.zshrc << 'EOZ'

# 6/7 Coding Challenge aliases
alias ccstart="~/bin/cc-start-day.sh"
alias cclog="~/bin/cc-log-progress.sh"
alias ccpush="~/bin/cc-push-updates.sh"
alias ccstatus="~/bin/cc-status.sh"
EOZ
fi

echo "Setup complete! Remember to source your .zshrc file:"
echo "source ~/.zshrc"
