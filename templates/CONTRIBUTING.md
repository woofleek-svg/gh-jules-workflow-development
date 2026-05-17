# Contributing

## Jules CLI Guidelines

When using Jules for this project:

1. **Provide Clear Prompts**
   - Be specific about what you want
   - Include file paths and line numbers
   - Mention edge cases to handle

2. **Use AGENTS.md**
   - Jules reads this for project rules
   - Update it when conventions change

3. **Review Changes**
   - Always check the diff before merging
   - Test locally if possible

4. **Encourage Testing**
   - Ask Jules to write tests for new features
   - Verify tests pass before merging

## Standard Workflow

1. Create task: `jules remote new --repo <owner>/<repo> "<task>"`
2. Wait for session: `jules remote list --session`
3. Review PR: `gh pr diff <number>`
4. Comment for changes: `gh pr comment <number> --body "<feedback>"`
5. Create follow-up session if needed
6. Merge when satisfied: `gh pr merge <number> --squash --delete-branch`
