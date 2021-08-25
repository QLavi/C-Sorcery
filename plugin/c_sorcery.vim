function! Generate_Signs()
	call sign_define('warning', {'text': '??', 'texthl': 'Search', 'linehl': ''})
	call sign_define('error', {'text': '!!', 'texthl': 'Error', 'linehl': ''})
endfunction

let g:csor_build_cmd = 'make'
function! Gen_Compiler_Ouptut()
    silent! execute '!'..g:csor_build_cmd..' 2> .tmp'
    call sign_unplace('*')
    call Read_Output()
endfunction


let s:descr_list = []
function! Read_Output()
    let compiler_output = readfile('.tmp', '')
    if empty(compiler_output)
        call sign_unplace('*')
        return
    endif

    let name_expr = '\v[a-zA-Z0-9]+\.(.cc|.c|.cpp)'
    let ln_expr = '\v[0-9]+'
    let type_expr = '\v(error|warning)'
    let sub_expr = name_expr..':'..ln_expr..':'..ln_expr..':'..' '..type_expr..': '

    let id = 0
    for line in compiler_output
        let name = matchstr(line, name_expr)
        let ln = matchstr(line, ln_expr)
        let type = matchstr(line, type_expr)
        let descr = matchstr(line, sub_expr)
        if empty(descr)
            continue
        endif
        call sign_place(id, '', type, '%', {'lnum': ln})
        let id = id + 1
        let s:descr_list += [[ln, line[strlen(descr):]]]
    endfor
endfunction

function! Give_Descr()
    for [ln, descr] in s:descr_list
        if ln == line('.')
            echo descr
        endif
    endfor

endfunction

call Generate_Signs()

map cmp :call Give_Descr()<cr>
autocmd BufWritePost *.cc :call Gen_Compiler_Ouptut()
