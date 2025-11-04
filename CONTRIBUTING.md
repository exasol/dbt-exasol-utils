# Contributing to dbt-exasol-utils

Thank you for your interest in contributing to dbt-exasol-utils! This document provides guidelines and instructions for contributing.

## Getting Started

### Prerequisites

- Exasol database (for testing)
- Python 3.8+
- dbt-core and dbt-exasol installed
- Familiarity with dbt and SQL

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git fork https://github.com/your-org/dbt-exasol-utils.git
   cd dbt-exasol-utils
   ```

2. **Install dependencies**
   ```bash
   cd integration_tests
   dbt deps
   ```

3. **Configure your Exasol connection**

   Create or update `~/.dbt/profiles.yml`:
   ```yaml
   exasol:
     target: dev
     outputs:
       dev:
         type: exasol
         dsn: your-exasol-host:8563
         user: your-username
         password: your-password
         dbname: your-schema
         schema: your-schema
   ```

## Development Workflow

### Adding a New Macro

1. **Create the macro file** in the appropriate subdirectory

   Macros are organized by package namespace:
   - `macros/dbt_utils/` - for dbt_utils macro overrides
   - `macros/dbt_date/` - for dbt_date macro overrides

   Follow the naming convention: `macro_name.sql` (not `exasol__macro_name.sql`)

   Example for a dbt_utils macro:
   ```sql
   {# macros/dbt_utils/your_macro.sql #}
   {% macro exasol__your_macro(arg1, arg2) %}
       -- Exasol-specific implementation
       select {{ arg1 }} + {{ arg2 }}
   {% endmacro %}
   ```

2. **Add integration tests** in `integration_tests/models/`

   ```sql
   -- integration_tests/models/test_your_macro.sql
   select {{ dbt_utils.your_macro(1, 2) }} as result
   from (select 1) test_data
   ```

3. **Run the tests**
   ```bash
   cd integration_tests
   dbt run --select test_your_macro
   ```

4. **Update documentation**
   - Add usage example to README.md
   - Add entry to CHANGELOG.md
   - Update integration_tests/README.md if needed

### Testing Your Changes

Always test your changes before submitting a PR:

```bash
cd integration_tests

# Install dependencies
dbt deps

# Run all tests
dbt run

# Run specific test
dbt run --select test_your_macro

# Check compiled SQL
dbt compile
```

### Code Style

- Use Jinja2 best practices
- Add comments explaining complex logic
- Follow existing code formatting patterns
- Use meaningful variable names

### Writing Good Macros

1. **Use native Exasol functions when available** - This provides better performance
2. **Handle edge cases** - Consider NULL values, empty strings, etc.
3. **Match the interface** - Your macro should work as a drop-in replacement for the dbt_utils/dbt_date equivalent
4. **Test thoroughly** - Include various input scenarios

## Submitting Changes

### Before You Submit

- [ ] Tests pass: `dbt run` in integration_tests/
- [ ] Updated CHANGELOG.md with your changes
- [ ] Updated README.md if adding new functionality
- [ ] Added/updated integration tests
- [ ] Code follows the project style

### Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add support for new_macro"
   ```

   Use conventional commit messages:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `test:` - Test changes
   - `refactor:` - Code refactoring

3. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

   Then create a Pull Request on GitHub.

4. **PR Review**
   - Maintainers will review your PR
   - Address any feedback
   - Once approved, your PR will be merged

## Reporting Issues

### Bug Reports

When reporting bugs, please include:
- dbt version, dbt-exasol version, Exasol version
- Steps to reproduce
- Expected vs actual behavior
- Error messages/logs
- Code samples (if applicable)

Use the bug report template when creating an issue.

### Feature Requests

When requesting features:
- Describe the problem you're trying to solve
- Explain why existing functionality doesn't work
- Provide examples of how you'd use the feature
- Consider if you can contribute the implementation

Use the feature request template when creating an issue.

## Questions?

- Check existing issues and documentation first
- Open a new issue for questions
- Join the dbt Community Slack (#db-exasol channel)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

## License

By contributing to dbt-exasol-utils, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to dbt-exasol-utils! 🎉
