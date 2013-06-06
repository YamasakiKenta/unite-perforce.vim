let s:save_cpo = &cpo
set cpo&vim

function! s:get_depots(args, path) 
	" ********************************************************************************
	" @par          depots を取得する
	" @param[in]	args	ファイル名
	" @param[in]	context
	" ********************************************************************************
	if len(a:args) > 1
		let depots = a:args[1:]
	else
		let depots = [a:path]
	endif
	return depots
endfunction

function! s:get_clients(args)
	let client = get(a:args, 0, '')
	if type(client) != type([])
		let clients = [client]
	else
		let clients = client
	endif
	return clients
endfunction

function! perforce#get#fname#for_unite(args, context) 
	" [2013-06-07 02:29]
	"
	" ファイル名の取得
	let path = expand('%:p')
	let a:context.source__path          = path
	let a:context.source__linenr        = line('.')
	let a:context.source__client        = s:get_clients(a:args)
	let a:context.source__client_flg    = exists('a:args[0]') ? 1 : 0
	let a:context.source__depots        = s:get_depots(copy(a:args), path)
	call unite#print_message('[line] Target: ' . path)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
