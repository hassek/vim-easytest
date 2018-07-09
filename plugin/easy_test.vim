" EasyTests - the genki dama to run your tests
"
" Author: Tomás Henríquez <tchenriquez@gmail.com>
" Source repository: https://github.com/hassek/EasyTest

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
" }}}

python << endpython
def run_current_test():
  run_test('test')

def run_current_class():
  run_test('class')

def run_current_file():
  run_test('file')

def run_current_test_on_terminal():
  run_test('test', on_terminal=True)

def run_current_class_on_terminal():
  run_test('class', on_terminal=True)

def run_current_file_on_terminal():
  run_test('file', on_terminal=True)

def run_test(level, on_terminal=False):
  import vim

  def easytest_django_syntax(cls_name, def_name):
    base = "./manage.py test "
    file_path = vim.eval("@%").replace('.py', '').replace("/", '.')

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
      return base + "\:" + ".".join(names)
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

  cb = vim.current.buffer
  cw = vim.current.window
  original_position = vim.current.window.cursor

  for func, value in vim.vars.items():
    if 'easytest' in func and value == 1:
      func = locals()[func]
      break
  else:
      func = locals()['easytest_django_syntax']

  vim.command("?\<def\>")
  def_name = cb[vim.current.window.cursor[0] - 1].split()[1].split('(')[0].strip(":")
  try:
    vim.command("?\<class\>")
    cls_name = cb[vim.current.window.cursor[0] - 1].split()[1].split('(')[0].strip(":")
  except vim.error:
    cls_name = None

  if level == 'class' or level == 'file':
    def_name = None

  if level == 'file':
    cls_name = None

  command = func(cls_name, def_name)
  cw.cursor = original_position
  vim.command("let @/ = ''")  # clears search
  if on_terminal:
    vim.command('Start ' + command)
  else:
    vim.command("Dispatch " + command)
endpython
