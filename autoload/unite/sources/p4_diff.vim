let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_diff#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_diff',
			\ 'description' : 'ファイルの差分表示',
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" 引数がない場合は、空白を設定する ( 全検索 )
	if len(a:args) > 0
		let files = a:args
		let all_flg = 0
	else
		let files = ['']
		let all_flg = 1
	endif

	let rtns = []
	let outs = []
	for file in files
		if perforce#is_p4_have(file)
			" ★ 
			if 1
				if perforce#data#get('diff -dw', 'common') == 1
					let outs += perforce#pfcmds('diff -dw','',perforce#common#get_kk(file)).outs
				endif
			endif
		else
			let rtns += [{
						\ 'word' : file,
						\ 'kind' : 'jump_list',
						\ 'action__line' : 0,
						\ 'action__path' : file,
						\ 'action__text' : 0,
						\ }]
			let rtns += perforce#get_source_file_from_path(file)
		endif
	endfor

	let rtns += perforce#get_source_diff_from_diff(outs) 

	" 表示をループさせる
	if all_flg == 0
		let nowline = line(".")
		let cnt = 0
		for rtn in rtns
			let line = rtn.action__line
			if line >= nowline
				exe 'let rtns = rtns['.cnt.':-1]  + rtns[0:'.cnt.']'
				break
			endif
			let cnt += 1
		endfor
	endif

	" add したファイルを追加する
	if all_flg
		"let file = 
		let opened_strs = perforce#pfcmds('opened','').outs

		for str in opened_strs
			if str =~ '.*#\d\+ - add change'
				let depot = perforce#get_depot_from_opened(str)
				let path = perforce#get_path_from_depot(depot)

				let rtns += [{
							\ 'word' : path,
							\ 'kind' : 'jump_list',
							\ 'action__line' : 0,
							\ 'action__path' : path,
							\ 'action__text' : 0,
							\ }]

				let rtns += perforce#get_source_file_from_path(path)
			endif
		endfor

	endif
	return rtns
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

