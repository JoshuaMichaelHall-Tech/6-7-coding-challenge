# Ruby Portfolio Project Plan
## 6/7 Coding Challenge - Phase 1 (200 Hours)
Part of the [6/7 Coding Challenge](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge) documentation. See [Documentation Index](https://github.com/JoshuaMichaelHall-Tech/6-7-coding-challenge/blob/main/DOCUMENTATION.md) for all guides.

This document outlines three significant Ruby projects of increasing complexity to build during Phase 1 of my 6/7 Coding Challenge. Each project is designed to showcase different aspects of my Ruby mastery while building toward my career goals in ML finance.

## Time Allocation

- **Total Time Budget**: 200 hours (100 days × 2 hours/day)
- **Planning/Learning Time**: 20 hours
- **Project 1**: 40-50 hours
- **Project 2**: 60-70 hours
- **Project 3**: 80-90 hours

## Project 1: TaskMaster CLI (40-50 hours)
A sophisticated command-line productivity system demonstrating Ruby fundamentals, OOP principles, and data persistence.

### Key Features
- Task tracking with priorities, due dates, and categories
- Time tracking for tasks with reporting
- Data visualization in the terminal
- Analytics and productivity metrics
- SQLite persistence
- Export to various formats (CSV, JSON)

### Technical Implementation
1. **Core Domain Model** (10h)
   - Task, Category, Tag, and TimeEntry classes
   - Service objects for business logic
   - Repository pattern for data access

2. **Command Line Interface** (8h)
   - Command pattern for CLI operations
   - TTY gem for enhanced terminal UI
   - Thor for command parsing

3. **Data Persistence** (8h)
   - SQLite database with proper migrations
   - Repository classes for data access
   - Data validation and error handling

4. **Reports & Analytics** (10h)
   - Burndown charts and progress visualization
   - Time analysis reports
   - Productivity metrics

5. **Testing & Documentation** (8h)
   - Comprehensive RSpec test suite
   - Detailed README with examples
   - Inline documentation

### Distinguishing Factors
- Plugin architecture for extensibility
- Proper logging and error handling
- Terminal-based data visualization
- YAML configuration support

### Timeline
- Weeks 1-4 (Days 1-24)
- Mid-project review at Day 12

## Project 2: ContentForge API (60-70 hours)
A RESTful content management API that demonstrates your backend design skills, authentication, and performance optimization capabilities.

### Key Features
- RESTful API design with versioning
- JWT authentication and role-based authorization
- Content modeling with relationships
- Advanced filtering and search
- Performance optimization with caching
- API documentation

### Technical Implementation
1. **API Architecture** (12h)
   - Sinatra application structure
   - Middleware stack configuration
   - Routing and controller organization

2. **Authentication & Authorization** (10h)
   - JWT implementation
   - Role-based access control
   - Security best practices

3. **Data Layer** (15h)
   - PostgreSQL schema design
   - Advanced queries and indexing
   - Database optimization

4. **Content Services** (15h)
   - CRUD operations
   - Relationship management
   - Search and filtering

5. **Performance & Testing** (15h)
   - Caching strategies
   - Load testing
   - Performance optimization

### Distinguishing Factors
- Custom query language for content filtering
- Real-time capabilities with WebSockets
- Comprehensive Swagger/OpenAPI documentation
- Rate limiting and request throttling
- Basic admin dashboard for content management

### Timeline
- Weeks 5-10 (Days 25-60)
- Mid-project review at Day 42

## Project 3: DistribuRuby (80-90 hours)
A distributed task processing system demonstrating your understanding of advanced Ruby concepts and distributed systems principles.

### Key Features
- Distributed job scheduling and execution
- Worker pools for parallel processing
- Job persistence and failure recovery
- Monitoring dashboard
- Horizontal scaling capabilities
- Workflow orchestration

### Technical Implementation
1. **Core Architecture** (15h)
   - Job representation and serialization
   - Queue abstraction
   - Worker process management

2. **Persistence Layer** (15h)
   - Job storage and retrieval
   - State management
   - Failure recovery mechanisms

3. **Concurrency Control** (20h)
   - Worker pools
   - Thread safety
   - Distributed locking

4. **Monitoring & Instrumentation** (15h)
   - Metrics collection
   - Dashboard visualization
   - Alerting system

5. **Advanced Features** (15h)
   - Job dependencies and workflows
   - Priority queues
   - Scheduling algorithms

6. **Testing & Documentation** (10h)
   - Integration testing
   - Load testing
   - Architecture documentation

### Distinguishing Factors
- Support for multiple queue backends (Redis, RabbitMQ)
- Leader election for coordinating workers
- Dead letter queues and job retry strategies
- Plugin system for custom job processors
- Comprehensive monitoring

### Timeline
- Weeks 11-17 (Days 61-100)
- Mid-project review at Day 80

## Portfolio Presentation Strategy

### Documentation Standards
- README with clear installation and usage instructions
- Architecture diagrams using Mermaid
- API documentation where applicable
- Code examples and use cases

### Demonstration Materials
- Terminal recordings of CLI applications
- API interaction examples
- Performance benchmarks

### Supplementary Content
- Technical blog posts about design decisions
- Architecture decision records (ADRs)
- Lessons learned documents

## Connecting to ML Finance Career Path

Each project includes elements that showcase skills relevant to ML finance roles:

1. **TaskMaster CLI**
   - Data analysis and reporting
   - Statistical tracking of productivity metrics
   - Time series visualization

2. **ContentForge API**
   - Structured data management
   - Query optimization
   - Authentication and security

3. **DistribuRuby**
   - Parallel processing (essential for ML workloads)
   - Distributed systems concepts
   - Scalable architecture design

## Development Workflow Integration

### Daily Workflow
- Update project Kanban board (5 min)
- Document progress in daily log (10 min)
- TDD approach for feature development (ongoing)
- End-of-session commit with detailed message (5 min)

### Weekly Workflow
- Code review and refactoring session (Saturday)
- Update project documentation (Saturday)
- Plan next week's deliverables (Saturday)

## Resources and References

### Ruby Best Practices
- Sandi Metz's POODR principles
- Thoughtbot guides
- Ruby Style Guide

### Testing Resources
- RSpec documentation
- Testing patterns
- Benchmarking tools

### Infrastructure
- Docker for development environments
- CI/CD setup with GitHub Actions
- Deployment documentation

---

This plan provides a structured approach to building three significant Ruby projects that demonstrate my mastery of the language and prepare me for my ML finance career path. Each project builds on the skills of the previous one while introducing new concepts and challenges.
