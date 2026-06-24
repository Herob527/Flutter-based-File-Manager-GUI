# Simple Flutter-based File Manager GUI

This project aims to experiment with wrapping `ripgrep`, `fd-find`, `find` and other commands into GUI for file management

## Stack

- dart
- flutter
- get_it and injectable for DI
- build_runner

## Scope

- [x] Traversal through file system
- [x] Checking for executables of ripgrep and others
- [x] Search using ripgrep, fdfind and find (with defaults)
- [x] Capability to choose between search backends (ripgrep, fd-find and find)
- [ ] Compatibility with Linux, Windows and macOS
- [ ] Reporting speed of search results

## Notes

- Built-in find commands are fallbacks unless picked explicitly
