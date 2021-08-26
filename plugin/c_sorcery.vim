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

    let extensions = '\.(cc|cpp|cpp|h|hpp)'
    let name_expr = '\v[a-zA-Z0-9]+'..extensions
    let ln_expr = '\v[0-9]+'
    let type_expr = '\v(error|warning)'
    let sub_expr = name_expr..':'..ln_expr..':'..ln_expr..':'..' '..type_expr..': '
    let incl_expr = '\v[0-9]+:$'

    let id = 0
    for line in compiler_output
        let name = matchstr(line, name_expr)
        let ln = matchstr(line, ln_expr)
        let type = matchstr(line, type_expr)
        let descr = matchstr(line, sub_expr)
        let incl_ln = matchstr(line, incl_expr)
        let incl_ln = incl_ln[:-2]

        if empty(incl_ln) == 0
            call sign_place(id, '', 'warning', name, {'lnum': incl_ln})
            let s:descr_list += [[incl_ln, 'error in included header']]
        endif

        if empty(descr)
            continue
        endif

        call sign_place(id, '', type, name, {'lnum': ln})

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
autocmd BufWritePost *.cc,*.cpp,*.hpp,*.h :call Gen_Compiler_Ouptut()
