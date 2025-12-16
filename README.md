# Ruby File Manager

A small graphical file manager written in **Ruby** using **glimmer-dsl-libui**.  
This project was created for recreational programming and experimentation with desktop UIs in Ruby.

It allows basic directory navigation, file inspection, and opening files using the system default application.

## Built With

- Ruby
- [glimmer-dsl-libui](https://github.com/AndyObtiva/glimmer-dsl-libui)
- Standard UNIX commands (`ls`, `realpath`, `open`)

## Requirements

- Ruby 3.x recommended
- macOS or Linux  
  *(The `open` command is macOS-specific; Linux users may need to replace it with `xdg-open`)*
