# Contributing to Poe Accountant

Thank you for your interest in contributing to Poe Accountant! We welcome contributions from the community and are pleased to have you join us.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- Git
- Nix with flakes enabled
- direnv (recommended for automatic environment setup)

See the [Development Environment Setup](README.md#development-environment-setup) section in the README for detailed installation instructions.

### Setting up the Development Environment

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd poe-accountant
   ```

2. **Enter the development environment**:
   ```bash
   # If using direnv (recommended)
   direnv allow
   
   # Or manually
   nix develop
   ```

3. **Install dependencies**:
   ```bash
   task install
   ```

## Development Workflow

### Project Structure

This project is organized as a Yarn workspace with the following structure:
- `projects/api/` - API server implementation
- `projects/common/` - Shared utilities and types
- `projects/ninja-server/` - Ninja API server implementation

### Making Changes

1. **Create a new branch** for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** in the appropriate workspace(s)

3. **Test your changes**:
   ```bash
   # Run tests for all workspaces
   yarn test
   
   # Run tests for a specific workspace
   yarn workspace <workspace-name> test
   ```

4. **Lint your code**:
   ```bash
   # Lint all workspaces
   yarn lint
   
   # Lint a specific workspace
   yarn workspace <workspace-name> lint
   ```

5. **Build the project**:
   ```bash
   # Build all workspaces
   yarn build
   
   # Build a specific workspace
   yarn workspace <workspace-name> build
   ```

### Commit Guidelines

- Use clear and descriptive commit messages
- Follow the conventional commit format: `type(scope): description`
- Examples:
  - `feat(api): add new endpoint for item pricing`
  - `fix(common): resolve type definition issue`
  - `docs: update installation instructions`

### Pull Request Process

1. **Ensure your code is tested** and all existing tests pass
2. **Update documentation** as needed
3. **Submit a pull request** with:
   - A clear title and description
   - Reference to any related issues
   - Screenshots or examples if applicable

## Code Style

- Follow TypeScript best practices
- Use meaningful variable and function names
- Include JSDoc comments for public APIs
- Maintain consistency with the existing codebase

## Testing

- Write unit tests for new functionality
- Ensure all tests pass before submitting a PR
- Include integration tests where appropriate

## Reporting Issues

When reporting issues, please include:
- A clear description of the problem
- Steps to reproduce the issue
- Expected vs actual behavior
- Your environment details (OS, Node.js version, etc.)

## Getting Help

If you need help or have questions:
- Open an issue for bugs or feature requests
- Check existing issues and discussions
- Reach out to the maintainers

## License

By contributing to Poe Accountant, you agree that your contributions will be licensed under the Mozilla Public License 2.0.
