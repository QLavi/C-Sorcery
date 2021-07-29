function! Generate_Signs()
	call sign_define('warning', {'text': '??', 'texthl': 'Search', 'linehl': ''})
	call sign_define('error', {'text': '!!', 'texthl': 'Error', 'linehl': ''})
	call sign_define('note', {'text': '?', 'texthl': 'Visual', 'linehl': ''})

endfunction


let g:sorcery_flags = ' -Wall -g '
function! Compile()
	execute ':!gcc -c %'.g:sorcery_flags.' 2> csor798'
endfunction

function! Read_and_Parse()
	execute ':silent call Compile()'
	let file_buffer = readfile('csor798', '')

	let line_expr = '\v[0-9]+:'
	let type_expr = '\v(error|warning|note)'

	let line_type_pairs = []
	let id = 0
	let ids = []
	for line in file_buffer

		let line_n = matchstr(line, line_expr)
		let type_n = matchstr(line, type_expr)
		let descr = matchstr(line, '\v[a-zA-Z0-9]+\.c:[0-9]+:[0-9]+: '.type_expr.': ')
		if line_n || type_n

			let id = id + 1
			let ids += [id]
			let descr = line[strlen(descr):]
			let line_type_pairs += [[id, line_n, type_n, descr]]
		endif
	endfor

	for [id, lnr, type, descr] in line_type_pairs
		if empty(type)
			continue
		endif
		call sign_place(id, '', type, '%', {'lnum': lnr[:-2]})

		let curr_line = line('.')
		if curr_line == lnr[:-2]
			execute 'echo descr'
		endif
	endfor

endfunction

function! Check()
	call sign_unplace('*')
	call Read_and_Parse()
endfunction

call Generate_Signs()
map ss :w<cr> \| :call Check()<cr>
map cls :call sign_unplace('*')<cr>
