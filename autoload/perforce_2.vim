let s:save_cpo = &cpo
set cpo&vim

if 1
	let s:L = vital#of('unite-perforce.vim')
	let s:File = s:L.import('Mind.Y_files')
else
	function! s:get_files(...) "{{{
		return get(a:, 1, "") == "" ? [expand("%:p")] : a:000
	endfunction
	"}}}
	let s:File = {}
	let s:File.get_files = function('s:get_files')
endif



function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" 補完 : perforce 上に存在するファイルを表示する
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction "}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" @param[in] add_flg true : クライアントに存在しない場合は、ファイルを追加
	" @param[in] a:000     {ファイル名}     値がない場合は、現在のファイルを編集する
	" @retval    なし
	" ********************************************************************************
	"
	" 編集するファイ目名の取得

	if a:0 == 0
		let _files = [perforce#common#get_now_filename()]
	else
		" ファイル名が指定されている場合
		let _files = a:000
	endif


	" init
	let file_d = {
				\ 'add' : '',
				\ 'edit' : '',
				\ 'null' : '',
				\ }

	" ファイルが存在しない場合、追加する
	for _file in _files
		let cmd = 'null'
		if perforce#is_p4_have(_file)
			let cmd = 'edit'
		else
			if ( a:add_flg == 1 )
				let cmd = 'add'
			endif
		endif

		let file_d[cmd] = file_d[cmd].' '.perforce#common#get_kk(_file)
	endfor

	unlet file_d['null']

	" init 
	let outs = []

	" コマンドを実行する
	for cmd in keys(file_d)
		let _file = file_d[cmd]
		if _file != ''
			call extend(outs, perforce#pfcmds_new_outs(cmd, '', _file))
		endif
	endfor

	call perforce#LogFile(outs)
endfunction
"}}}
function! perforce_2#pfDiff(...) "{{{
	let file_ = call(s:File.get_files, a:000)[0]
	return perforce#pfDiff(file_)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
