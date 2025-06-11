# Documentation Contributing Guidelines

This document outlines the standards and processes for maintaining documentation in the Logistix project.

## Documentation Workflow

### Before Making Code Changes ⚠️

**ALWAYS** review existing documentation first:

1. **Check existing docs**: Review relevant files in `./docs/`
2. **Understand current patterns**: Follow established documentation style
3. **Identify affected docs**: Note which documentation needs updates

### After Making Code Changes ✅

1. **Update existing docs**: Modify files that reference changed code
2. **Create new docs**: Add documentation for new features
3. **Test examples**: Verify all code examples still work
4. **Update index**: Add new docs to `./docs/README.md`

## Documentation Standards

### File Structure

```markdown
# Feature Name

## Overview
Brief description

## Problem Statement  
What problem this solves

## Solution
How it's solved

## Architecture
Components and structure

## Implementation Details
Key classes and methods

## Usage Examples
Code examples

## Configuration
Setup and config

## Troubleshooting
Common issues and solutions

## Best Practices
Recommendations

## Files Modified/Created
List of changes
```

### Writing Style

- **Clear and concise**: Use simple, direct language
- **Code examples**: Always include working code snippets
- **Problem/solution format**: Explain the why, not just the how
- **Step-by-step instructions**: Make it easy to follow
- **Troubleshooting focus**: Anticipate common issues

### Code Examples

```dart
// ✅ Good: Clear, complete, runnable
final mapService = MapServiceFactory.instance;
final result = await mapService.geocode('Chennai, India');
if (result != null) {
  print('Location: ${result.location.lat}, ${result.location.lng}');
}

// ❌ Bad: Incomplete, unclear context
mapService.geocode('Chennai');
```

### Configuration Examples

```dart
// ✅ Good: Show actual values and structure
class MapProviderConfig {
  static const String olaMapsApiKey = 'YGZHUWNx9FCMEw8K8OzqTW7WGZMp4DSQ8Upv6xdM';
  static const String projectId = '0ac30075-fe27-4c12-84cc-ba9bda04231a';
}

// ❌ Bad: Generic placeholders without context
static const String apiKey = 'YOUR_API_KEY';
```

## Feature Documentation Checklist

When documenting a new feature:

- [ ] **Overview**: Clear description of purpose
- [ ] **Problem**: What issue it solves
- [ ] **Architecture**: Components and relationships
- [ ] **Setup**: Installation and configuration
- [ ] **Usage**: Basic and advanced examples
- [ ] **API Reference**: Methods, parameters, returns
- [ ] **Error Handling**: Common errors and solutions
- [ ] **Troubleshooting**: FAQ and debug tips
- [ ] **Best Practices**: Recommendations
- [ ] **Files Changed**: List of modified/created files
- [ ] **Testing**: How to verify it works

## Documentation Types

### Feature Documentation
- Complete implementation guides
- Architecture explanations
- Usage examples
- Troubleshooting guides

### API Documentation
- Method signatures
- Parameter descriptions
- Return value formats
- Error codes and handling

### Configuration Documentation
- Environment variables
- Default settings
- Customization options
- Best practices

### Troubleshooting Documentation
- Common issues
- Step-by-step solutions
- Debug techniques
- Performance tips

## Quality Standards

### Code Examples Must Be:
- **Runnable**: Copy-paste ready
- **Complete**: Include necessary imports
- **Realistic**: Use actual use cases
- **Tested**: Verified to work

### Architecture Diagrams Should:
- Show component relationships
- Include data flow
- Use consistent notation
- Be easy to understand

### Configuration Sections Must:
- Show complete examples
- Explain each option
- Include default values
- Provide customization guidance

## Review Process

### Self-Review Checklist
- [ ] Examples are tested and working
- [ ] Code snippets include necessary imports
- [ ] Configuration examples are complete
- [ ] Troubleshooting covers common issues
- [ ] Links to related documentation work
- [ ] File paths are correct
- [ ] Grammar and spelling checked

### Documentation Updates Required When:
- Adding new features
- Modifying existing APIs
- Changing configuration options
- Updating dependencies
- Fixing bugs that affect documentation
- Refactoring code structure

## File Naming Conventions

- **Feature docs**: `feature_name_guide.md`
- **Implementation docs**: `feature_name_implementation.md`
- **Integration docs**: `service_name_integration.md`
- **Fix docs**: `issue_type_fix.md`
- **Architecture docs**: `component_name_architecture.md`

## Documentation Organization

```
docs/
├── README.md                    # Documentation index
├── CONTRIBUTING.md             # This file
├── TEMPLATE.md                 # Documentation template
├── features/                   # Feature-specific docs
│   ├── maps/
│   ├── authentication/
│   ├── booking/
│   └── wallet/
├── architecture/               # System architecture
├── api/                       # API documentation
└── troubleshooting/           # Common issues
```

## Tools and Resources

### Recommended Tools
- **Markdown Editor**: VS Code with Markdown extensions
- **Diagram Tools**: Mermaid, draw.io
- **Code Formatting**: Prettier for consistent formatting

### Useful Extensions
- Markdown All in One (VS Code)
- Markdown Preview Enhanced (VS Code)
- Code Spell Checker (VS Code)

## Common Mistakes to Avoid

### ❌ Don't:
- Write documentation after the fact
- Use generic placeholder values
- Skip error handling in examples
- Forget to update existing docs
- Write implementation-only docs without usage
- Use outdated screenshots or examples

### ✅ Do:
- Document while developing
- Use real, working examples
- Include comprehensive error handling
- Keep existing docs up to date
- Focus on user needs and use cases
- Test all code examples

## Getting Help

If you need help with documentation:

1. **Review existing docs** for patterns and style
2. **Use the template** in `TEMPLATE.md`
3. **Check similar features** for reference
4. **Ask for review** before finalizing

## Maintenance Schedule

### Weekly:
- Review recent code changes for documentation updates
- Check for broken links or outdated examples

### Monthly:
- Review all documentation for accuracy
- Update any deprecated examples
- Check external links

### Per Release:
- Update version numbers
- Review breaking changes
- Update migration guides
- Verify all examples work with new version 