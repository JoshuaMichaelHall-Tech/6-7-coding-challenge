# 6/7 Coding Challenge Project Templates

This guide provides starter templates for each phase of the 6/7 Coding Challenge. These templates will help you maintain consistency and follow best practices throughout your 500-day journey.

## Table of Contents

1. [Phase 1: Ruby Backend](#phase-1-ruby-backend)
2. [Phase 2: Python Data Analysis](#phase-2-python-data-analysis)
3. [Phase 3: JavaScript Frontend](#phase-3-javascript-frontend)
4. [Phase 4: Full-Stack Projects](#phase-4-full-stack-projects)
5. [Phase 5: ML Finance Applications](#phase-5-ml-finance-applications)
6. [Template Usage Instructions](#template-usage-instructions)

## Phase 1: Ruby Backend

### Basic Ruby Project Template

```
day<N>/
├── README.md              # Daily challenge documentation
├── lib/                   # Library code
│   └── main.rb            # Main application code
├── spec/                  # Tests
│   └── main_spec.rb       # Test specifications
└── Gemfile                # Dependencies
```

### Gemfile Template

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'rspec', '~> 3.12'        # Testing framework
gem 'rubocop', '~> 1.56'      # Static code analyzer
gem 'pry', '~> 0.14.2'        # Debugging tool
```

### RSpec Configuration

```ruby
# spec/spec_helper.rb
require_relative '../lib/main'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
```

### Sinatra Web Application Template

```
day<N>/
├── README.md
├── app.rb                 # Main Sinatra application
├── config.ru              # Rack configuration
├── lib/                   # Business logic
├── public/                # Static files
│   ├── css/               # Stylesheets
│   ├── js/                # JavaScript files
│   └── images/            # Image assets
├── views/                 # ERB templates
│   ├── layout.erb         # Main layout
│   └── index.erb          # Home page
├── spec/                  # Tests
└── Gemfile                # Dependencies
```

### Sinatra Gemfile

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'sinatra', '~> 3.0'           # Web framework
gem 'sinatra-contrib', '~> 3.0'   # Sinatra extensions
gem 'puma', '~> 6.3'              # Web server
gem 'erubi', '~> 1.12'            # Safe templating
gem 'rack', '~> 2.2'              # Web server interface

group :development do
  gem 'rerun', '~> 0.14'          # Auto-reload app
  gem 'pry', '~> 0.14.2'          # Debugging
end

group :test do
  gem 'rspec', '~> 3.12'          # Testing framework
  gem 'rack-test', '~> 2.1'       # Testing Rack apps
  gem 'capybara', '~> 3.39'       # Integration testing
end
```

### Basic Sinatra App

```ruby
# app.rb
require 'sinatra/base'
require 'sinatra/reloader'
require 'erubi'

class MyApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :erb, :escape_html => true
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'

  get '/' do
    erb :index
  end

  # Start the server if this file is run directly
  run! if app_file == $0
end
```

## Phase 2: Python Data Analysis

### Basic Python Data Analysis Project

```
day<N>/
├── README.md                # Daily challenge documentation
├── notebooks/               # Jupyter notebooks
│   └── analysis.ipynb       # Main analysis notebook
├── src/                     # Python modules
│   ├── __init__.py          # Makes src a package
│   └── data_processor.py    # Data processing functions
├── data/                    # Data directory
│   ├── raw/                 # Raw data
│   └── processed/           # Processed data
├── tests/                   # Test directory
│   ├── __init__.py
│   └── test_data_processor.py
├── requirements.txt         # Dependencies
└── setup.py                 # Package setup
```

### requirements.txt Template

```
# requirements.txt
numpy==1.24.3
pandas==2.0.3
matplotlib==3.7.2
seaborn==0.12.2
scikit-learn==1.3.0
jupyter==1.0.0
pytest==7.4.0
black==23.7.0
```

### Data Processor Module

```python
# src/data_processor.py
import pandas as pd
import numpy as np
from typing import Optional, List, Dict, Any, Union


def load_data(file_path: str) -> pd.DataFrame:
    """
    Load data from a CSV file.
    
    Args:
        file_path: Path to the CSV file
    
    Returns:
        DataFrame containing the data
    """
    return pd.read_csv(file_path)


def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean the data by removing duplicates and handling missing values.
    
    Args:
        df: Input DataFrame
    
    Returns:
        Cleaned DataFrame
    """
    # Remove duplicates
    df = df.drop_duplicates()
    
    # Handle missing values
    df = df.fillna({
        'numeric_col': df['numeric_col'].median(),
        'categorical_col': 'Unknown'
    })
    
    return df


def feature_engineering(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create new features from existing ones.
    
    Args:
        df: Input DataFrame
    
    Returns:
        DataFrame with new features
    """
    # Example feature: create a new feature
    df['new_feature'] = df['feature1'] / df['feature2']
    
    return df


def split_data(df: pd.DataFrame, 
               target_col: str, 
               test_size: float = 0.2,
               random_state: Optional[int] = None):
    """
    Split data into training and testing sets.
    
    Args:
        df: Input DataFrame
        target_col: Target column name
        test_size: Proportion of data for testing
        random_state: Random seed for reproducibility
    
    Returns:
        X_train, X_test, y_train, y_test
    """
    from sklearn.model_selection import train_test_split
    
    X = df.drop(columns=[target_col])
    y = df[target_col]
    
    return train_test_split(X, y, test_size=test_size, random_state=random_state)
```

### Jupyter Notebook Template

```python
# notebooks/analysis.ipynb
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Data Analysis for Day <N>\n",
    "\n",
    "## Overview\n",
    "\n",
    "This notebook contains the analysis for day <N> of the 6/7 Coding Challenge Phase 2."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Import libraries\n",
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Configure visualizations
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_context('notebook')
%matplotlib inline
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['font.size'] = 12"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Import local modules\n",
    "import sys\n",
    "sys.path.append('..')\n",
    "from src.data_processor import load_data, clean_data, feature_engineering"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Load and Explore Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Load the data\n",
    "df = load_data('../data/raw/dataset.csv')\n",
    "\n",
    "# Display basic information\n",
    "print(f\"Data shape: {df.shape}\")\n",
    "df.head()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Data summary\n",
    "df.describe()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Check for missing values\n",
    "df.isna().sum()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Data Cleaning"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Clean the data\n",
    "df_cleaned = clean_data(df)\n",
    "\n",
    "# Verify cleaning\n",
    "print(f\"Original shape: {df.shape}\")\n",
    "print(f\"Cleaned shape: {df_cleaned.shape}\")\n",
    "df_cleaned.isna().sum()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Feature Engineering"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create new features\n",
    "df_featured = feature_engineering(df_cleaned)\n",
    "\n",
    "# Examine new features\n",
    "df_featured[['feature1', 'feature2', 'new_feature']].head()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Visualization"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Distribution of target variable\n",
    "sns.histplot(df_featured['target'], kde=True)\n",
    "plt.title('Distribution of Target Variable')\n",
    "plt.xlabel('Value')\n",
    "plt.ylabel('Count')\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Correlation matrix\n",
    "plt.figure(figsize=(14, 10))\n",
    "corr_matrix = df_featured.select_dtypes(include=['number']).corr()\n",
    "mask = np.triu(np.ones_like(corr_matrix, dtype=bool))\n",
    "sns.heatmap(corr_matrix, mask=mask, annot=True, fmt='.2f', cmap='coolwarm')\n",
    "plt.title('Feature Correlation Matrix')\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Data Modeling"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Split data into training and testing sets\n",
    "from sklearn.model_selection import train_test_split\n",
    "\n",
    "X = df_featured.drop(columns=['target'])\n",
    "y = df_featured['target']\n",
    "\n",
    "X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Train a model\n",
    "from sklearn.ensemble import RandomForestRegressor\n",
    "from sklearn.metrics import mean_squared_error, r2_score\n",
    "\n",
    "model = RandomForestRegressor(n_estimators=100, random_state=42)\n",
    "model.fit(X_train, y_train)\n",
    "\n",
    "# Make predictions\n",
    "y_pred = model.predict(X_test)\n",
    "\n",
    "# Evaluate model\n",
    "mse = mean_squared_error(y_test, y_pred)\n",
    "r2 = r2_score(y_test, y_pred)\n",
    "\n",
    "print(f\"Mean Squared Error: {mse:.4f}\")\n",
    "print(f\"R² Score: {r2:.4f}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Feature importance\n",
    "feature_importances = pd.DataFrame({\n",
    "    'feature': X.columns,\n",
    "    'importance': model.feature_importances_\n",
    "}).sort_values('importance', ascending=False)\n",
    "\n",
    "plt.figure(figsize=(10, 6))\n",
    "sns.barplot(x='importance', y='feature', data=feature_importances[:10])\n",
    "plt.title('Top 10 Feature Importances')\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Conclusion\n",
    "\n",
    "Summary of findings and next steps."
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.7"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
```

## Phase 3: JavaScript Frontend

### Basic JavaScript Project

```
day<N>/
├── README.md          # Daily challenge documentation
├── index.html         # Main HTML file
├── css/               # Stylesheets
│   └── styles.css     # Main stylesheet
├── js/                # JavaScript files
│   ├── main.js        # Main JavaScript file
│   └── utils.js       # Utility functions
├── assets/            # Static assets
│   └── images/        # Image files
└── tests/             # Tests
    └── main.test.js   # Tests for main.js
```

### HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Day N Project</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <header>
        <h1>Day N Project</h1>
        <nav>
            <ul>
                <li><a href="#home">Home</a></li>
                <li><a href="#about">About</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section id="home">
            <h2>Home Section</h2>
            <p>This is the home section of the project.</p>
        </section>
        
        <section id="about">
            <h2>About Section</h2>
            <p>This is the about section of the project.</p>
        </section>
        
        <section id="contact">
            <h2>Contact Section</h2>
            <p>This is the contact section of the project.</p>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 6/7 Coding Challenge - Day N</p>
    </footer>

    <script src="js/utils.js"></script>
    <script src="js/main.js"></script>
</body>
</html>
```

### CSS Template

```css
/* Reset and base styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Arial', sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f5f5f5;
}

/* Layout */
header, main, footer {
    padding: 20px;
    max-width: 1200px;
    margin: 0 auto;
}

/* Navigation */
nav ul {
    display: flex;
    list-style: none;
}

nav li {
    margin-right: 20px;
}

nav a {
    text-decoration: none;
    color: #333;
    font-weight: bold;
}

nav a:hover {
    color: #0066cc;
}

/* Sections */
section {
    margin-bottom: 40px;
    padding: 20px;
    background-color: white;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

h1, h2 {
    margin-bottom: 15px;
}

/* Footer */
footer {
    text-align: center;
    padding: 20px;
    background-color: #333;
    color: white;
}

/* Responsive design */
@media (max-width: 768px) {
    nav ul {
        flex-direction: column;
    }
    
    nav li {
        margin-right: 0;
        margin-bottom: 10px;
    }
}
```

### JavaScript Template

```javascript
// main.js
document.addEventListener('DOMContentLoaded', () => {
    // Initialize application
    init();
    
    // Set up event listeners
    setupEventListeners();
});

/**
 * Initialize the application
 */
function init() {
    console.log('Application initialized');
    
    // Example: Fetch data from API
    // fetchData();
    
    // Example: Update UI with data
    updateUI();
}

/**
 * Set up event listeners
 */
function setupEventListeners() {
    // Example: Add click event to navigation links
    document.querySelectorAll('nav a').forEach(link => {
        link.addEventListener('click', handleNavigation);
    });
    
    // Example: Form submission
    const contactForm = document.querySelector('#contact form');
    if (contactForm) {
        contactForm.addEventListener('submit', handleFormSubmit);
    }
}

/**
 * Handle navigation click events
 * @param {Event} event - The click event
 */
function handleNavigation(event) {
    // Prevent default link behavior
    event.preventDefault();
    
    // Get the target section id from the href
    const targetId = event.currentTarget.getAttribute('href');
    
    // Scroll to the section
    document.querySelector(targetId).scrollIntoView({
        behavior: 'smooth'
    });
}

/**
 * Handle form submissions
 * @param {Event} event - The submit event
 */
function handleFormSubmit(event) {
    event.preventDefault();
    
    // Get form data
    const formData = new FormData(event.currentTarget);
    const data = Object.fromEntries(formData.entries());
    
    console.log('Form submitted with data:', data);
    
    // Example: Send data to backend
    // sendFormData(data);
}

/**
 * Update the UI with data
 * @param {Object} data - The data to display
 */
function updateUI(data = {}) {
    console.log('Updating UI');
    
    // Example: Update dynamic content
    const timestamp = new Date().toLocaleString();
    const homeSection = document.querySelector('#home');
    
    if (homeSection) {
        const timeElement = document.createElement('p');
        timeElement.textContent = `Last updated: ${timestamp}`;
        homeSection.appendChild(timeElement);
    }
}

// Utility functions can be imported from utils.js
const { formatDate, calculateTotal } = utils;
```

### React Project Template

```
day<N>/
├── README.md              # Daily challenge documentation
├── public/                # Public assets
│   ├── index.html         # HTML entry point
│   └── favicon.ico        # Site favicon
├── src/                   # Source code
│   ├── components/        # React components
│   │   ├── App.jsx        # Main App component
│   │   ├── Header.jsx     # Header component
│   │   └── Footer.jsx     # Footer component
│   ├── hooks/             # Custom hooks
│   │   └── useData.js     # Data fetching hook
│   ├── context/           # React context
│   │   └── AppContext.js  # Application context
│   ├── styles/            # CSS/SCSS styles
│   │   └── main.css       # Main stylesheet
│   ├── utils/             # Utility functions
│   │   └── helpers.js     # Helper functions
│   ├── index.js           # JavaScript entry point
│   └── App.css            # App component styles
├── package.json           # Dependencies and scripts
└── .gitignore             # Git ignore file
```

## Phase 4: Full-Stack Projects

### Basic Full-Stack Project (Rails + React)

```
day<N>/
├── README.md              # Daily challenge documentation
├── backend/               # Ruby on Rails backend
│   ├── app/               # Rails app directory
│   │   ├── controllers/   # API controllers
│   │   ├── models/        # Database models
│   │   └── services/      # Business logic
│   ├── config/            # Rails configuration
│   ├── db/                # Database files
│   │   ├── migrate/       # Database migrations
│   │   └── seeds.rb       # Seed data
│   ├── Gemfile            # Ruby dependencies
│   └── README.md          # Backend documentation
├── frontend/              # React frontend
│   ├── public/            # Static assets
│   ├── src/               # Source code
│   │   ├── components/    # React components
│   │   ├── api/           # API client
│   │   └── hooks/         # Custom hooks
│   ├── package.json       # Dependencies
│   └── README.md          # Frontend documentation
└── docker-compose.yml     # Docker configuration
```

### Rails API Template

```ruby
# backend/Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 7.1'
gem 'puma', '~> 6.3'
gem 'pg', '~> 1.5'
gem 'bcrypt', '~> 3.1'
gem 'rack-cors'
gem 'jbuilder', '~> 2.11'
gem 'jwt', '~> 2.7'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
end

group :development do
  gem 'listen', '~> 3.8'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

### React Frontend Template (with API Integration)

```javascript
// frontend/src/api/apiClient.js
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';

// Create axios instance
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    // Get token from localStorage
    const token = localStorage.getItem('token');
    
    // If token exists, add to headers
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Handle unauthorized errors (401)
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      // Optional: Redirect to login page
      // window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

// API functions
export const api = {
  // Auth endpoints
  auth: {
    login: (credentials) => apiClient.post('/auth/login', credentials),
    register: (userData) => apiClient.post('/auth/register', userData),
    logout: () => {
      localStorage.removeItem('token');
      return Promise.resolve();
    },
  },
  
  // User endpoints
  users: {
    getCurrent: () => apiClient.get('/users/me'),
    update: (userData) => apiClient.put('/users/me', userData),
  },
  
  // Resource endpoints
  resources: {
    getAll: () => apiClient.get('/resources'),
    getById: (id) => apiClient.get(`/resources/${id}`),
    create: (data) => apiClient.post('/resources', data),
    update: (id, data) => apiClient.put(`/resources/${id}`, data),
    delete: (id) => apiClient.delete(`/resources/${id}`),
  },
};

export default apiClient;
```

### Docker Compose Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: pguser
      POSTGRES_DB: app_development
    ports:
      - "5432:5432"

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - ./backend:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgresql://pguser:password@db/app_development
      RAILS_ENV: development

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "8000:8000"
    environment:
      - REACT_APP_API_URL=http://localhost:3000/api
    depends_on:
      - backend

volumes:
  postgres_data:
```

## Phase 5: ML Finance Applications

### ML Finance Project Template

```
day<N>/
├── README.md              # Daily challenge documentation
├── data/                  # Data directory
│   ├── raw/               # Raw financial data
│   ├── processed/         # Processed data
│   └── features/          # Feature engineered data
├── notebooks/             # Jupyter notebooks
│   ├── exploration.ipynb  # Data exploration
│   ├── modeling.ipynb     # Model development
│   └── evaluation.ipynb   # Model evaluation
├── src/                   # Source code
│   ├── __init__.py        # Package init
│   ├── data/              # Data processing modules
│   │   ├── __init__.py
│   │   ├── collect.py     # Data collection utilities
│   │   └── process.py     # Data processing utilities
│   ├── features/          # Feature engineering
│   │   ├── __init__.py
│   │   └── build.py       # Feature building utilities
│   ├── models/            # Model definitions
│   │   ├── __init__.py
│   │   └── train.py       # Model training utilities
│   └── evaluation/        # Model evaluation
│       ├── __init__.py
│       └── metrics.py     # Evaluation metrics
├── config/                # Configuration files
│   └── params.yaml        # Model parameters
├── requirements.txt       # Dependencies
└── setup.py               # Package setup
```

### Financial Data Processing Module

```python
# src/data/process.py
import pandas as pd
import numpy as np
from typing import Optional, List, Dict, Any, Union
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def load_financial_data(file_path: str, date_col: str = 'date') -> pd.DataFrame:
    """
    Load financial time series data from CSV.
    
    Args:
        file_path: Path to the CSV file
        date_col: Name of the date column
    
    Returns:
        DataFrame with datetime index
    """
    logger.info(f"Loading financial data from {file_path}")
    
    try:
        df = pd.read_csv(file_path)
        df[date_col] = pd.to_datetime(df[date_col])
        df.set_index(date_col, inplace=True)
        df.sort_index(inplace=True)
        
        logger.info(f"Loaded data with shape {df.shape}")
        return df
    
    except Exception as e:
        logger.error(f"Error loading data: {str(e)}")
        raise

def calculate_returns(
    df: pd.DataFrame, 
    price_col: str = 'close',
    periods: List[int] = [1, 5, 21]
) -> pd.DataFrame:
    """
    Calculate returns over different periods.
    
    Args:
        df: DataFrame with price data
        price_col: Column name containing price data
        periods: List of periods for return calculation (1=daily, 5=weekly, 21=monthly)
    
    Returns:
        DataFrame with additional return columns
    """
    logger.info(f"Calculating returns for periods: {periods}")
    
    result_df = df.copy()
    
    # Calculate simple returns
    for period in periods:
        col_name = f"return_{period}d"
        result_df[col_name] = df[price_col].pct_change(period)
    
    # Calculate log returns
    for period in periods:
        col_name = f"log_return_{period}d"
        result_df[col_name] = np.log(df[price_col] / df[price_col].shift(period))
    
    return result_df

def calculate_volatility(
    df: pd.DataFrame, 
    return_col: str = 'return_1d',
    windows: List[int] = [21, 63, 252]
) -> pd.DataFrame:
    """
    Calculate rolling volatility for different windows.
    
    Args:
        df: DataFrame with return data
        return_col: Column name containing return data
        windows: List of rolling windows for volatility calculation
    
    Returns:
        DataFrame with additional volatility columns
    """
    logger.info(f"Calculating volatility for windows: {windows}")
    
    result_df = df.copy()
    
    for window in windows:
        col_name = f"volatility_{window}d"
        result_df[col_name] = result_df[return_col].rolling(window=window).std() * np.sqrt(252)
    
    return result_df

def add_technical_indicators(df: pd.DataFrame, price_col: str = 'close') -> pd.DataFrame:
    """
    Add common technical indicators to the dataframe.
    
    Args:
        df: DataFrame with price data
        price_col: Column name containing price data
    
    Returns:
        DataFrame with additional technical indicator columns
    """
    logger.info("Adding technical indicators")
    
    result_df = df.copy()
    
    # Moving averages
    result_df['ma_50'] = result_df[price_col].rolling(window=50).mean()
    result_df['ma_200'] = result_df[price_col].rolling(window=200).mean()
    
    # Relative Strength Index (RSI)
    delta = result_df[price_col].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    
    rs = gain / loss
    result_df['rsi_14'] = 100 - (100 / (1 + rs))
    
    # Bollinger Bands
    result_df['ma_20'] = result_df[price_col].rolling(window=20).mean()
    result_df['bband_upper'] = result_df['ma_20'] + 2 * result_df[price_col].rolling(window=20).std()
    result_df['bband_lower'] = result_df['ma_20'] - 2 * result_df[price_col].rolling(window=20).std()
    
    # MACD
    result_df['ema_12'] = result_df[price_col].ewm(span=12, adjust=False).mean()
    result_df['ema_26'] = result_df[price_col].ewm(span=26, adjust=False).mean()
    result_df['macd'] = result_df['ema_12'] - result_df['ema_26']
    result_df['macd_signal'] = result_df['macd'].ewm(span=9, adjust=False).mean()
    result_df['macd_hist'] = result_df['macd'] - result_df['macd_signal']
    
    return result_df

def split_time_series(
    df: pd.DataFrame,
    test_size: float = 0.2,
    validation_size: Optional[float] = 0.1
) -> Dict[str, pd.DataFrame]:
    """
    Split time series data into train, validation, and test sets.
    
    Args:
        df: DataFrame with time series data
        test_size: Proportion of data for testing
        validation_size: Proportion of data for validation (None for no validation set)
    
    Returns:
        Dictionary with train, validation (optional), and test dataframes
    """
    logger.info(f"Splitting time series with test_size={test_size}, validation_size={validation_size}")
    
    n = len(df)
    test_idx = int(n * (1 - test_size))
    
    if validation_size is not None:
        val_idx = int(n * (1 - test_size - validation_size))
        train = df.iloc[:val_idx]
        validation = df.iloc[val_idx:test_idx]
        test = df.iloc[test_idx:]
        
        logger.info(f"Train shape: {train.shape}, Validation shape: {validation.shape}, Test shape: {test.shape}")
        return {'train': train, 'validation': validation, 'test': test}
    else:
        train = df.iloc[:test_idx]
        test = df.iloc[test_idx:]
        
        logger.info(f"Train shape: {train.shape}, Test shape: {test.shape}")
        return {'train': train, 'test': test}
```

## Template Usage Instructions

### How to Use These Templates

1. **Start with the right template**:
   - Identify which phase you're in and select the appropriate template
   - Copy the template structure to your day's project directory

2. **Customize for your specific project**:
   - Rename files and directories as needed
   - Remove components you don't need
   - Add additional files for your specific requirements

3. **Initialize with standard commands**:
   - For Ruby: `bundle init && bundle install`
   - For Python: `pip install -r requirements.txt`
   - For JavaScript: `npm init && npm install`

4. **Document in your README**:
   - Always update the README.md to describe your specific implementation
   - Include setup instructions
   - Document any deviations from the template

### Extending Templates

These templates are starting points - feel free to extend them based on your needs:

1. **Add authentication** to backend templates
2. **Integrate databases** appropriate for your project
3. **Enhance frontend** with UI libraries like Material UI or Bootstrap
4. **Add testing frameworks** specific to your project
5. **Include CI/CD configuration** as you progress

### Best Practices

1. **Maintain consistency** across your projects for easier comparison
2. **Document changes** to the template structure in your README
3. **Refactor common code** into reusable modules
4. **Version control** from the start of each project
5. **Follow language-specific conventions** for naming and structure

Happy coding with your 6/7 Challenge!
\n",
    