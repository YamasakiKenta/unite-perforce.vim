let s:save_cpo = &cpo
set cpo&vim

function! perforce#command#revert(...) "{{{
	" ********************************************************************************
	" @param[in] ファイル名
	" ********************************************************************************
	let files_ = call('perforce#util#get_files', a:000)

	let data_ds = []
	call extend(data_ds, perforce#cmd#use_port_clients_files('p4 revert -a', files_, 0))
	call extend(data_ds, perforce#cmd#use_port_clients_files('p4 revert'   , files_, 1))

	let outs = perforce#get#outs(data_ds)

	call perforce#log_file(outs)
endfunction 
"}}}
"
function! perforce#command#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" @par 編集状態、もしくは追加状態にする
	" @param[in] a:add_flg = 1 - TREUE : クライアントに存在しない場合は、ファイルを追加
	" @param[in] a:000     {ファイル名}     値がない場合は、現在のファイルを編集する
	" ********************************************************************************
	"
	let files_ = call('perforce#util#get_files', a:000)

	let data_ds = []
	let data_d = perforce#cmd#use_port_clients_files('p4 edit', files_, 1)
	call extend(data_ds, data_d)
	if ( a:add_flg == 1 )
		let data_d = perforce#cmd#use_port_clients_files('p4 add', files_, 0)
		call extend(data_ds, data_d)
	endif

	let outs = perforce#get#outs(data_ds)
endfunction
"}}}
"
function! s:get_annotate_sub_cmd(cmd, file) "{{{
	" [2013-06-15 12:14]
	let data_ds = perforce#cmd#use_port_clients_files(a:cmd, [a:file], 1)
	let outs = []
	for data_d in data_ds
		let tmps = data_d.outs
		call extend(outs, tmps[1:])
	endfor

	return outs
endfunction
"}}}
function! s:get_annotate_sub_strs(rev_outs, diff_outs) "{{{
	" [2013-06-15 12:26]

	" 逆順で、行う
	let del_outs = []
	let rev_outs  = a:rev_outs
	let diff_outs = a:diff_outs

	let new_outs = copy(rev_outs) 
	let old_outs = []

	" 差分データの設定
	let diffs = s:get_annotate_sub_diffs(diff_outs)

	for diff in diffs
		if diff.type == 'a'
			call extend(new_outs, diff.new_strs, diff.old_start + 1)
		elseif diff.type == 'd'
			if diff.old_end >= 0
				let del_outs = remove(new_outs, diff.old_start, diff.old_end)
			else
				let del_outs =  remove(new_outs, diff.old_start)
			endif
			call extend(old_outs, [diff.state]+ del_outs)
		elseif diff.type == 'c' 
			if diff.old_end >= 0
				let del_outs = remove(new_outs, diff.old_start, diff.old_end)
			else
				let del_outs = [remove(new_outs, diff.old_start)]
			endif
			call extend(old_outs, [diff.state] + del_outs)
			call extend(new_outs, diff.new_strs, diff.old_start)
		endif
	endfor
	"
	return {
				\ 'new' : new_outs,
				\ 'old' : old_outs,
				\ }
endfunction
"}}}
function! s:set_annotate_sub_win(bufnr, lnum, ft) "{{{
	exe 'b '.a:bufnr
	winc H
	call cursor(a:lnum, 0)
	norm zz
	exe 'set ft='.a:ft
endfunction
"}}}
function! s:get_annotate_sub_diffs(diff_outs) "{{{
	let diff_outs = a:diff_outs

	let diffs = []
	let diff  = {}
	for out in diff_outs
		let out = substitute(out, '\\r', '', 'g')
		if out !~ '^[<>-]'
			" 編集行以外
			call insert(diffs, copy(diff))
			let diff.type      = matchstr(out, '[acd]')
			let diff.old_start = matchstr(out, '\d\+')-1
			let diff.old_end   = matchstr(out, '\d\+,\zs\d\+\ze[acd]')-1
			let diff.start     = matchstr(out, '[acd]\zs\d\+')-1
			let diff.end       = matchstr(out, '[acd]\d\+,\zs\d\+')-1
			let diff.state     = out
			let diff.old_strs  = []
			let diff.new_strs  = []
		elseif out =~ '^<'
			" 削除行
			call add(diff.old_strs, out)
		elseif out =~ '^>'
			" 追加行
			call add(diff.new_strs, out)
		endif
	endfor
	call insert(diffs, copy(diff))

	unlet diffs[-1]

	return diffs
endfunction
"}}}
function! perforce#command#annnotate(file) "{{{
	let file = expand("%:p")
	let rev_outs  = s:get_annotate_sub_cmd('p4 annotate', file)
	let diff_outs = s:get_annotate_sub_cmd('p4 diff -dw', file)

	let out_d = s:get_annotate_sub_strs(rev_outs, diff_outs)
	let new_outs = out_d.new
	let old_outs = out_d.old

	" 差分データの設定
	let lnum   = line(".")
	let ft     = &filetype

	tabe %

	let tmp_file = 'new'
	call perforce#util#log_file(tmp_file, 1, new_outs)
	call s:set_annotate_sub_win(bufnr("%"), lnum, ft)

	let tmp_file = 'old'
	call perforce#util#log_file(tmp_file, 1, old_outs)
	call s:set_annotate_sub_win(bufnr("%"), lnum, ft)

	for bufnr in range(2)
		vertical res 20 
		winc l
	endfor

endfunction
"}}}
"
function! perforce#command#complate_have(A,L,P) "{{{
	"********************************************************************************
	" 補完 : perforce 上に存在するファイルを表示する
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
