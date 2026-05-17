# Contributing

Welcome to the `gh-jules-workflow-development` project! This document outlines guidelines for using Jules effectively when contributing.

## Jules Prompt Categories

When creating tasks for Jules, you can structure your prompts around the following categories to maintain and improve the project:

*   **Code Health**: Prompts focused on refactoring, improving readability, optimizing performance, and reducing technical debt.
*   **Security**: Prompts focused on identifying and patching vulnerabilities, auditing dependencies, and enforcing secure coding practices.
*   **Testing**: Prompts focused on adding or improving unit tests, integration tests, and end-to-end testing coverage.

## Example Jules Task Prompt

You can run a Jules task directly from the command line using the GitHub CLI (`gh`). Here is an example showing the exact CLI syntax:

```bash
gh jules task "Refactor the workflow scripts in the scripts/ directory to improve error handling and logging."
```

## Multi-Session Tasks

For complex operations that involve multiple independent steps or changes across different areas of the codebase, you can speed up execution using parallel sessions.

**Note on `--parallel`:** Use the `--parallel` flag for multi-session tasks to allow Jules to execute independent tasks concurrently, significantly reducing the overall time required.

```bash
gh jules task --parallel "Audit security vulnerabilities, update unit tests, and format the documentation."
```
