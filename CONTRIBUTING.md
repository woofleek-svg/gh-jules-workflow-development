# Contributing

First off, thank you for considering contributing to this project!

## Project Structure

This project currently serves as a development and testing ground for Jules workflows. As an initial step, the repository contains foundational documentation.

```text
.
└── CONTRIBUTING.md  # Project guidelines and setup instructions
```

*(Note: As the project evolves, this section should be updated to reflect the addition of source code directories, tests, etc.)*

## Setup Instructions

To get started with local development, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/woofleek-svg/gh-jules-workflow-development.git
   cd gh-jules-workflow-development
   ```

*(Currently, there are no code dependencies or build steps, as the repository only contains documentation. This section will be expanded once code is added to the project.)*

## Jules CLI Guidelines

Jules is our AI software engineer designed to assist with coding tasks, bug fixes, feature implementations, and more. When using the Jules CLI, keep the following guidelines in mind to get the best results:

1. **Provide Clear Prompts:**
   Be as specific as possible about what you want Jules to accomplish. Include details about which files to modify, the desired behavior, and any edge cases to handle.

2. **Utilize `AGENTS.md`:**
   Jules reads `AGENTS.md` files (which can be placed anywhere in the repository, usually in the root) to understand project-specific rules, coding conventions, architectural guidelines, and test instructions. Use `AGENTS.md` to define standard procedures.

3. **Verify Work & Review Changes:**
   Always review the code changes Jules proposes. Ensure that they meet the project's standards and that no unintended side effects were introduced.

4. **Encourage Testing:**
   Ask Jules to write tests for any new features or bug fixes, and ensure it runs the tests to verify the changes.
