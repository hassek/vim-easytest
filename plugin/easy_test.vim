" EasyTests - the genki dama of test runner
"
" Author: Tomás Henríquez <tchenriquez@gmail.com>
" Source repository: https://github.com/hassek/vim-easytest

" Script initialization {{{
	if exists('g:Easy_test_loaded') || &compatible || version < 702
		finish
	endif

	let g:Easy_test_loaded = 1

  " Supported syntaxes
  " let g:easytest_django_nose_syntax = 0
  " let g:easytest_pytest_syntax = 0
  " let g:easytest_django_syntax = 0
  " let g:easytest_ruby_syntax = 0
  " let g:easytest_rust_syntax = 0
  " let g:easytest_go_syntax = 0
  "
  " Go debugger support (requires delve: https://github.com/go-delve/delve)
  " let g:easytest_go_use_dlv = 1
" }}}

pythonx << endpython
def run_current_test():
  run_test('test')

def run_current_class():
  run_test('class')

def run_current_file():
  run_test('file')

def run_current_package():
  run_test('package')

def run_current_test_on_terminal():
  run_test('test', on_terminal=True)

def run_current_class_on_terminal():
  run_test('class', on_terminal=True)

def run_current_file_on_terminal():
  run_test('file', on_terminal=True)

def run_current_package_on_terminal():
  run_test('package', on_terminal=True)

def run_all_tests():
  run_test('all')

def run_all_tests_on_terminal():
  run_test('all', on_terminal=True)

def run_test(level, on_terminal=False):
  import vim

  def easytest_django_syntax(cls_name, def_name):
    base = "./manage.py test "
    if level == 'all':
      return base

    file_path = vim.eval("@%").replace('.py', '').replace("/", '.')
    if level == 'package':
      file_path = file_path.rpartition('.')[0]

    # filter null values
    names = [nn for nn in [cls_name, def_name] if nn]

    if names:
      return base + file_path + "." + ".".join(names)
    return base + file_path

  def easytest_django_nose_syntax(cls_name, def_name):
    base = "./manage.py test %"
    # filter null values
    names = [nn for nn in [cls_name, def_name] if nn]

    if names:
      return base + "\\:" + ".".join(names)
    return base

  def easytest_pytest_syntax(cls_name, def_name):
    base = "pytest %"
    names = [nn for nn in [cls_name, def_name] if nn]

    if names:
      return base + "::" + "::".join(names)
    return base

  def easytest_ruby_syntax(cls_name, def_name):
    path_name = vim.eval("@%")
    base = "ruby -I\"lib:test\" " + path_name

    if cls_name:
      base += " -t " + cls_name
    if def_name:
      base += " -n " + def_name

    return base

  def easytest_rust_syntax(cls_name, def_name):
    base = "cargo test "
    if level == 'all':
      return base

    file_path = vim.eval("@%").replace('.rs', '').replace('src/', '')
    if level == 'package':
      file_path = file_path.rpartition('::')[0]

    # filter null values
    names = [nn for nn in [cls_name, def_name] if nn]

    if names:
      return base + file_path + "::" + "::".join(names) + " -- --nocapture"
    return base + file_path + " -- --nocapture --nocapture"

  def easytest_go_syntax(cls_name, def_name):
    use_dlv = vim.vars.get('easytest_go_use_dlv') == 1

    if use_dlv:
      base = "dlv test "
      if level == 'all':
        return base + "./..."

      file_path = "./" + "/".join(vim.eval("@%").split('/')[:-1])
      if level in ('package', 'class'):
        return base + file_path

      # dlv requires -- separator and -test.run instead of -run
      return base + file_path + " -- -test.run " + def_name + "$"
    else:
      base = "go test "
      if level == 'all':
        return base + "./..."

      file_path = "./" + "/".join(vim.eval("@%").split('/')[:-1])
      if level in ('package', 'class'):
        return base + file_path

      return base + file_path + " -run " + def_name + "$"


  cb = vim.current.buffer
  cw = vim.current.window
  original_position = vim.current.window.cursor

  for syntype in ["easytest_django_syntax", "easytest_django_nose_syntax", "easytest_pytest_syntax", "easytest_ruby_syntax", "easytest_rust_syntax", "easytest_go_syntax"]:
    if vim.vars.get(syntype) == 1:
      func = locals()[syntype]
      break
  else:
      func = locals()['easytest_django_syntax']

  def_name = None
  try:
    # Get the indentation level at the cursor position
    cursor_line = cb[original_position[0] - 1]
    cursor_indent = len(cursor_line) - len(cursor_line.lstrip())

    # Keep searching backward for a function at the same or lower indentation level
    max_attempts = 20  # Prevent infinite loops
    for attempt in range(max_attempts):
      vim.command(r"?\<def\>\|\<fn\>\|\<func\>")
      current_line_num = vim.current.window.cursor[0]
      line = cb[current_line_num - 1]
      line_indent = len(line) - len(line.lstrip())

      # Only consider functions at the same or lower indentation than cursor
      if line_indent <= cursor_indent:
        parts = line.replace('async ', '').split()

        # Check if we have at least 2 parts (keyword + name)
        if len(parts) >= 2:
          potential_name = parts[1].split('(')[0].strip(":").strip("{").strip()

          # Check if it's a valid function name (not empty and not punctuation)
          if potential_name and potential_name not in ['(', '{', ')', '}']:
            def_name = potential_name
            break

      # If we're already at line 1, stop searching
      if current_line_num == 1:
        break
  except vim.error:
    pass
  try:
    vim.command(r"?\<class\>\|\<mod\>")
    cls_name = cb[vim.current.window.cursor[0] - 1].split()[1].split('(')[0].strip(":").strip("{").strip()
  except vim.error:
    cls_name = None

  if level == 'class' or level == 'file':
    def_name = None

  if level == 'file':
    cls_name = None

  if level == 'package' or level == 'all':
    cls_name = None
    def_name = None

  command = func(cls_name, def_name)
  cw.cursor = original_position
  print(f"command {command}")
  vim.command("let @/ = ''")  # clears search
  if on_terminal:
    vim.command('Dispatch ' + command)
  else:
    vim.command("Start " + command)
endpython
