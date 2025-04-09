# Day X - Phase 3: Capstone Prep (Week XX)

## Today's Focus
- [ ] Primary goal: Design database schema for analytics platform
- [ ] Secondary goal: Create API documentation with OpenAPI
- [ ] Stretch goal: Set up CI/CD pipeline with GitHub Actions

## Launch School Connection
- Current course: LS180 - Database Foundations
- Concept application: Database normalization and schema design

## Project Context
This capstone preparation project is focused on building the foundation for the full-stack social media analytics platform. Today's work focuses on designing the database schema and setting up the development infrastructure.

## Tools & Technologies
- PostgreSQL for database
- dbdiagram.io for schema visualization
- Swagger/OpenAPI for API documentation
- GitHub Actions for CI/CD
- Docker for containerization

## Progress Log
- Started: 2025-11-XX 08:45
- Created entity-relationship diagram for analytics platform
- Defined tables with proper relationships and constraints
- Generated SQL migration scripts
- Created OpenAPI specification for planned endpoints
- Set up GitHub Actions for automated testing
- Configured Docker Compose for local development

## Code Highlight
```sql
-- Schema definition for analytics platform
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE social_accounts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,
    account_id VARCHAR(255) NOT NULL,
    access_token VARCHAR(255),
    refresh_token VARCHAR(255),
    token_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(platform, account_id)
);

CREATE TABLE analytics_metrics (
    id SERIAL PRIMARY KEY,
    social_account_id INTEGER REFERENCES social_accounts(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    followers INTEGER NOT NULL,
    engagement_rate DECIMAL(5,2) NOT NULL,
    impressions INTEGER NOT NULL,
    post_count INTEGER NOT NULL,
    UNIQUE(social_account_id, date)
);

-- Indexes for performance
CREATE INDEX idx_analytics_metrics_date ON analytics_metrics(date);
CREATE INDEX idx_social_accounts_user_id ON social_accounts(user_id);
```

## Challenges Faced
- Determining the right level of normalization for the analytics data
- Designing a schema that can accommodate various social media platforms
- Setting up proper foreign key constraints and indexes
- Balancing between flexibility and performance in the schema design

## Learning Resources Used
- Launch School LS180 material on database design
- PostgreSQL documentation on indexing strategies
- "Database Design for Mere Mortals" by Michael J. Hernandez
- OpenAPI specification 3.0 documentation

## Reflections
- Database design is foundational and difficult to change later
- Indexes should be planned carefully based on query patterns
- Foreign key constraints provide data integrity but add complexity
- Documentation-first approach to API design helps clarify requirements

## Tomorrow's Plan
- Implement database migrations with a migration tool
- Create seed data for development
- Set up database connection pooling
- Begin implementing core data access layer
