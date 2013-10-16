# vim-easytest

## About

EasyTest is a utility plugin which allows you to run unit tests easier
avoiding the need to write the name of the specific test, class or file
you want to run.

### Examples videos are coming soon

## Features

- Run your tests Asynchronously
- See results on your quickfix
- Run tests on your terminal right away if needed (i.e. for debugging with pdb)

## Installation

You need the amazing plugin [dispatch](https://github.com/tpope/vim-dispatch) for vim-easytest to run.

## Supported Syntax

- Python
  - django (Default)
  - django-nose

to change the default syntax for a specific language just set `let easytest_{syntax_name}_syntax = 1` in your `.vimrc` file
 

## Quick Start
TODO

## Mapping

Currently there is no default mapping so everyone can just map it however they want. But here is a good recommendation for a default:

    nmap <S-t> :py run_current_test()<CR>
    nmap <leader>t :py run_current_test(on_terminal=True)<CR>
    nmap <C-t> :py run_current_class()<CR>
    nmap <D-t> :py run_current_file()<CR>

## Contributing
As one can see, there're still many issues to be resolved, patches, suggestions and new language/framework syntax are always welcome! A list of open feature requests can be found [here](../../issues?labels=enhancement&state=open).
