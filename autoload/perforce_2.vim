let s:save_cpo = &cpo
set cpo&vim

function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" 補完 : perforce 上に存在するファイルを表示する
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
"}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
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
function! perforce_2#revert(...) "{{{
	" ********************************************************************************
	" @param[in] ファイル名
	" ********************************************************************************
	let files_ = call('perforce#util#get_files', a:000)

	let data_ds = []
	call extend(data_ds, perforce#cmd#use_port_clients_files('p4 revert -a', files_, 0))
	call extend(data_ds, perforce#cmd#use_port_clients_files('p4 revert'   , files_, 1))

	let outs = perforce#get#outs(data_ds)

	call perforce#LogFile(outs)
endfunction 
"}}}
function! perforce_2#echo_error(message) "{{{
  echohl WarningMsg 
  echo a:message 
  echohl None
endfunction
"}}}
function! perforce_2#show(str) "{{{
	" ********************************************************************************
	" @par  必ず別windows を表示する
	" ********************************************************************************
	call perforce#util#LogFile('p4show', 1, a:str)
endfunction
"}}}

function! s:get_args(default_key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @par 辞書型に変換する
	"
	" @param[in]     a:default_key
	"  - リスト型の場合の場合に設定したいキー
	"
	" @param[in]     args
	"  - 変換する変数
	"
	" @return        data_ds
	" ********************************************************************************
	if len(a:args) == 0
		let data_ds = [{}]
	elseif type({}) == type(a:args[0])
		let data_ds = a:args
	else
		let data_ds = map(deepcopy(a:args), "{ a:default_key : v:val }")
	endif
	return data_ds
endfunction
"}}}
function! perforce_2#get_data_client(type, key, args) "{{{
	" [2013-06-07 01:47]
	" ********************************************************************************
	" @return        [{a:key : 0, 'use_port_clients' : ['']}]
	" ********************************************************************************
	let data_ds = s:get_args(a:key, a:args)

	let rtn_ds = []
	for data_d in data_ds
		let tmp_clients      = exists("data_d.client") ? [data_d.client] : []
		let key_data         = exists('data_d[a:key]') ? a:type.''.data_d[a:key] : ''
		let use_ports        = call('perforce#data#get_use_ports'        , tmp_clients)
		let use_port_clients = call('perforce#data#get_use_port_clients' , tmp_clients)

		call add(rtn_ds, {
					\ a:key              : key_data,
					\ 'use_ports'        : use_ports,
					\ 'use_port_clients' : use_port_clients,
					\ })
	endfor
	return rtn_ds
endfunction
"}}}
"
function! perforce_2#extend_dicts(key, ...) "{{{
	let rtns = []
	for dicts in a:000
		for dict in dicts
			call extend(rtns, dict[a:key])
		endfor
	endfor
	return rtns
endfunction
"}}}


function! perforce_2#annnotate(file)
	let file = expand("%:p")

	let data_ds = perforce#cmd#use_port_clients_files('p4 annotate', [file], 1)
	let rev_outs = []
	for data_d in data_ds
		let tmps = data_d.outs
		if tmps[0] !~ 'An empty string is not allowed as a file name.'
			call extend(rev_outs, tmps[1:])
		endif
	endfor

	let data_ds = perforce#cmd#use_port_clients_files('p4 diff -dw', [file], 1)
	let diff_outs = []
	for data_d in data_ds
		let tmps = data_d.outs
		if tmps[0] !~ 'An empty string is not allowed as a file name.'
			call extend(diff_outs, tmps[1:])
		endif
	endfor

	" 差分データの設定
	let diffs = []
	let diff  = {}
	for out in diff_outs
		if out !~ '^[<>-]'
			call insert(diffs, copy(diff))
			let diff.type      = matchstr(out, '[acd]')
			let diff.old_start = matchstr(out, '\d\+')-1
			let diff.old_end   = matchstr(out, '\d\+,\zs\d\+\ze[acd]')-1
			let diff.start     = matchstr(out, '[acd]\zs\d\+')-1
			let diff.end       = matchstr(out, '[acd]\d\+,\zs\d\+')-1
			let diff.old_strs  = []
			let diff.new_strs  = []
		elseif out =~ '^<'
			call add(diff.old_strs, out)
		elseif out =~ '^>'
			call add(diff.new_strs, out)
		endif
	endfor
	call insert(diffs, copy(diff))

	" 逆順で、行う
	let new_outs = copy(rev_outs) "{{{
	for diff in diffs[:-2]
		if diff.type == 'a'
			call extend(new_outs, diff.new_strs, diff.old_start+1)
		elseif diff.type == 'd'
			if diff.old_end >= 0
				call remove(new_outs, diff.old_start, diff.old_end)
			else
				call remove(new_outs, diff.old_start)
			endif
		elseif diff.type == 'c' 
			if diff.old_end >= 0
				call remove(new_outs, diff.old_start, diff.old_end)
			else
				call remove(new_outs, diff.old_start)
			endif
			call extend(new_outs, diff.new_strs, diff.old_start)
		endif
	endfor
	"}}}

	if 0
	let old_outs = copy(rev_outs) "{{{
	for diff in diffs[:-2]
		if diff.type == 'd'
			if diff.old_end >= 0
				call remove(old_outs, diff.old_start, diff.old_end)
			else
				call remove(old_outs, diff.old_start)
			endif
		elseif diff.type == 'c' 
			if diff.old_end >= 0
				call remove(old_outs, diff.old_start, diff.old_end)
			else
				call remove(old_outs, diff.old_start)
			endif
		endif
	endfor
	"}}}
	endif

	" 差分データの設定

	winc H
	let ft = &filetype
	"set scb

	let lnum = line(".")

	if 0
		let tmp_file = 'p4_annotate diff'
		call perforce#util#LogFile(tmp_file, 1, diff_outs)
		winc H
		"set scb
		exe 'set ft='.ft
		call cursor(lnum, 0)
	endif

	if 0
		let tmp_file = 'p4_annotate rev'
		call perforce#util#LogFile(tmp_file, 1, rev_outs)
		winc H
		"set scb
		exe 'set ft='.ft
		call cursor(lnum, 0)
	endif 

	if 1
		let tmp_file = 'p4_annotate new'
		call perforce#util#LogFile(tmp_file, 1, new_outs)
		winc H
		"set scb
		exe 'set ft='.ft
		call cursor(lnum, 0)
	endif

	if 0
		let tmp_file = 'p4_annotate old'
		call perforce#util#LogFile(tmp_file, 1, old_outs)
		winc H
		"set scb
		exe 'set ft='.ft
		call cursor(lnum, 0)
	endif

	" window の修正
	vertical res 10
	winc l
	if 0
		vertical res 20
		winc l
		vertical res 20
		winc l
		vertical res 20
		winc l
	endif


endfunction

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
