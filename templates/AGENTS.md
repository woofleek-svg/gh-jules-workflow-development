# AGENTS.md

## Project Rules
- Use TypeScript for all new code
- Follow Prettier formatting (2-space indent)
- Write tests for all new features
- Run linting before committing

## Coding Conventions
- Prefix private methods with underscore
- Use async/await, not callbacks
- Handle errors with try/catch + custom Error classes

## Testing Requirements
- All new functions must have unit tests
- Test edge cases (empty input, null, invalid types)
- Aim for >80% coverage

## Jules CLI Integration
- Jules reads this file for project-specific rules
- Update this file when conventions change
- Be specific in task descriptions (include file paths, line numbers)
