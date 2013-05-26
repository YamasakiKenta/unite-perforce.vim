let s:save_cpo = &cpo
set cpo&vim

function! s:get_depots(args, path) 
	" ********************************************************************************
	" @par          depots ���擾����
	" @param[in]	args	�t�@�C����
	" @param[in]	context
	" ********************************************************************************
	if len(a:args) > 0
		let depots = a:args
	else
		let depots = [a:path]
	endif
	return depots
endfunction

function! perforce#get#fname#for_unite(args, context) 
	" �t�@�C�����̎擾
	let a:context.source__path          = expand('%:p')
	let a:context.source__linenr        = line('.')
	let a:context.source__depots        = s:get_depots(copy(a:args), a:context.source__path)
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
