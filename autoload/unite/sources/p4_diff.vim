let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_diff#define()
	return s:source_diff
endfunction

function! s:get_source_file_from_path(path) "{{{
	" ********************************************************************************
	" 差分の出力を、Unite jump_list化
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let path = a:path
	let lines = readfile(path)
	let candidates = []
	let lnum = 1
	for line in lines
		let candidates += [{
					\ 'word' : lnum.' : '.line,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ 'action__text' : line,
					\ }]
		let lnum += 1
	endfor
	return candidates
endfunction
"}}}
function! s:perforce_get_file_source_diff(outs) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let data_d = {
		\ 'path'  : '',
		\ 'depot' : '',
		\ }
	for out in outs
		let num = perforce#get#lnum#from_diff_describe(out, num.lnum, num.snum)
		let lnum = num.lnum
		let data_d = perforce#get#path#from_diff(data_d, out)
		let candidates += [{
					\ 'word' : lnum.' : '.out,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : data_d.path,
					\ 'action__text' : substitute(out,'^[<>] ','',''),
					\ }]
	endfor
	return candidates
endfunction
"}}}

let s:source_diff = {
			\ 'name' : 'p4_diff',
			\ 'description' : 'ファイルの差分表示',
			\ }
function! s:source_diff.gather_candidates(args, context) "{{{

	" 引数がない場合は、空白を設定する ( 全検索 )
	if len(a:args) > 0
		let files   = a:args
		let all_flg = 0
	else
		let files   = ['']
		let all_flg = 1
	endif

	let rtns = []
	let outs = []
	" {{{
	for file in files
		if perforce#is_p4_have(file)
			" ★ 
			if 1
				if perforce#data#get('diff -dw', 'common') == 1
					let outs += perforce#cmd#base('diff -dw','',perforce#common#get_kk(file)).outs
				else
					let outs += perforce#cmd#base('diff','',perforce#common#get_kk(file)).outs
				endif
			endif
		else
			if 0
				let rtns += [{
							\ 'word' : file,
							\ 'kind' : 'jump_list',
							\ 'action__line' : 0,
							\ 'action__path' : file,
							\ 'action__text' : 0,
							\ }]
				echo file
				let rtns += s:get_source_file_from_path(file)
			endif
		endif
	endfor
	"}}}

	let rtns += s:perforce_get_file_source_diff(outs) 

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
		let opened_strs = perforce#cmd#base('opened','').outs

		for str in opened_strs
			if str =~ '.*#\d\+ - add change'
				let depot = perforce#get#depot#from_opened(str)
				let path = perforce#get#path#from_depot(depot)

				let rtns += [{
							\ 'word' : path,
							\ 'kind' : 'jump_list',
							\ 'action__line' : 0,
							\ 'action__path' : path,
							\ 'action__text' : 0,
							\ }]

				echo path
				call input("")
				let rtns += s:get_source_file_from_path(path)
			endif
		endfor

	endif
	return rtns
endfunction
"}}}

if 1
	call unite#define_source(s:source_diff)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

