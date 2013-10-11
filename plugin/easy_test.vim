" EasyTests - the genki dama to run your tests
"
" Author: Tomás Henríquez <tchenriquez@gmail.com>
" Source repository: https://github.com/hassek/EasyTest 

" Script initialization {{{
	if exists('g:Easy_test_loaded') || &compatible || version < 702
		finish
	endif

	let g:Easy_test_loaded = 1

  " Supported syntexes
  let g:easytest_django_nose_syntax = 0
  let g:easytest_django_syntax = 0
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

  def easytest_django_syntax(file_name, cls_name, def_name):
    file_name = file_name.split('/')[-2]

    # filter null values
    names = [nn for nn in [cls_name, def_name] if nn]

    if names:
      return file_name + "." + ".".join(names)
    return file_name

  def easytest_django_nose_syntax(file_name, cls_name, def_name):
    file_name = "/".join(file_name.split('/')[-2:])

    # filter null values
    names = [nn for nn in [cls_name, def_name] if nn]

    if names:
      return file_name + ":" + ".".join(names)
    return file_name

  cb = vim.current.buffer
  cw = vim.current.window
  original_position = vim.current.window.cursor

  for func, value in vim.vars.items():
    if 'easytest' in func and value == 1:
      func = locals()[func]
      break
  else:
      func = locals()['easytest_django_syntax']

  file_name = cb.name
  vim.command("?\<def\>")
  def_name = cb[vim.current.window.cursor[0] - 1].split()[1].split('(')[0] 
  vim.command("?\<class\>")
  cls_name = cb[vim.current.window.cursor[0] - 1].split()[1].split('(')[0] 

  if level == 'class' or level == 'file':
    def_name = None

  if level == 'file':
    cls_name = None

  command = "./manage.py test "
  command += func(file_name, cls_name, def_name)
  cw.cursor = original_position
  vim.command("let @/ = ''")  # clears search
  if on_terminal:
    vim.command('Start ' + command)
  else:
    vim.command("Dispatch " + command)
endpython

" Common key mappings
"nmap <S-t> :py run_current_test()<CR>
"nmap <leader>t :py run_current_test(on_terminal=True)<CR>
"nmap <C-t> :py run_current_class()<CR>
"nmap <D-t> :py run_current_file()<CR>
